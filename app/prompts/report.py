from app.models import Message, Session

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


def build_report_prompt(session: Session) -> tuple[str, list[Message]]:
    transcript = "\n".join(f"{m.role}: {m.content}" for m in session.history)
    assumptions = "\n".join(f"- {a}" for a in session.assumptions) or "(ei tunnistettuja oletuksia)"
    risks = "\n".join(f"- {r}" for r in session.risks) or "(ei tunnistettuja riskejä)"

    context = Message(
        role="user",
        content=(
            f"Idea: {session.idea}\n\n"
            f"Keskusteluhistoria:\n{transcript}\n\n"
            f"Tunnistetut oletukset:\n{assumptions}\n\n"
            f"Tunnistetut riskit:\n{risks}\n\n"
            "Laadi lopputulos."
        ),
    )
    return SYSTEM, [context]
