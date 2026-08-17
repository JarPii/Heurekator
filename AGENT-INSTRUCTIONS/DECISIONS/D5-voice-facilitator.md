# D5 — Ääni aivoriihessä: elävä litterointi + äänifasilitaattori

**Tausta.** Käyttäjä nosti esiin konkreettisen fasilitointiongelman: aivoriihi (§2b)
tapahtuu tyypillisesti ryhmässä, ja kirjurina toimiminen samalla kun ideoidaan on
vaikeaa. Ehdotus: Heurekator poimisi puheen ja kirjoittaisi sen tekstiksi, josta
ideat sitten poimittaisiin.

**Miksi tämä on eri laatuinen kuin D1–D4.** Kaikki aiemmat päätökset kulkevat
olemassa olevan `LLMClient`-rajapinnan (`app/llm/base.py`) läpi — teksti sisään,
teksti/rakenne ulos. Puheentunnistus ja -tuottaminen ovat eri kyvykkyyslaji: audio
sisään/ulos, ei tekstiä. Kumpikaan nykyinen palveluntarjoaja (Mistral, Anthropic) ei
tarjoa tätä natiivisti — tämä tuo todennäköisesti kolmannen palveluntarjoajan.

**Kolme alipäätöstä:**

1. **Elävä litterointi, ei jälkikäteinen.** Vaihtoehtona harkittu nauhoitus +
   jälkikäteinen käsittely olisi ollut teknisesti huomattavasti kevyempi — ei
   striimattua audioyhteyttä, ei matalan viiveen vaatimusta. Käyttäjä valitsi silti
   elävän vaihtoehdon: kirjuriongelma on nimenomaan reaaliaikainen (ryhmä ideoi juuri
   nyt, ei jälkikäteen), joten ratkaisunkin pitää olla.

2. **Yksi yhdistetty transkripti, ei puhujaerottelua.** Diarisointi (kuka sanoi
   minkäkin) hylättiin — teknisesti vaativampi ja tarkkuusherkempi usean
   samanaikaisen puhujan tilanteessa, eikä aivoriihen luonteessa ole oleellista kuka
   esitti minkäkin idean, koska idea irtoaa esittäjästään joka tapauksessa kun se
   siirtyy §9.2:n keräykseen.

3. **Äänifasilitaattori, ei raportin äänilähikäynti.** Puheen *tuottamisen*
   käyttötarkoitus on nimenomaan aktiivinen fasilitointi kesken aivoriihen — Heurekator
   lukee ääneen omat provokaationsa ja jatkokysymyksensä (esim. "entä jos hinta olisi
   ilmainen?"), ei vain kuuntele. Tämä ratkaisee saman kirjuri/ruutu-ongelman
   käänteisesti: kukaan ei joudu katsomaan ruutua kesken ideoinnin lukeakseen
   työkalun kysymyksiä.

**Tunnistettu, ei ratkaistu tässä päätöksessä: tekninen paino.** Elävä,
kaksisuuntainen ääni-vuorovaikutus on kunnianhimoisin yksittäinen osa koko visiota
tähän mennessä — striimattu audioyhteys, striimausta tukeva puheentunnistuspalvelu,
jatkuva/jaksottainen ideapoiminta kasvavasta transkriptista, puheentuottamispalvelu,
ja logiikka joka päättää milloin fasilitaattori puuttuu peliin (liian usein häiritsee,
liian harvoin ei auta). Tämä päätös kirjaa *mitä* halutaan, ei *miten* se
toteutetaan — tekninen suunnittelu (mikä palveluntarjoaja, fasilitaattorin
puuttumislogiikka, tallennusmuoto) jää `PLAN-AUTHORING-SCOPING.md`:n mukaiselle
scoped-planille, joka kirjoitetaan vasta kun tämä nostetaan `Visio.md` §8:n
jonosta toteutukseen (nykyinen sijainti listalla: kohta 10, eksplisiittisesti
viimeisenä — "ei skoopata ennen kuin 8–9 ovat edes runkona olemassa").
