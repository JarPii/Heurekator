## Phase P1 - Structured evaluation profile + risk register (backend)

**Status:** active.
**Depends on:** none.
**Scope:** `app/models.py` gains new schema types; `app/core/engine.py::_generate_report`
assembles a real per-area evaluation profile from already-collected scores instead of
discarding them, and delegates only narrative/synthesis (concept doc, prioritized risk
register, recommendation) to the LLM; `app/prompts/report.py` is updated to ask for a
structured, prioritized risk register instead of leaving risks/assumptions as
unstructured prose context. Frontend rendering is explicitly out of scope (P2).
**Gate level:** full - changes the `Report` API shape the frontend (P2) will consume,
and changes the report-generation LLM call's structured-output schema
(`PLAN-PHASE-DETAILING.md` §3a: "frontend/backend API shape" and "AI routing or tool
behavior" both trigger `full`).

**Current state (verified):**
- `app/models.py:23-26` - `class CriterionScore(BaseModel): criterion: str; score: int
  = Field(ge=1, le=5); comment: str` - already exists, reused as-is.
- `app/models.py:29-35` - `class Evaluation(BaseModel): verdict: Verdict; scores:
  list[CriterionScore]; identified_assumptions: list[str] = Field(default_factory=list);
  identified_risks: list[str] = Field(default_factory=list); contradiction_note: str |
  None = None; rationale: str` - one `Evaluation` is produced per answer.
- `app/models.py:38-42` - `class AreaProgress(BaseModel): area_id: str; attempts: int =
  0; resolved: bool = False; evaluations: list[Evaluation] = Field(default_factory=list)`
  - `Session.areas: list[AreaProgress]` holds one of these per `Area` in `AREAS` order
  (built that way in `Engine.start_session`, `app/core/engine.py:23-29`).
- `app/models.py:45-48` - `class Report(BaseModel): concept_document_markdown: str;
  recommendation: Recommendation; recommendation_rationale: str` - the field to extend.
- `app/models.py:15` - `Recommendation = Literal["jatka", "kehita_lisaa", "hylkaa"]`.
- `app/core/criteria.py:5-8` - `@dataclass(frozen=True) class Area: id: str; label: str;
  seed_question: str`; `AREAS: list[Area]` (7 entries, order is the canonical order).
- `app/core/engine.py:78-80` - current `_generate_report`:
  ```python
  def _generate_report(self, session: Session) -> Report:
      system, messages = build_report_prompt(session)
      return self._llm.complete_structured(system, messages, Report)
  ```
- `app/core/engine.py:1-9` - current imports:
  `from app.models import AreaProgress, Evaluation, Message, Report, Session`
  (`AreaProgress` is imported but not otherwise used in this file beyond type context -
  confirm still needed after edits, do not leave an unused import).
- `app/prompts/report.py:1-26` - `SYSTEM` string + `build_report_prompt(session: Session)
  -> tuple[str, list[Message]]`; passes `session.idea`, a flattened transcript, and two
  flat prose blocks for `session.assumptions` / `session.risks`. Never reads
  `session.areas`.
- `app/llm/base.py` - `LLMClient.complete_structured(system: str, messages:
  list[Message], schema: Type[T]) -> T` - generic; no change needed to this seam, only
  to which pydantic model is passed as `schema`.
- `AGENT-INSTRUCTIONS/DOMAIN/CONCEPTS.md` - `Report` term (alphabetical, after
  `LLMClient`) currently: "The concept document, a recommendation (...), and a rationale
  that an [[LLMClient]] generates once every [[Area]] in a [[Session]] is resolved
  (`app/models.py`, `app/prompts/report.py`)." - must be updated in this phase (design
  rule 5 in `full-plan.md`).

**Read first (do not invent):**
- `app/models.py` - exact current field order/types, listed above; new types must be
  added in dependency order so pydantic resolves forward references correctly (this repo
  uses `from __future__ import annotations` at the top of `models.py`, so annotations are
  strings, but a class referenced in a field must still be **defined earlier in the file**
  for pydantic v2 to resolve it at class-creation time - no `model_rebuild()` calls exist
  in this codebase and this phase must not add one just to work around bad ordering).
- `app/core/engine.py:44-53` - `submit_answer`'s evaluation call already appends every
  `Evaluation` (including `.scores`) onto `progress.evaluations` before this phase's
  code ever runs; this phase only reads that existing data, never re-computes it.

**Build plan:**

1. `app/models.py` - add three new classes and one new type alias, and change `Report`.
   Insert in this exact order (each depends only on names already defined above it):

   a. Immediately after the existing `Recommendation = Literal[...]` (line 15), add:
      ```python
      RiskPriority = Literal["high", "medium", "low"]
      ```

   b. Immediately after `class AreaProgress(BaseModel): ...` (after line 42), add:
      ```python
      class AreaEvaluationSummary(BaseModel):
          area_id: str
          area_label: str
          verdict: Verdict
          scores: list[CriterionScore]
          weaknesses: list[str]
      ```

   c. Immediately after `class AreaEvaluationSummary`, add:
      ```python
      class RiskRegisterEntry(BaseModel):
          description: str
          kind: Literal["assumption", "risk"]
          priority: RiskPriority
      ```

   d. Immediately after `class RiskRegisterEntry`, add:
      ```python
      class ReportNarrative(BaseModel):
          concept_document_markdown: str
          risk_register: list[RiskRegisterEntry]
          recommendation: Recommendation
          recommendation_rationale: str
      ```

   e. Replace the existing `Report` class body:
      ```python
      class Report(BaseModel):
          concept_document_markdown: str
          evaluation_profile: list[AreaEvaluationSummary]
          risk_register: list[RiskRegisterEntry]
          recommendation: Recommendation
          recommendation_rationale: str
      ```

2. `app/prompts/report.py` - replace `SYSTEM` with:
   ```python
   SYSTEM = (
       "Olet Heurekatorin raporttigeneraattori. Kokoa käyty prosessi konseptidokumentiksi "
       "markdown-muodossa: ongelma, kohderyhmä, ratkaisu, seuraavat askeleet. Älä toista "
       "pelkkää oletukset/riskit-listaa proosassa niiden lisäksi — ne annetaan sinulle "
       "erikseen, ja sinun tehtäväsi on yhdistää ne yhdeksi priorisoiduksi "
       "riskirekisteriksi (risk_register): jokaiselle merkinnälle 'description' "
       "(alkuperäinen teksti, älä keksi uutta sisältöä), 'kind' ('assumption' tai 'risk' "
       "sen mukaan kummasta annetusta listasta merkintä tuli), ja 'priority' ('high', "
       "'medium' tai 'low' sen perusteella kuinka vakava tai kiireellinen merkintä on "
       "idean kannalta). Älä pudota yhtäkään annettua oletusta tai riskiä äläkä lisää "
       "uusia. Anna lopuksi suositus yhdellä arvoista 'jatka', 'kehita_lisaa' tai "
       "'hylkaa', ja perustele suositus lyhyesti viitaten käytyyn keskusteluun."
   )
   ```
   `build_report_prompt`'s body and signature are unchanged - it already passes
   `session.assumptions` and `session.risks` as two separate labeled blocks
   (`"Tunnistetut oletukset:\n..."` / `"Tunnistetut riskit:\n..."`), which is exactly
   what the model needs to tag `kind` correctly. Do not touch the function body.

3. `app/core/engine.py` - three changes:

   a. Update the import line (currently
      `from app.models import AreaProgress, Evaluation, Message, Report, Session`) to:
      ```python
      from app.models import (
          AreaEvaluationSummary,
          AreaProgress,
          Evaluation,
          Message,
          Report,
          ReportNarrative,
          Session,
      )
      ```
      (confirmed via `grep -n "AreaProgress" app/core/engine.py`: line 26,
      `Engine.start_session`, uses `AreaProgress(area_id=a.id)` - it stays in the import
      list; only add the two new names.)

   b. Replace `_generate_report` (current lines 78-80):
      ```python
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
      ```

   c. Add a new private static method in the same class, directly below
      `_generate_report`:
      ```python
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
      ```
      Uses the module-level `AREAS` import already present in this file
      (`from app.core.criteria import AREAS, MAX_ATTEMPTS_PER_AREA`, line 3 - unchanged).
      Score threshold for "weakness" is `<= 3` on the existing 1-5 scale (settled here,
      not deferred - a score of 3 out of 5 is mediocre, not a pass).
      Looks up by `progress.area_id` rather than assuming list-position alignment
      between `session.areas` and `AREAS`, even though `start_session` currently builds
      them in the same order - do not silently rely on that ordering invariant holding
      forever.

**Callers / wiring to update:**
- `app/core/engine.py::submit_answer` calls `self._generate_report(session)` once, at
  the point where the last `Area` resolves (existing call site, unchanged signature -
  no edit needed there beyond what's already covered by step 3b's return-type-compatible
  replacement).
- `app/main.py::submit_answer` (the FastAPI route) does `report.model_dump()` when
  `report is not None` - no code change needed there; the dict will simply gain
  `evaluation_profile` and `risk_register` keys, since it dumps whatever `Report` object
  it receives.
- `frontend/app.js::renderReport` reads `report.recommendation`,
  `report.recommendation_rationale`, and `report.concept_document_markdown` today and
  will silently ignore the two new keys until P2 - confirmed acceptable, P2 depends on
  this phase being done first.

**Config / schema / migrations:**
- None. No database, no migration files exist in this repo (`AGENT-INSTRUCTIONS/PROJECT.md`
  §3, §5). This is a pure in-process pydantic schema change; `data/sessions/*.json` files
  written by prior runs under the old `Report` shape are local runtime state
  (gitignored, per `AGENT-INSTRUCTIONS/PROJECT.md` §4.3) - do not attempt to migrate them.

**Rules / MUST NOT:**
- Do not touch `app/core/criteria.py` (`AREAS`, `EVALUATION_CRITERIA`,
  `MAX_ATTEMPTS_PER_AREA`) - out of scope for this plan (`full-plan.md` design rule 3).
- Do not touch `frontend/` - P2's scope, not this phase's (`full-plan.md` Phase P1 "Must
  not").
- Do not add a human-approval/review step before `Report` is produced or persisted -
  would violate `AGENT-INSTRUCTIONS/PROJECT.md` §4.4 as currently stated (LLM output is
  trusted without human review); that invariant is unchanged by this phase.
- Do not call `model_rebuild()` or restructure `app/models.py` beyond the exact
  insertions in step 1 - keep the diff to the new/changed classes only.
- Do not have the LLM (`ReportNarrative`) re-emit or re-score `evaluation_profile` -
  `full-plan.md` design rule 1 requires `Evaluation.scores` to stay the single source of
  truth; the LLM only ever sees `session.assumptions` / `session.risks` / the transcript,
  never `session.areas`.
- No new config keys, thresholds, or model names are introduced by this phase (the `<= 3`
  weakness threshold is a plain Python literal in `_build_evaluation_profile`, not a
  policy knob - do not promote it to `.env` or `criteria.py` as part of this phase).

**Tests:**
- No automated test suite exists in this repo (`AGENT-INSTRUCTIONS/PROJECT.md` §3) - none
  added or run as part of this phase; adding one is out of scope
  (`full-plan.md` "Carry-overs / deferred").

**Automated tests (E2E):** N/A — no E2E harness exists anywhere in this repo
(`AGENT-INSTRUCTIONS/PROJECT.md` §3 states this gap explicitly; confirmed again during
this phase's research pass: no `tests/` directory, no CI). `PLAN-PHASE-DETAILING.md` §8b
would normally require automated coverage for a `full`-gated, workflow-visible phase;
since the harness itself does not exist, every derived use case below is deferred with
that single honest reason rather than claimed as covered.

| Use case (actor + intent) | Described | Manual User test | Automated E2E |
|---|---|---|---|
| Single internal user completes all 7 areas and receives a `Report` with a populated `evaluation_profile` (7 entries) and a non-empty `risk_register` | scoped | step 1-3 below | deferred — no E2E harness exists in this repo |
| An area where every `CriterionScore.score` is > 3 produces an empty `weaknesses` list for that area, not an error | scoped | step 3 below (inspect at least one area's `weaknesses`) | deferred — no E2E harness exists in this repo |
| A session with an empty `session.risks` and `session.assumptions` (never happens today since `Evaluation` always yields at least one of each in practice, but the code must not crash if it did) still returns a `Report` with `risk_register: []` rather than erroring | scoped | not exercised by manual test (requires forcing an unusual model response) - accepted gap, revisit only if this ever surfaces in real use | deferred — no E2E harness exists in this repo |

**User test (manual, run by the user to prove it works):**
- *Automation can't reach it*: no E2E harness exists in this repo to prove this
  end-to-end, and the behavior depends on a live LLM response, so a human must run one
  real session and read the JSON.
1. Start the server: `source venv/bin/activate && uvicorn app.main:app --reload --port
   8001` (per `AGENT-INSTRUCTIONS/PROJECT.md` §3; adjust port if 8000/8001 are free).
2. Run a full session end-to-end via `curl` against `POST /api/sessions` then repeated
   `POST /api/sessions/{id}/answer` calls (same pattern used earlier in this project's
   own debugging) until the response has `"done": true`.
3. Inspect the final JSON's `report` object and confirm:
   - `evaluation_profile` is a list of 7 objects, each with `area_id`, `area_label`,
     `verdict`, a non-empty `scores` list of `{criterion, score, comment}`, and a
     `weaknesses` list (may legitimately be empty for a strong area).
   - `risk_register` is a non-empty list (given a normal session generates several
     assumptions/risks over 7 areas), each entry has `description`, `kind` (`assumption`
     or `risk`), and `priority` (`high`, `medium`, or `low`).
   - `concept_document_markdown`, `recommendation`, `recommendation_rationale` are still
     present and non-empty (unchanged from before this phase).

**Completion checklist (gate):**
- [ ] `full` gate requirements from `PLAN-PHASE-DETAILING.md` §3a satisfied: targeted
      manual verification done (no automated tests exist to run), caller/wiring audit
      done (table above), phase document re-read after implementation, invariant check
      against `AGENT-INSTRUCTIONS/PROJECT.md` §4.4 done (no human-approval gate added).
- [ ] `app/models.py` changes match Build plan step 1 exactly; `python3 -c "import
      app.models"` succeeds with no import/definition-order errors.
- [ ] `app/core/engine.py` imports updated; no unused-import warning for `AreaProgress`
      unless confirmed still used elsewhere in the file.
- [ ] `app/main.py` runs unmodified and still imports cleanly
      (`ANTHROPIC_API_KEY=dummy python3 -c "from app.main import app"` or the Mistral
      equivalent, matching how this was smoke-tested earlier in this project).
- [ ] User test steps 1-3 above run against a real live session and pass.
- [ ] `AGENT-INSTRUCTIONS/DOMAIN/CONCEPTS.md` - `Report` term updated to describe
      `evaluation_profile` and `risk_register`; new terms added for
      `AreaEvaluationSummary` and `RiskRegisterEntry` (alphabetical placement); run
      `AGENT-INSTRUCTIONS/SCRIPTS/check-domain-concepts.sh` and confirm PASS.
- [ ] `AGENT-INSTRUCTIONS/SCRIPTS/check-portability.sh` still PASSes (no new leaked
      terms expected, but confirm - new class names like `RiskRegisterEntry` are
      lowercase-free-of-collision but check anyway).
- [ ] Safety commit made.
- [ ] User test steps handed to the user and confirmed passing.
- [ ] On confirmation: compress this file into `done/P1-structured-evaluation-profile.md`
      (frozen contract only) and flip the `full-plan.md` status row to `done`.

**Exit:** `POST /api/sessions/{id}/answer`'s final response (`"done": true`) carries a
`Report` whose `evaluation_profile` and `risk_register` are real, populated, structured
data derived from what the loop already computed - not discarded, not left as
unstructured prose. `DOMAIN/CONCEPTS.md` reflects the new shape. Frontend rendering is
still the old 3-field view until P2 lands.
