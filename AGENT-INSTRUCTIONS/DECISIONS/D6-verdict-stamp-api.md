# D6 — Kuulustelu-UI:n verdiktileima: yksi uusi kenttä `submit_answer`-vastaukseen

**Tausta.** `AGENT-INSTRUCTIONS/PLANS/interrogation-ui/full-plan.md` (ROADMAP.md R1,
D1:n toteutus `frontend/`-koodiin) skoopattiin backend-koskemattomaksi — pelkkä
visuaalinen uudelleenmuotoilu. Skoopatessa löytyi kuitenkin aukko: `app/core/engine.py`
`submit_answer` (rivi 53) laskee jokaiselle vastaukselle `Evaluation`n (verdikti +
pisteet), mutta `app/main.py`:n reitti (rivit 39–49) ei koskaan palauta sitä —
frontend saa vain seuraavan kysymyksen ja `area_index`:n. `area_index` yksin riittää
7-aluepalkkiin (alueet ratkeavat aina `AREAS`-järjestyksessä, `app/core/criteria.py`),
mutta ei elävään verdiktileimaan yksittäiselle vastaukselle.

**Kaksi vaihtoehtoa, jotka kirjattiin plan-tiedostoon avoimena kysymyksenä ennen
päätöstä:**

1. **Ei backend-muutosta.** Kuulusteluruutu näyttäisi aluepalkin ja transkriptin,
   mutta verdikti näkyisi vasta lopullisessa raportissa (`evaluation_profile`, jo
   valmis `report-fidelity`-suunnitelman P1/P2:n kautta).
2. **Yksi uusi kenttä.** `Engine.submit_answer` palauttaa myös jo laskemansa
   `Evaluation`n; `app/main.py`:n reitti lisää yhden kentän (esim. `verdict`)
   ei-`done`-vastaukseensa. Pieni, lisäävä, taaksepäin yhteensopiva muutos — mikään
   olemassa oleva kenttä ei muutu.

**Valinta ja syy.** Käyttäjä valitsi vaihtoehdon 2. D1:n koko visuaalinen perustelu
(`D1-ui-direction.md`) on nimenomaan se, että arviointi "lyö kirjaimellisen leiman" —
elävänä hetkenä, ei jälkikäteen raportissa. Ilman tätä kenttää kuulustelu-UI olisi
voinut näyttää aluepalkin edistymisen muttei koskaan sitä konkreettista mekaniikkaa,
jonka takia Kuulustelupöytäkirja-suunta alun perin valittiin muiden kahden
vaihtoehdon (Sokraattinen pöytäkirja, Diagnostiikkalaite) sijaan.

**Vaikutus suunnitelmaan.** `PLANS/interrogation-ui/full-plan.md`:n Phase P2:n
gate-taso nousee `standard`:sta `full`:iin, koska muutos koskee API-vastauksen
muotoa — sama peruste jota `report-fidelity`-suunnitelman P1 käytti kun se nosti oman
gate-tasonsa vastaavasta syystä. P2:n tarkka kenttänimi ja -muoto (`verdict` vs. koko
`Evaluation`-objekti) ratkaistaan Phase P2:n yksityiskohtaisessa suunnittelussa
(`PLAN-PHASE-DETAILING.md`), ei tässä päätöksessä.

**Mitä tämä ei muuta.** `Engine`n arviointilogiikka itsessään (mikä tekee vastauksesta
`kestävä`/`pinnallinen`/jne., milloin alue ratkeaa) pysyy koskemattomana — tämä
päätös koskee vain sitä, että jo olemassa oleva tulos myös *näytetään* käyttäjälle
aiempaa aikaisemmin, ei sitä miten se lasketaan. `PROJECT.md` §4 invariantti 4 (LLM:n
tuotos on luotettu ilman ihmistarkistusta) pysyy siis totena — tämä ei lisää
tarkistusporttia, se vain tekee olemassa olevasta, jo luotetusta tuotoksesta
näkyvämmän aiemmin.
