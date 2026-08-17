# D1 — UI-suunta: Kuulustelupöytäkirja

**Tausta.** MVP:n frontend (`frontend/`) on tähän asti ollut geneerinen chat-UI —
harmaat/siniset kuplat, tavallinen lomake. Se ei viesti Visio.md:n omaa ydinajatusta:
Heurekator ei ole avustava chatbotti, se on työkalu joka nimenomaan pakottaa idean
kantajan paineen alle (Visio.md §1).

**Kolme vaihtoehtoa.** Kolme visuaalista suuntaa luonnosteltiin yhtenä vertailuartefaktina,
sama todellinen sisältö (oikea Kohderyhmä-vaiheen kysymys/vastaus/arviointi omasta
Heurekator-testiajosta) kolmella eri tulkinnalla:

1. **Kuulustelupöytäkirja** — tumma, karu, pöytäkirjamainen. Kysymykset
   monospace-leimasimen tyyliin ("ALUE 02/07 — KOHDERYHMÄ"), vastaukset kuin
   kuulusteltavan lausunto, arviointi lyö kirjaimellisen leiman ("KESTÄVÄ",
   kallistettuna kuin rubber stamp).
2. **Sokraattinen pöytäkirja** — kylmä kivensävy (tietoisesti ei lämmin
   kerma+terrakotta-klisee), keskitetty dialogi-layout kuin lukisi klassista tekstiä,
   arviointi jää hienovaraiseksi marginaalimerkinnäksi.
3. **Diagnostiikkalaite** — hyödyntää sitä että data on P1/P2:n jälkeen oikeasti
   rikasta (7 aluetta, 4 kriteeriä, priorisoitu riskirekisteri): mittaristo,
   statusruudukko, väri-koodatut riskiraidat.

Vertailuartefakti (ei enää elossa pysyvä linkki tämän tiedoston ulkopuolella, mutta
kuvakaappaukset ja lähdekoodi säilyvät keskusteluhistoriassa): kolme rinnakkaista
`.concept-frame`-lohkoa, kukin oma kiinteä väripaletti riippumatta katsojan
teemavalinnasta (tietoinen valinta, ei laiminlyönti — ks. kunkin `.c1`/`.c2`/`.c3`-
lohkon kommentit `frontend/`-koodin ulkopuolisessa luonnoksessa).

**Valinta ja syy.** Kuulustelupöytäkirja valittiin, koska se on ainoa kolmesta joka
ottaa Visio.md §1:n sanan "pakottaa" kirjaimellisesti visuaalisena kielenä eikä vain
tekstinä. Sokraattinen pöytäkirja on esteettisesti kaunis mutta *rauhoittava* —
keskitetty, hidas, kontemplatiivinen — mikä on ristiriidassa "paineen" kanssa.
Diagnostiikkalaite on hyvä datan esittämiseen (ja voi hyvinkin lainata elementtejä
myöhemmin raportin puolelle, ks. alla) mutta kliininen mittaristo-tunnelma ei itsessään
luo kuulustelun painetta kysymyshetkellä — se etäännyttää.

**Ei suljettu pois kokonaan.** Diagnostiikkalaitteen mittaristot (aluekohtaiset
statusruudut, priorisoidun riskirekisterin väristripe-esitys) ovat todennäköinen
lainauslähde kun raportti-näkymää (nykyinen `renderReport()`, ks. `done/P2-render-report.md`)
kehitetään Kuulustelupöytäkirja-suunnan sisällä eteenpäin — kysymyshetken tunnelma ja
raportin datan esitystapa eivät ole sama päätös.

**Seuraava askel.** Ei vielä pläänattu — tämä päätös koskee vain suuntaa, ei
toteutuslaajuutta. `PLAN-AUTHORING-SCOPING.md`:n mukainen scoped plan tehdään kun
toteutus aloitetaan.

**Miksi tämä ylittää `DECISIONS/LOG.md`:n kynnyksen.** `DECISIONS/README.md` §2 kirjaa
lokiin vain päätöksiä jotka muuttavat visiota tai roadmapia — ei taktisia
toteutusvalintoja. Pelkkä väripaletti tai layout ei sinänsä ylittäisi tätä. Tämä päätös
ylittää sen silti, koska se ei ole vain visuaalinen valinta: se on tulkinta siitä mitä
Visio.md §1:n ydinsana "pakottaa" tarkoittaa käyttöliittymässä, ja se hylkää kaksi
muuten toteuttamiskelpoista tulkintaa nimenomaan sillä perusteella että ne
*pehmentävät* painetta (rauhoittava dialogi, etäännyttävä mittaristo) — siis
ristiriidassa vision kanssa, ei vain esteettisesti erilaisia. Tämä on sama kynnys jonka
D3 (kielisyys) ja D4 (elinkaarimalli) ylittävät: valinta, joka olisi voinut mennä
vision periaatteen vastaisesti jos sitä ei olisi tehty tietoisesti.
