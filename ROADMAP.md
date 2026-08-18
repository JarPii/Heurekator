# Heurekator — Roadmap

> Tämä dokumentti järjestää `Visio.md` §8:n ("Seuraavat askeleet") kohdat
> **toteutusjärjestykseksi, riippuvuuksineen ja nykytilalla varustettuna**. §8 pysyy
> visiodokumentin osana ja kertoo *mitä* — tämä kertoo *missä järjestyksessä ja miksi*,
> ja sitä päivitetään useammin kuin `Visio.md`:tä. Kun jokin alla oleva vaihe (R<n>)
> valitaan toteutukseen, se skoopataan omaksi `AGENT-INSTRUCTIONS/PLANS/<slug>/`-kansiokseen
> `PLAN-AUTHORING-SCOPING.md`:n mukaisesti — tämä dokumentti ei korvaa sitä prosessia,
> se päättää vain minkä vaiheen vuoro on.

## Nykytila (todennettu koodista ja DECISIONS/LOG.md:stä)

| # (§8) | Askel | Tila | Todiste |
|---|---|---|---|
| 1 | Prototyyppi | **Valmis** | `app/core/engine.py`, `app/core/criteria.py` — 7 aluetta, 4 kriteeriä, koko sokraattinen sykli toimii |
| 2 | Oma käyttö (2–3 ideaa läpi) | **Ei todennettavissa repositoriosta** | Käyttöaktiviteetti, ei koodiartefakti — ei tiedossa onko tehty |
| 3 | Arviointikriteerien kalibrointi | **Ei aloitettu / jatkuva** | `EVALUATION_CRITERIA` on yhä ensimmäinen versio; ei kalibrointia kirjattu `DECISIONS/LOG.md`:hen |
| 4 | Lopputuloksen muotoilu | **Valmis** | `PLANS/report-fidelity/full-plan.md` P1+P2 — arviointiprofiili + priorisoitu riskirekisteri, sekä backend että UI |
| 5 | Nelikielisyys | **Päätetty, ei toteutettu** | D3 aktiivinen; `app/core/criteria.py`, `app/prompts/*.py`, `frontend/` ovat yhä suomenkielisiä/kieliparametrittomia |
| 6 | Idean elinkaarimalli | **Päätetty, ei toteutettu** | D4 aktiivinen; `app/models.py`:ssä ei ole `Idea`-luokkaa, `app/main.py`:ssä ei ole `GET /api/sessions` |
| 7 | Vektorointi/semanttinen haku | **Tietoisesti lykätty** | D2 (osittain), ei ajankohtainen — volyymiehtoinen, ks. alla |
| 8 | Ongelman validointi | **Vain visiotasolla** | Visio.md §2a: "vaatii vielä muotoilua ennen skoopattavaa suunnitelmaa"; ei D-riviä |
| 9 | Aivoriihi | **Vain visiotasolla** | Visio.md §2b; riippuu 8:sta |
| 10 | Ääni ja litterointi | **Päätetty *mitä*, ei *miten*** | D5 aktiivinen; eksplisiittisesti "ei skoopata ennen kuin 8–9 ovat edes runkona olemassa" |

**Puuttuva rivi §8:ssa:** UI-suunnan (D1, "Kuulustelupöytäkirja") toteutus `frontend/`-koodiin ei ole minkään §8-kohdan alla — D1 on päätetty ja jopa visuaalisesti luonnosteltu, mutta mitään koodia ei ole vielä kirjoitettu. Tämä roadmap lisää sen omaksi vaiheekseen (R1).

## Järjestys ja riippuvuudet

### R1 — Kuulustelupöytäkirja-UI:n toteutus
**Perustuu:** D1 (UI-suunta), uusi brändi-ilme (`Heurekator_logo*.png`, repon juuressa).
**Riippuu:** ei mistään kesken olevasta päätöksestä.
**Tila: P0-P2 valmiit, P3 (raportti) skoopattu muttei vielä detaljoitu.**
`AGENT-INSTRUCTIONS/PLANS/interrogation-ui/full-plan.md` — neljä vaihetta (P0
tokenit/masthead, P1 idea sisään, P2 kuulustelu, P3 raportti).
Skoopatessa löytyi tarkennus alkuperäiseen "ei backend-muutoksia" -oletukseen:
`submit_answer` ei tällä hetkellä palauta juuri annetun vastauksen verdiktiä
frontendille, joten D1:n leimasin-hetki ei voisi näkyä elävänä kesken kuulustelun.
**Ratkaistu (D6):** yksi uusi kenttä lisätään `submit_answer`-vastaukseen — Phase P2:n
gate-taso nousi `full`:iin tämän takia.
**Miksi tässä kohtaa:** pienin ja itsenäisin jäljellä oleva vaihe. Parantaa myös §8
kohdan 2 ("oma käyttö") kokemusta heti, ilman että se odottaa mitään muuta.

### R1.5 — Etusivu ja aloitusvalinnat (D7, D8, D9)
**Perustuu:** D7, laajennettu D8:lla (aivoriihen teemavalikko) ja D9:llä (kysymysten
muotoiluperiaate).
**Riippuu:** R1 (jakaa saman `frontend/`-token/tyylipohjan, D1:n suunta).
**Tila: valmis (2026-08-18).** `AGENT-INSTRUCTIONS/PLANS/mode-selector/full-plan.md` —
neljä vaihetta (P0 kaksivalintainen valitsin, P1 kolmas valinta + mittakaava-ruutu, P2
mittakaava-tietoiset kysymykset, P3 alue-katon näkyväksi tekevä huomautus), kaikki
toteutettu ja käyttäjän vahvistamat. Uusi etusivu sovelluksen aloitusnäytöksi ennen
`#idea-form`:ia. Ensimmäinen valinta, kolme vaihtoehtoa (`Visio.md` §1.2): "Idea"
(johtaa olemassa olevaan §3-validointiin sellaisenaan), "Ongelma" ja "Aivoriihi"
(molemmat näkyvät, mutta selvästi merkitty ei-vielä-toteutetuiksi —
`REPO-RULES.md` §2:n sallima, eksplisiittisesti merkitty degraded path — kunnes
niiden taustalla oleva logiikka on ratkaistu: "Ongelma" R4:ssä, "Aivoriihi" R5:ssä).
Valinnan jälkeen toinen valintaruutu mittakaavalle (sisäinen toiminta / toimitus /
uusi ominaisuus / uusi ratkaisu) — kaapataan käyttöliittymässä varhain, vaikka mikään
myöhempi vaihe ei vielä kuluta sitä. Ei rakenna §2a:n tai §2b:n kysymyslogiikkaa —
ne ovat yhä R4:n ja R5:n vastuulla.
**Ei vielä ratkaistu skoopatessa:** mihin tietomalliin mittakaava-valinta
tallennetaan ennen kuin R3:n `Idea`-malli on olemassa — provisorinen kenttä
`Session`:iin joka siirtyy R3:n myötä, vai odotetaanko R3:a ennen tätä osaa? Tämä
ratkaistaan `PLAN-AUTHORING-SCOPING.md`:n mukaisessa scoping-keskustelussa kun tämä
vaihe otetaan toteutukseen.
**Miksi tässä kohtaa:** paljasti käyttäjätestauksessa (D7:n tausta) ettei sovellus
tarjoa mitään reittiä ongelman validointiin tai aivoriiheen, vaikka `Visio.md` §1.1
kuvaa ne omina vaiheinaan ennen ideaa. Käyttäjä halusi tämän valintakyvyn näkyviin
mahdollisimman varhain — tekee puutteen näkyväksi ja kaappaa mittakaava-valinnan heti,
ilman että mitään §2a:n tai §2b:n ratkaisemattomista kysymyksistä
(pysähtymiskriteeri, kysymyslogiikka, puutteellisen-yhteenvedon täsmällinen
määritelmä aivoriihessä) tarvitsee ratkaista tässä vaiheessa.

### R2 — Nelikielisyys (D3)
**Perustuu:** D3.
**Riippuu:** ei kovaa riippuvuutta R1:stä, mutta kannattaa tulla heti sen jälkeen — muuten `frontend/`-koodia muokataan kahteen kertaan (kerran UI-suunnan takia, kerran kieliparametroinnin takia).
**Miksi tässä kohtaa, ei myöhemmin:** jokainen tämän jälkeen tuleva vaihe (idean elinkaari, ongelman validointi, aivoriihi) lisää uusia kysymyssarjoja tai käyttöliittymätekstejä. Jos nelikielisyys rakennetaan vasta niiden jälkeen, sama käännöstyö pitää tehdä uudestaan jokaiselle niistä erikseen. Rakennettuna nyt, seuraavat vaiheet vain noudattavat jo olemassa olevaa mallia.

### R3 — Idean elinkaarimalli (D4, Visio.md §9)
**Perustuu:** D4.
**Riippuu:** ei kovaa riippuvuutta R1–R2:sta.
**Miksi tässä kohtaa — kova riippuvuus eteenpäin:** aivoriihi (§2b) ei voi toteutua ilman tätä. Visio.md §2b sanoo suoraan: *"Jokainen aivoriihen tuottama tai sieltä poimittu idea päätyy §9.2:n mukaisesti kerätyksi."* Ilman `Idea`-mallia ja keräysmekanismia aivoriihellä ei ole minne kirjoittaa tuotoksiaan. Tämä ei siis ole vain looginen järjestys — se on aivoriihen kova edellytys.

### R4 — Ongelman validointi (Visio.md §2a)
**Perustuu:** ei vielä D-riviä.
**Riippuu:** ei koodiriippuvuutta edellisistä, mutta vaatii oman päätöksentekokeskustelun ensin.
**Ei vielä skoopattavissa:** Visio.md §2a listaa itse ratkaisemattomana pysähtymiskriteerin (kiinteä kierrosmäärä / arviointimoottorin oma "kestävä"-päätös / käyttäjän oma valinta) ja tarkan kysymyslogiikan. Nämä kaksi kysymystä on ratkaistava keskustelussa — todennäköisesti tuottaen oman `DECISIONS/LOG.md`-rivin — ennen kuin `PLAN-AUTHORING-SCOPING.md` voidaan käynnistää tälle.

### R5 — Aivoriihi (Visio.md §2b)
**Perustuu:** ei vielä D-riviä (kysymyslogiikan/rajausten osalta; D5 kattaa vain äänen §2b.1:stä).
**Riippuu:** **R3** (idean elinkaari/keräys, kova riippuvuus edellä kuvatusti) **ja R4** (validoitu ongelma syötteenä aivoriihelle).
**Ei skoopattavissa ennen R3 ja R4 valmistumista.**

### R6 — Ääni ja litterointi (D5, Visio.md §2b.1)
**Perustuu:** D5 (mitä halutaan), ei vielä miten-tason päätöksiä (palveluntarjoaja, puuttumislogiikka).
**Riippuu:** R5 — Visio.md §8 kohta 10 sanoo eksplisiittisesti: *"ei skoopata ennen kuin 8–9 ovat edes runkona olemassa."*
**Huomio:** kunnianhimoisin ja teknisesti raskain vaihe koko roadmapilla (striimattu audio, kolmas palveluntarjoaja Mistralin/Anthropicin rinnalle — ks. D5). Kun R5 on runkona olemassa, tämä kannattaa aloittaa `PLAN-AUTHORING-SCOPING.md` §1a:n "tutkimusvaiheena" (research pass) täyden scoped-planin sijaan, koska teknistä epävarmuutta on paljon (D5:n oma "Tunnistettu, ei ratkaistu" -kohta).

## Ei aikataulutettu — ehto, ei järjestys

- **Vektorointi/semanttinen haku (§8 kohta 7, D2).** Ei sijoitu R1–R6-jonoon, koska sen laukaisin on ideamäärä, ei toteutusjärjestys. Käynnistyy kun selaaminen silmillä ei enää riitä (`D2-persistence-strategy.md`).
- **Arviointikriteerien kalibrointi (§8 kohta 3).** Jatkuva toiminta, ei kertaluontoinen vaihe — tapahtuu oman käytön (§8 kohta 2) palautteen perusteella milloin tahansa, riippumatta R1–R6:n etenemisestä.

## Miten tätä dokumenttia ylläpidetään

- Kun R<n> valitaan toteutukseen: käynnistä `PLAN-AUTHORING-SCOPING.md`, joka tuottaa
  `AGENT-INSTRUCTIONS/PLANS/<slug>/full-plan.md`. Päivitä tämän dokumentin
  "Nykytila"-taulukko kun vaihe valmistuu tai käynnistyy.
- Järjestyksen muuttaminen (esim. R2 ja R3 vaihtavat paikkaa) on `../BUILDING/REPO-RULES.md`
  §0:n tarkoittama roadmap-tason päätös. Jos konkreettinen vaihtoehtoinen järjestys
  hylätään tietoisesti, se saa oman rivin `AGENT-INSTRUCTIONS/DECISIONS/LOG.md`:ssä —
  tämä tiedosto itsessään ei ole se binding-lähde, `LOG.md` on.
- Tämä tiedosto ei ole osa `AGENT-INSTRUCTIONS/`-pakettia eikä sitä synkata muihin
  repoihin — se on tämän projektin oma, kuten `Visio.md`.

---

*Heurekator — Roadmap*
*Perustuu `Visio.md` v0.7 §8:aan ja `AGENT-INSTRUCTIONS/DECISIONS/LOG.md`:n tilaan, elokuu 2026.*
