import uuid

from app.core.criteria import AREAS, MAX_ATTEMPTS_PER_AREA
from app.core.store import SessionStore
from app.llm.base import LLMClient
from app.models import (
    AreaEvaluationSummary,
    AreaProgress,
    Evaluation,
    Message,
    Report,
    ReportNarrative,
    Session,
    Verdict,
)
from app.prompts.evaluation import build_evaluation_prompt
from app.prompts.question import build_question_prompt
from app.prompts.report import build_report_prompt


class Engine:
    """Orkestroi vision §3.1 syklin: kysymys → vastaus → arviointi → sopeutus →
    seuraava kysymys. Ei tunne LLM-kutsujen tai tallennuksen toteutustapaa —
    puhuu vain LLMClient- ja SessionStore-rajapintoja vasten.
    """

    def __init__(self, llm: LLMClient, store: SessionStore):
        self._llm = llm
        self._store = store

    def start_session(self, idea: str) -> tuple[Session, str]:
        session = Session(
            id=str(uuid.uuid4()),
            idea=idea,
            areas=[AreaProgress(area_id=a.id) for a in AREAS],
        )
        question = self._ask_next_question(session)
        self._store.save(session)
        return session, question

    def submit_answer(
        self, session: Session, answer: str
    ) -> tuple[Session, str | None, Report | None, Verdict]:
        if session.status == "done":
            raise ValueError("Sessio on jo päättynyt.")

        area = AREAS[session.current_area_index]
        progress = session.areas[session.current_area_index]

        session.history.append(Message(role="user", content=answer))
        progress.attempts += 1

        system, messages = build_evaluation_prompt(area, answer, session.history)
        evaluation = self._llm.complete_structured(system, messages, Evaluation)
        progress.evaluations.append(evaluation)

        for assumption in evaluation.identified_assumptions:
            if assumption not in session.assumptions:
                session.assumptions.append(assumption)
        for risk in evaluation.identified_risks:
            if risk not in session.risks:
                session.risks.append(risk)

        resolved = evaluation.verdict == "kestava" or progress.attempts >= MAX_ATTEMPTS_PER_AREA
        progress.resolved = resolved

        if not resolved:
            question = self._ask_next_question(session, evaluation)
            self._store.save(session)
            return session, question, None, evaluation.verdict

        if session.current_area_index + 1 < len(AREAS):
            session.current_area_index += 1
            question = self._ask_next_question(session)
            self._store.save(session)
            return session, question, None, evaluation.verdict

        report = self._generate_report(session)
        session.report = report
        session.status = "done"
        self._store.save(session)
        return session, None, report, evaluation.verdict

    def _ask_next_question(
        self, session: Session, last_evaluation: Evaluation | None = None
    ) -> str:
        area = AREAS[session.current_area_index]
        system, messages = build_question_prompt(session.idea, area, session.history, last_evaluation)
        question = self._llm.complete_text(system, messages)
        session.history.append(Message(role="assistant", content=question))
        return question

    def _generate_report(self, session: Session) -> Report:
        system, messages = build_report_prompt(session)
        narrative = self._llm.complete_structured(system, messages, ReportNarrative)
        return Report(
            concept_document_markdown=narrative.concept_document_markdown,
            evaluation_profile=self._build_evaluation_profile(session),
            risk_register=narrative.risk_register,
            recommendation=narrative.recommendation,
            recommendation_rationale=narrative.recommendation_rationale,
        )

    @staticmethod
    def _build_evaluation_profile(session: Session) -> list[AreaEvaluationSummary]:
        progress_by_area_id = {progress.area_id: progress for progress in session.areas}
        profile: list[AreaEvaluationSummary] = []
        for area in AREAS:
            progress = progress_by_area_id.get(area.id)
            if progress is None or not progress.evaluations:
                continue
            last_evaluation = progress.evaluations[-1]
            weaknesses = [
                f"{score.criterion}: {score.comment}"
                for score in last_evaluation.scores
                if score.score <= 3
            ]
            profile.append(
                AreaEvaluationSummary(
                    area_id=area.id,
                    area_label=area.label,
                    verdict=last_evaluation.verdict,
                    scores=last_evaluation.scores,
                    weaknesses=weaknesses,
                )
            )
        return profile
