# D4 — Idea-elinkaarimalli (korvaa D2:n)

**Tausta.** Käyttäjä kuvasi Heurekatorin käytön kolmena erilaisena tilana: ideoiden
kerääminen ilman syvempää analyysiä, ideoiden validointi (D1–D3:ssa jo rakennettu
sokraattinen prosessi), ja ideoiden luokittelu useaan mahdolliseen kohteeseen — suoraan
sivuun (ei kuitenkaan poisteta), validointiin, jatkoon, arkistoon, "jne."

Tämä muuttaa perusrakennetta: `Session` (validointi) ei ole enää koko malli, vaan
yksi asia mitä idealle voi tapahtua sen elinkaaren aikana. Validointi jää
sisällöllisesti ennalleen (§3, ei muutu) — muutos on siinä että sen ympärille tulee
laajempi `Idea`-käsite tilalla.

**Kolme alipäätöstä, jotka käytiin läpi ennen kirjaamista:**

1. **Kerääminen on täysin kevyt.** Ei LLM-kutsua ollenkaan — pelkkä teksti +
   aikaleima. Vaihtoehtona harkittu kevyt LLM-esikatselu/tiivistelmä hylättiin: se
   olisi tuonut kustannuksen ja viiveen jo keräysvaiheeseen, joka on nimenomaan
   tarkoitettu olemaan nopea eikä vielä pakottava (§1, §9.2). Paine tulee vasta
   validoinnissa.

2. **Tilalista on avoin, ei suljettu.** Neljä nimettyä tilaa (kerätty/sivuun/
   validoinnissa/jatkossa/arkistossa) ovat ensimmäiset, ei ainoat — käyttäjä mainitsi
   itse "jne." Malli on siis avoin lista, samaan tapaan kuin arviointialueet
   `app/core/criteria.py`:ssa ovat konfiguroitavissa koodissa ilman että itse
   moottoria (`app/core/engine.py`) tarvitsee koskea. Siirtymät tilojen välillä ovat
   vapaita — ei pakotettua tilakonetta, ei sallittujen siirtymien listaa. Tämä on
   tietoinen yksinkertaistus: tiukka tilakone säännöillä (esim. "arkistosta ei voi
   siirtyä suoraan jatkoon") olisi lisännyt monimutkaisuutta ilman että käyttäjä
   pyysi sitä.

3. **D2 korvataan, ei täydennetä.** Edellisen kierroksen D2 ("kevyt sessiolistaus"
   suoraan `JSONFileStore`:n päälle) oli mitoitettu näyttämään vain valmiit
   validointiajot. Jos elinkaarimalli on todellinen tavoite, sama listausnäkymä
   jouduttaisiin rakentamaan kahteen kertaan — ensin D2:n suppeana versiona, sitten
   uudelleen elinkaarimallin päälle. D2:n `Status` muutettu `superseded by D4`:ksi
   samassa muutoksessa (`DECISIONS/README.md`:n append-only-säännön mukaisesti); D2:n
   rivin `Decision`/`Rejected`/`Why rejected` -sarakkeet pysyvät ennallaan sellaisina
   kuin ne kirjattiin.

**Suhde D2:een.** D2 sisälsi kaksi erillistä tarvetta yhdessä päätöksessä: (1) kevyt
sessiolistaus `JSONFileStore`:n päälle, ja (2) Postgres+pgvector-vektorihaun
lykkääminen myöhempään vaiheeseen. Tämä päätös (D4) korvaa **vain** tarpeen (1) —
elinkaarimalli tekee erillisen sessiolistauksen tarpeettomaksi, koska sama näkymä
rakennetaan `Idea`-tilan päälle suoraan. Tarve (2) — ei Postgresia/pgvectoria nyt — **ei
muutu tässä päätöksessä**; D2:n perustelu sille (ei deploy-kohdetta, ei tietokantaa,
`SessionStore`-abstraktio tekee myöhemmästä vaihdosta halvan) pysyy voimassa
sellaisenaan. `LOG.md`:n `Status`-sarake ei erottele osittaista korvautumista rivi-
tasolla, joten D2:n rivi näkyy kokonaan `superseded by D4`:nä vaikka vain sen
sessiolistaus-osa on korvattu — ks. D2:n oma narratiivi tästä tarkennuksesta.

**Suhde `Session`-käsitteeseen (`DOMAIN/CONCEPTS.md`).** Koska idea voi siirtyä
validointiin useaan kertaan elinkaarensa aikana (§9.4), yksi `Idea` voi liittyä
useampaan `Session`-tallenteeseen ajan myötä — ei ylikirjoiteta, jokainen validointikierros
säilyy omanaan. Tarkka tekninen suhde (`Idea.id` viittaus `Session`-tallenteisiin vai
päinvastoin, tallennusmuoto) ei ole vielä ratkaistu — se ratkaistaan scoped-planin
yhteydessä (`PLAN-AUTHORING-SCOPING.md`), ei tässä päätöksessä.

**Mitä tämä ei vielä ratkaise.** Tarkka tekninen toteutus (uusi `Idea`-malli koodissa,
mihin `data/`-hakemistoon se tallentuu, miten listaus/luokittelu-UI toimii, miten tämä
nivoutuu D3:n kielivalintaan — valitaanko kieli jo keräysvaiheessa vai vasta kun idea
siirtyy validointiin) on auki. Ratkaistaan `PLAN-AUTHORING-SCOPING.md`:n ja
`PLAN-PHASE-DETAILING.md`:n mukaisesti kun toteutus aloitetaan.
