from dataclasses import dataclass

from app.models import Mittakaava


@dataclass(frozen=True)
class Area:
    id: str
    label: str
    seed_question: str


# Vision-dokumentin §3.2 kysymyspatteriston ydinalueet, tässä järjestyksessä käydään läpi.
AREAS: list[Area] = [
    Area("ongelma", "Ongelman määrittely", "Mitä ongelmaa idea ratkaisee, ja onko ongelma todellinen?"),
    Area("kohderyhma", "Kohderyhmä", "Kenelle tästä on hyötyä, ja kuinka spesifi tämä ryhmä on?"),
    Area("tarpeellisuus", "Tarpeellisuus", "Miksi tätä tarvitaan juuri nyt? Mitä tapahtuisi ilman tätä?"),
    Area("vaihtoehdot", "Vaihtoehdot", "Miten ongelma on ratkaistavissa ilman tätä ideaa?"),
    Area("oletukset", "Oletukset", "Mitkä oletukset idea lepää, ja mitkä niistä ovat heikoimpia?"),
    Area("kestavyys", "Kestävyys", "Toimiiko tämä taloudellisesti, teknisesti ja operationaalisesti?"),
    Area("riskit", "Riskit", "Mitkä voivat olla esteet, vastustus tai epäonnistumisskenaariot?"),
]

# Vision-dokumentin §3.3 arviointikriteerit — keskitetty tänne, jotta kalibrointi
# (vision §8 kohta 3) ei vaadi koskemista moottori- tai promptikoodiin.
EVALUATION_CRITERIA: list[str] = [
    "syvyys",
    "konkretia",
    "johdonmukaisuus",
    "oletustietoisuus",
]

# Estää loputtoman silmukan, jos malli ei koskaan päädy "kestävä"-arvioon.
MAX_ATTEMPTS_PER_AREA = 3

# Vision-dokumentin §1.2 / DECISIONS/LOG.md D9 -periaate (a): kysymyksen mittakaava
# perustuu käyttäjän aloitusvalintoihin. Yksi lause per mittakaava, liitetään
# jokaiseen kysymyspromptiin (app/prompts/question.py).
MITTAKAAVA_FRAMING: dict[Mittakaava, str] = {
    "sisainen_toiminta": (
        "Mittakaava: sisäinen toiminta (oman, tiimin, tai koko organisaation "
        "toiminnan kehittäminen). Älä kysy markkinakokoa, myyntipotentiaalia tai "
        "ulkoisten asiakkaiden määrää — keskity sisäiseen hyötyyn, käyttöönottoon "
        "ja resursseihin."
    ),
    "toimitus": (
        "Mittakaava: toimitusprojektin ongelma (korjaava tai ehkäisevä "
        "toimenpide). Kysy toimitusprojektin kontekstista, asiakasvaikutuksesta ja "
        "aikataulupaineesta — ei yleistä markkinakokoa."
    ),
    "uusi_ominaisuus": (
        "Mittakaava: laajennus olemassa olevaan toimitukseen. Kysy miten tämä "
        "sopii nykyiseen tarjontaan ja mille asiakassegmentille ominaisuus on "
        "suunnattu."
    ),
    "uusi_ratkaisu": (
        "Mittakaava: kokonaan uusi, mahdollisesti myytävä ratkaisu. Markkinakoko, "
        "kohderyhmän laajuus ja kilpailutilanne ovat relevantteja kysymyksiä."
    ),
}
