# D2 — Säilytysstrategia: kevyt ensin, vektorihaku myöhemmin

> **Superseded by [D4](D4-idea-lifecycle.md) (2026-08-17).** D2:n "kevyt sessiolistaus"
> korvattiin laajemmalla idea-elinkaarimallilla ennen kuin sitä ehdittiin toteuttaa —
> loput tästä tiedostosta kuvaavat alkuperäisen, nyt korvatun ajatuksen.

**Tausta.** Käyttäjä ehdotti Postgres-tyyppistä suoraa tallennusta ja mahdollista
vektorilisäosaa (pgvector), jotta vanhoihin ideoihin pääsee uudelleen käsiksi ja
kaikki keskustelut jäävät talteen myöhempää tarkastelua ja mahdollista
uudelleenarviointia varten.

**Havainto ennen päätöstä.** Osa tarpeesta on jo ratkaistu: `JSONFileStore`
(`app/core/store.py`) ei koskaan poista mitään — jokainen sessio (koko
kysymys-vastaus-historia, arvioinnit, raportti) säilyy pysyvästi `data/sessions/`-
kansiossa. "Kaikki keskustelut jäävät talteen" on siis jo totta. Todellinen aukko oli
löydettävyys: ei ole listausta menneistä sessioista (jo aiemmin kirjattu tunnettuna
puutteena `PROJECT.md` §4.1:ssä).

**Kaksi erillistä tarvetta, jotka helposti sekoittuvat yhdeksi päätökseksi:**
1. **Selaus/uudelleenavaus** — nähdä lista omista ideoista, avata jokin uudelleen.
   Ei vaadi uutta infraa, ratkeaa `JSONFileStore`:n päälle rakennetulla
   listausendpointilla.
2. **Semanttinen haku** — tunnistaa automaattisesti samankaltaiset/toistuvat ideat.
   Vaatii oikeasti vektorihaun (embeddaus + samankaltaisuushaku), ja siihen
   Postgres+pgvector (tai vastaava) on perusteltu ratkaisu.

Käyttäjä vahvisti tarvitsevansa molempia, mutta halusi aloittaa kevyestä.

**Päätös.** Ei oteta Postgresia/pgvectoria käyttöön nyt. Sen sijaan:
- Lyhyellä aikavälillä: kevyt sessiolistaus nykyisen `JSONFileStore`:n päälle (uusi
  endpoint, ei uutta tallennusteknologiaa) — ratkaisee tarpeen 1 kokonaan.
- Vektorihaku (tarve 2) jää tietoiseksi, kirjatuksi myöhemmäksi vaiheeksi. Ei
  toteuteta ennen kuin ideamäärä on oikeasti sellainen että selaaminen silmillä ei
  enää riitä.

**Miksi ei Postgres+pgvector nyt.** `PROJECT.md` §5-§6: ei deploy-kohdetta, yksi
kehittäjä, ei tietokantaa eikä migraatioita tällä hetkellä missään osassa repoa.
Postgres+pgvector toisi mukanaan käynnissä olevan DB-palvelimen, migraatiot,
embeddausputken (uusi LLM-kutsu per idea/viesti → kustannus ja viive) ja
käyttöoikeuksien/varmuuskopioinnin miettimisen — merkittävä infrapainon lisäys
prototyypille jonka nykyinen ideamäärä ei vielä perustele.

**Miksi tämä ei lukitse mitään.** `SessionStore`-abstraktio (`app/core/store.py`)
rakennettiin alun perin juuri tätä varten: `Engine` (`app/core/engine.py`) puhuu vain
`SessionStore`-rajapintaa vasten, ei `JSONFileStore`-toteutusta suoraan. Postgresiin
(tai mihin tahansa muuhun) siirtyminen myöhemmin ei vaadi koskemista `engine.py`:hin —
vain uuden `SessionStore`-toteutuksen kirjoittamista.

**Seuraava askel.** Kevyt sessiolistaus omana scoped-planinaan
(`PLAN-AUTHORING-SCOPING.md`:n mukaisesti) kun toteutus aloitetaan. Vektorihaku ei ole
vielä pläänattu — se odottaa kunnes ideamäärä oikeasti kasvaa.
