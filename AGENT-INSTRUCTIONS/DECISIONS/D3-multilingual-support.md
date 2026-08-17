# D3 — Nelikielisyys: valinta, kuori, raportin kieli

**Tausta.** Käyttäjä halusi että keskustelut säilyvät talteen alkuperäisellä kielellä,
mutta yhteenvedot ja loppuraportit tuotetaan englanniksi — ja että kun vektorointi
joskus toteutetaan (D2), se tehdään aina englanninkieliseen raporttiin, jotta haku
pysyy yhtenäisenä riippumatta idean alkuperäiskielestä. Alkuperäiset käyttökielet:
suomi, englanti, ranska, puola.

Tämä on vision laajennus, ei vain tekninen yksityiskohta — `Visio.md` ei tähän asti
maininnut kieltä lainkaan (kirjoitettu implisiittisesti suomeksi suomenkieliselle
käyttäjälle). Muutos kirjattu `Visio.md` §3.5:een ja seuraaviin askeliin (§8).

**Kolme erillistä alipäätöstä, jotka käytiin läpi ennen kirjaamista:**

1. **Kielen valinta.** Pudotusvalikko idean syöttövaiheessa, ei automaattinen
   tunnistus. Automaattinen tunnistus idean tekstistä olisi altis virheille lyhyellä
   tai sekakielisellä syötteellä, eikä anna LLM:lle yhtä yksiselitteistä signaalia
   kuin eksplisiittinen valinta.

2. **Käyttöliittymän kuori.** Käännetään kaikille neljälle kielelle heti, ei
   lykätä myöhempään vaiheeseen. Vaihtoehto (kysymykset+raportti kielellä, mutta
   painikkeet/otsikot pysyvät suomeksi) olisi ollut pienempi ensimmäinen askel, mutta
   tuntuisi keskeneräiseltä ranskan- tai puolankieliselle käyttäjälle — puolet
   kokemuksesta olisi hänen omalla kielellään, puolet ei.

3. **Raportin kääntäminen englanniksi.** Erillinen käännösvaihe raportin
   generoinnin jälkeen, ei suora "kirjoita englanniksi" -ohjeistus
   raportti-promptin SYSTEM-viestissä. Suora ohjeistus olisi kevyempi (ei uutta
   LLM-kutsua), mutta erillinen vaihe antaa enemmän kontrollia — käännöksen laatua
   voi tarkistaa/validoida erikseen, ja käännösaskel on oma, testattava, uudelleen
   ajettava yksikkönsä jos jokin menee pieleen.

**Mitä tämä ei vielä ratkaise.** Tarkka tekninen toteutus (miten `app/core/criteria.py`,
`app/prompts/*.py` ja `frontend/`:n kiinteät merkkijonot parametrisoidaan kielen
mukaan; mihin käännösvaihe koodissa asettuu; käännetäänkö `Area.label`/`seed_question`
neljälle kielelle manuaalisesti vai generoidaanko ne) on vielä auki — se ratkaistaan
scoped-planin ja sen detailoinnin yhteydessä (`PLAN-AUTHORING-SCOPING.md`,
`PLAN-PHASE-DETAILING.md`), ei tässä päätöksessä.

**Suhde D2:een.** Tämä päätös ei muuta D2:ta (Postgres+pgvector pysyy lykättynä) —
se ainoastaan kirjaa etukäteen mille kielelle tuleva vektorointi kohdistuu, kun D2:n
myöhempi vaihe joskus käynnistyy.
