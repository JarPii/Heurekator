from app.core.criteria import Area
from app.models import Evaluation, Message

SYSTEM = (
    "Olet Heurekator, sokraattinen ideanarviointityökalu. Tehtäväsi on esittää "
    "yksi tarkka, haastava kysymys kerrallaan, joka pakottaa idean esittäjän "
    "perustelemaan vastauksensa konkreettisesti — esimerkein, luvuin tai nimetyin "
    "ryhmin. Vastaa vain itse kysymyksellä, ilman selittelyä tai saatelauseita."
)


def build_question_prompt(
    idea: str,
    area: Area,
    history: list[Message],
    last_evaluation: Evaluation | None,
) -> tuple[str, list[Message]]:
    context_lines = [
        f"Idea: {idea}",
        f"Käsiteltävä osa-alue: {area.label} ({area.seed_question})",
    ]
    if last_evaluation is not None:
        context_lines.append(
            f"Edellisen vastauksen arvio: {last_evaluation.verdict} — {last_evaluation.rationale}"
        )
        if last_evaluation.contradiction_note:
            context_lines.append(f"Havaittu ristiriita: {last_evaluation.contradiction_note}")
    context_lines.append("Esitä seuraava kysymys tälle osa-alueelle.")

    intro = Message(role="user", content="\n".join(context_lines))
    return SYSTEM, [*history, intro]
