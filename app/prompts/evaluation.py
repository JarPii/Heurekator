from app.core.criteria import Area, EVALUATION_CRITERIA
from app.models import Message

SYSTEM = (
    "Olet Heurekatorin arviointimoottori. Arvioi käyttäjän VIIMEISIN vastaus "
    "yksinomaan sen sisällön perusteella — älä anna kysymyksen muotoilun vaikuttaa "
    "arvioon. Käytä kriteereitä: " + ", ".join(EVALUATION_CRITERIA) + ". Anna "
    "jokaiselle kriteerille pistemäärä 1-5 ja lyhyt perustelu. Tunnista vastauksesta "
    "mahdolliset implisiittiset oletukset ja riskit. Jos vastaus on ristiriidassa "
    "aiemman keskusteluhistorian kanssa, kuvaa ristiriita contradiction_note-kentässä. "
    "Päätä lopuksi verdict yhdellä arvoista: 'pinnallinen' (ei konkretiaa), "
    "'ristiriitainen' (ristiriita aiempaan), 'puuttuva_nakokulma' (jättää olennaisen "
    "huomiotta), 'yksiulotteinen' (ei kestä vastakysymystä/ääritilannetta), tai "
    "'kestava'. Valitse 'kestava' vain jos vastaus on konkreettinen, johdonmukainen "
    "aiempien vastausten kanssa ja erottaa faktat oletuksista."
)


def build_evaluation_prompt(
    area: Area,
    answer: str,
    history: list[Message],
) -> tuple[str, list[Message]]:
    context = Message(
        role="user",
        content=(
            f"Käsiteltävä osa-alue: {area.label} ({area.seed_question})\n"
            f"Käyttäjän vastaus: {answer}\n\n"
            "Arvioi vastaus yllä kuvatuilla kriteereillä."
        ),
    )
    return SYSTEM, [*history, context]
