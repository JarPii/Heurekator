# Heurekator — Vision Document v0.6 (sisäinen käyttö)

> *The machine that forces eureka moments.*

---

## 1. Visio

Heurekator on sisäinen työkalu, joka ei arvioi ideoita — se pakottaa idean kantajan arvioimaan itse. Työkalu kuljettaa käyttäjän strukturoidun, sokraattisen prosessin läpi, jossa jokainen vastaus arvioidaan, jokainen oletus haastetaan ja jokainen ristiriita tuodaan esiin. Lopputulos ei ole pelkkä arvio, vaan joko aiempaa syvällisempi, viestittämiskelpoinen konsepti — tai perusteltu hylkäys.

Tässä vaiheessa työkalu on tarkoitettu omaan ja oman organisaation käyttöön: ideoiden seulontaan ennen kuin niihin sidotaan aikaa tai resursseja. Ei tuotetta, ei markkinaa — vain väline parempaan ajatteluun.

Sokraattinen validointi (§3) on yksi vaihe idean elinkaaressa, ei ainoa asia mitä Heurekatorissa voi tehdä idealle — ks. §9.

### 1.1 Kokonaiskuva: prosessin vaiheet

Tämä dokumentti on kirjoitettu parin tunnin sisällä ja kasvaa yhä — kokonaiskuva hahmottuu keskustelun myötä, ei valmiina. Kaikkia alla kuvattuja vaiheita ei ole vielä toteutettu koodissa; tämä on visio siitä miten palaset sopivat yhteen, ei tilannekatsaus toteutuksesta (ks. `AGENT-INSTRUCTIONS/PROJECT.md` toteutuksen nykytilaa varten).

```
ONGELMA (käyttäjän syöttämä)
  │
  ▼
┌─────────────────────────────────────────────┐
│ ONGELMAN VALIDOINTI — juurisyyt (§2a)        │  ← PAINE PÄÄLLÄ
│ ohjailtu "miksi" -ketju samalla moottorilla  │
│ kuin idean validointi, eri kysymyspatteristo │
└─────────────────────────────────────────────┘
  │  validoitu ongelma
  ▼
┌─────────────────────────────────────────────┐
│ AIVORIIHI — laaja ideointi (§2b)             │  ← PAINE POIS, tietoinen poikkeus
│ useita, myös hulluja ratkaisuehdotuksia      │
│ validoitua ongelmaa vasten, ei arviointia    │
└─────────────────────────────────────────────┘
  │  yksi tai useampi idea (tai idea suoraan käyttäjältä, ilman ongelman validointia)
  ▼
┌─────────────────────────────────────────────┐
│ IDEAN ELINKAARI (§9)                         │
│ Kerätty → Luokittelu → Sivuun / Arkistoon /  │
│           Validointiin → Jatkoon             │
└─────────────────────────────────────────────┘
  │  luokiteltu validointiin
  ▼
┌─────────────────────────────────────────────┐
│ IDEAN VALIDOINTI — sokraattinen paine (§3)   │  ← PAINE PÄÄLLÄ
└─────────────────────────────────────────────┘
  │
  ▼
RAPORTTI: konseptidokumentti, arviointiprofiili,
riskirekisteri, suositus (§3.4)
```

Paine (§1:n "pakottaa") on tarkoituksella vain kahdessa suppenemispisteessä — juurisyyn löytäminen ja idean validointi — ei koko matkan ajan. Aivoriihi (§2b) on tietoinen, rajattu poikkeus: siellä paine on pois päältä, koska laaja ideointi tarvitsee tilaa jota välitön arviointi tukahduttaisi.

## 2. Ongelman kuvaus

Ideoita syntyy jatkuvasti, mutta useimmat niistä pysyvät pinnallisina ajatuksina. Tyypillinen kaava on:

> Idea → innostus → (ehkä toteutus) → pettymys

Ideaa ei altisteta riittävälle kritiikille ennen kuin resursseja on sidottu. Syy on harvoin idean laatu — useimmiten se on prosessin puute: ei ole olemassa helppoa, jäsenneltyä tapaa pakottaa ajattelua syvemmälle kuin "tuntuuko tämä hyvältä".

Sama pätee sisäisiin ideoihin yhtä lailla kuin ulkoisiin: tiimin sisällä syntyvä idea saa usein vapaakortin, koska sitä ei koskaan altisteta samalle paineelle kuin ulkopuolelle esitettyä ideaa.

## 2a. Ongelman validointi

*Uusi ajatus, ei vielä toteutettu — ks. §1.1:n kokonaiskuva.*

Idea ei ole ainoa asia jonka Heurekator voi altistaa paineelle — myös ongelma, jota idean pitäisi ratkaista, kannattaa validoida ennen kuin siihen aletaan keksiä ratkaisuja. Moni "ratkaisu" epäonnistuu koska se vastaa oireeseen, ei syyhyn: idean validointi (§3) tarkistaa onko *idea* kestävä, mutta ei kyseenalaista onko *ongelma* edes se oikea ongelma.

Menetelmä muistuttaa "kysy viisi kertaa miksi" -tekniikkaa, mutta ohjailevampana: käyttäjä esittää ongelman, ja työkalu esittää sarjan syventäviä miksi-kysymyksiä — ei mekaanisesti tasan viisi kertaa, vaan niin kauan kuin vastaus vielä paljastaa uuden, syvemmän syyn eikä vain toista pintatason oiretta. Rakenteellisesti sama moottori kuin idean validoinnissa (§3.1, §3.3: kysymys → vastaus → arviointi → sopeutus → seuraava kysymys) — mutta oma kysymyslogiikka juurisyiden etsintään, ei §3.2:n seitsemää aluetta.

Lopputulos on dokumentoitu juurisyyketju ("validoitu ongelma"), joka syötetään joko aivoriiheen (§2b) tai suoraan idean keräämiseen (§9.2) jos ratkaisu on jo olemassa.

**Ei vielä ratkaistu:** pysähtymiskriteeri (milloin syvyys riittää — kiinteä kierrosmäärä, arviointimoottorin oma "kestävä"-tyyppinen päätös, vai käyttäjän oma valinta?); tarkka kysymyslogiikka; miten "validoitu ongelma" tallentuu suhteessa myöhempiin ideoihin.

## 2b. Aivoriihi

*Uusi ajatus, ei vielä toteutettu — ks. §1.1:n kokonaiskuva.*

Kun ongelma on validoitu (§2a), aivoriihi tuottaa laajan kirjon mahdollisia ratkaisuideoita sille — myös hulluja. Tämä on tietoisesti Heurekatorin muun luonteen vastakohta: ei arviointia, ei sopeutuvaa haastamista, ei painetta. Tavoite on määrä ja moninaisuus, ei laatu — laatu tulee myöhemmin, kun jokin näistä ideoista nostetaan idean validointiin (§3). Jos aivoriihi arvioisi ideat heti syntyessään, se tukahduttaisi juuri sen mitä aivoriihen pitäisi tuottaa.

LLM tuottaa ehdotuksia validoitua ongelmaa (§2a) vasten; käyttäjä voi pyytää lisää, ohjata suuntaa, tai poimia suoraan. Jokainen aivoriihen tuottama tai sieltä poimittu idea päätyy §9.2:n mukaisesti kerätyksi — kevyesti, ilman arviointia — ja etenee siitä eteenpäin kuten mikä tahansa muukin kerätty idea.

**Ei vielä ratkaistu:** montako ideaa yhdellä kierroksella; voiko käyttäjä lisätä omia ideoita saman aivoriihi-session sisällä ilman LLM:ää; säilyykö koko aivoriihi-sessio yhtenä tallenteena vai vain sen tuottamat yksittäiset kerätyt ideat.

## 3. Idean validointi

Tämä on Heurekatorin ensimmäisenä rakennettu ja tähän mennessä ainoa toteutettu vaihe (§1.1:n kokonaiskuvassa) — se mitä koodi tänään tekee. Ongelman validointi (§2a) ja aivoriihi (§2b) ovat samaa pakottavaa periaatetta (tai sen tietoista poikkeusta) sovellettuna muihin vaiheisiin, mutta eivät vielä koodia.

### 3.1 Prosessin rakenne

Työkalu etenee sokraattisella menetelmällä: kysymysten avulla käyttäjä johdatetaan tarkastelemaan ideaansa monelta kannalta. Prosessi ei ole staattinen kysymyslista, vaan dynaaminen polku, joka rakentuu aiempien vastausten päälle.

```
IDEA SYÖTE → KYSYMYS → VASTAUS → ARVIOINTI → SOPEUTUS → SEURAAVA KYSYMYS
                ↑                                              |
                └──────────────────────────────────────────────┘
```

### 3.2 Kysymyspatteriston ydinalueet

- **Ongelman määrittely** — mitä ongelmaa idea ratkaisee? Onko ongelma todellinen?
- **Kohderyhmä** — kenelle tästä on hyötyä sisäisesti? Kuinka spesifi tämä ryhmä on?
- **Tarpeellisuus** — miksi tätä tarvitaan nyt? Mitä tapahtuisi ilman tätä?
- **Vaihtoehdot** — miten ongelma on ratkaistavissa ilman tätä ideaa?
- **Oletukset** — mitkä oletukset idea lepää? Mitkä niistä ovat heikoimpia?
- **Kestävyys** — toimiiko tämä taloudellisesti, teknisesti, operationaalisesti oman organisaation kontekstissa?
- **Riskit** — mitkä voivat olla esteet, vastustus, epäonnistumisskenaariot?

### 3.3 Iteratiivinen arviointimoottori

Työkalun sydän on arviointisykli: jokainen käyttäjän vastaus analysoidaan reaaliajassa ja seuraava askel valitaan tuloksen perusteella.

**Arviointikriteerit:**

| Kriteeri | Mitä mitataan | Esimerkki heikosta | Esimerkki vahvasta |
|----------|--------------|--------------------|--------------------|
| Syvyys | Onko vastaus pinnallinen vai perusteltu | "Auttaa monia ihmisiä" | "50–200 hengen yritykset, 15h/viikko X-tehtäviin" |
| Konkretia | Käytetäänkö esimerkkejä, lukuja, nimettyjä ryhmiä | "Helppo käyttää" | "HR-päällikkö, joka hallitsee Exceliä mutta ei SQL:ää" |
| Johdonmukaisuus | Risteääkö vastaus aiempien kanssa | Kohderyhmä A → ongelma kohderyhmä B | Koherentti narratiivi alusta loppuun |
| Oletustietoisuus | Erottaako käyttäjä faktojen ja oletusten välillä | "Markkina kasvaa varmasti" | "Oletan kasvun — perustuu X-raporttiin, voin olla väärässä" |

**Sopeutumislogiikka:**

- Pinnallinen → "Anna konkreettinen esimerkki" / "Kuvaa tarkka tilanne"
- Ristiriitainen → "Aiemmin mainitsit X — miten tämä sopii yhteen?"
- Puuttuva näkökulma → "Emme ole vielä käsitelleet Y:tä — miten se mahtuu kuvaan?"
- Yksiulotteinen → "Mitä jos hinta kolminkertaistuisi — ketkä jäisivät pois?"
- Kestävä → "Selvä — siirrytään seuraavaan osa-alueeseen."

### 3.4 Lopputulos

Kun prosessi päättyy, käyttäjä saa:

- **Konseptidokumentin** — idea työstettynä strukturoidusti: ongelma, kohderyhmä, ratkaisu, riskit, seuraavat askeleet
- **Arviointiprofiilin** — pisteytys jokaiselta arviointikriteeriltä sekä tunnistetut heikkoudet
- **Riskirekisterin** — lista tunnistetuista oletuksista ja riskeistä, priorisoituna
- **Suosituksen** — jatka, kehitä enemmän, tai hylkää — perusteluineen

Tai vaihtoehtoisesti:

- **Perustellun hylkäyksen** — työkalu tunnistaa, milloin idea ei kestä painetta, ja kertoo miksi

### 3.5 Kielisyys

Työkalu tukee aluksi neljää käyttökieltä: **suomi, englanti, ranska, puola**. Käyttäjä valitsee kielen idean syöttövaiheessa.

- Kysymykset, vastaukset ja koko käyty keskustelu säilyvät valitulla kielellä sellaisenaan — mitään ei käännetä prosessin aikana, jotta alkuperäinen ilmaisu ei vääristy.
- Konseptidokumentti, arviointiprofiili ja loppuraportti (§3.4) tuotetaan aina **englanniksi**, riippumatta keskustelun kielestä — erillisenä käännösvaiheena keskustelun päätyttyä, ei osana itse keskustelua.
- Käyttöliittymän kiinteät tekstit (painikkeet, otsikot, virheviestit) käännetään kaikille neljälle kielelle.
- Kun ideoiden vektorointi/semanttinen haku joskus toteutetaan (§8), vektorointi tehdään aina englanninkielisiin raportteihin — ei alkuperäiskielisiin keskusteluihin. Tämä pitää haun keskinäisen eheyden riippumatta siitä millä kielellä yksittäinen idea alun perin käytiin läpi.

## 4. Ero suoraan LLM-käyttöön

| Suora LLM-käyttö | Heurekator |
|------------------|------------|
| Käyttäjä kontrolloi kysymyksiä | Työkalu kontrolloi ja sopeuttaa kysymykset |
| LLM vastaa käyttäjän kysymyksiin | LLM kysyy ja arvioi käyttäjän vastauksia |
| Ei rakenteellista etenemistä | Algoritminen, vaiheittainen prosessi |
| Lopputulos riippuu promptin laadusta | Johdonmukainen riippumatta käyttäjän taidoista |
| Käyttäjä voi ohittaa epämiellyttävät kysymykset | Prosessi pakottaa kohtaamaan heikkoudet |

## 5. Tekninen lähestymistapa

**Arkkitehtuurin pääkomponentit:**

1. **Kysymysmoottori** — tuottaa seuraavan kysymyksen kontekstin, arvioinnin ja prosessin tilan perusteella
2. **Arviointimoottori** — analysoi vastauksen laadun määritellyillä kriteereillä
3. **Tilan hallinta** — ylläpitää koko keskusteluhistoriaa, tunnistetut oletukset ja ristiriidat
4. **Raporttigeneraattori** — kokoaa lopputuloksen konseptidokumentiksi ja arviointiprofiiliksi

**Teknologiset huomiot:**

- Arvioinnin luotettavuus — LLM:n oma arvio voi olla itseviitteistä; harkitse sääntöpohjaisten tarkistusten yhdistämistä
- Käyttäjäkokemus — tasapaino syvyyden ja sujuvuuden välillä
- Kahden mallin lähestymistapa (yksi kysyy, toinen arvioi) on mahdollinen jatkokehitysaskel, mutta ei tarpeen ensimmäisessä versiossa

## 6. Käyttö omassa organisaatiossa

Ensimmäinen versio on tarkoitettu:

- **Omaan käyttöön** — omien ideoiden seulontaan ennen niihin tarttumista
- **Oman tiimin/organisaation sisäiseen käyttöön** — uusien ideoiden tai aloitteiden käsittelyyn ennen kuin niistä tehdään päätös tai niihin varataan aikaa

Ei ulkoista käyttäjäkuntaa, ei jakelua tässä vaiheessa. Tavoite on validoida, että prosessi itsessään tuottaa parempaa ajattelua — ei rakentaa tuotetta.

## 7. Onnistumisen mittarit

- **Muuttuuko oma/käyttäjän ajatus prosessin aikana** — ydinindikaattori
- **Kuinka moni idea hylätään prosessin jälkeen** — terve hylkäys on yhtä arvokas tulos kuin jatkopäätös
- **Lopputuloksen käyttökelpoisuus** — voiko konseptidokumentin ottaa suoraan pohjaksi päätökselle tai jatkotyölle

## 8. Seuraavat askeleet

1. **Prototyyppi** — suppea kysymyspatteristo ja yksinkertainen arviointilogiikka, käytettävissä yhdellä idealla kerrallaan
2. **Oma käyttö** — aja 2–3 omaa tai tiimin ideaa läpi prosessista, arvioi muuttuiko käsitys
3. **Arviointikriteerien kalibrointi** — hio kriteerejä oman käytön kokemuksen perusteella
4. **Lopputuloksen muotoilu** — vakiinnuta konseptidokumentin rakenne omaan käyttöön sopivaksi
5. **Nelikielisyys** — kysymykset, vastaukset ja käyttöliittymä suomeksi, englanniksi, ranskaksi ja puolaksi; raportit aina englanniksi (§3.5)
6. **Idean elinkaarimalli** — kerätyistä ideoista listaus jossa näkyy tila (kerätty/sivuun/validoinnissa/jatkossa/arkistossa), ks. §9 — pääsy takaisin vanhoihin ideoihin ilman että session-tunnus pitää muistaa on tämän osa, ei erillinen ominaisuus
7. **Vektorointi/semanttinen haku** — kun ideamäärä kasvaa riittävän suureksi; aina englanninkielisiin raportteihin, ei alkuperäiskielisiin keskusteluihin (§3.5); ei vielä ajankohtainen — ks. `AGENT-INSTRUCTIONS/DECISIONS/LOG.md` D4
8. **Ongelman validointi** — juurisyy-analyysi ennen ideointia, sama moottori eri kysymyslogiikalla (§2a) — tuorein ajatus, vaatii vielä muotoilua ennen skoopattavaa suunnitelmaa
9. **Aivoriihi** — laaja, paineeton ideointi validoitua ongelmaa vasten, syöttää tuotokset suoraan keräykseen (§2b, §9.2) — tuorein ajatus, riippuu 8:sta

## 9. Idean elinkaari

Validointi (§3) on yksi vaihe idean elämässä, ei ainoa. Heurekator hallinnoi ideoita niiden koko elinkaaren ajan — keräämisestä arkistointiin.

### 9.1 Tilat

Idean tila on vapaasti asetettava, avoin lista — ei kiinteä, pakotettu tilakone eikä sallittuja siirtymiä rajoittava sääntöjoukko. Ensimmäiset tilat:

- **Kerätty** — idea talletettu sellaisenaan, ei vielä käsitelty mitenkään.
- **Sivuun** — luokiteltu, mutta jätetty odottamaan. Ei poisteta koskaan.
- **Validoinnissa** — käynnissä oleva tai valmistunut sokraattinen validointikierros (§3).
- **Jatkossa** — hyväksytty etenemään.
- **Arkistossa** — päätetty, ei enää aktiivinen, mutta säilyy pysyvästi.

Lista on avoin — uusia tiloja voi lisätä myöhemmin, samaan tapaan kuin arviointialueet (§3.2) ovat konfiguroitavissa koodissa ilman rakenteen uudelleensuunnittelua. Idea voi liikkua mistä tahansa tilasta mihin tahansa toiseen milloin tahansa; ei pakotettuja siirtymäsääntöjä.

### 9.2 Kerääminen

Kerääminen on tarkoituksella ohut: idea talletetaan sellaisenaan, ilman analyysiä ja **ilman LLM-kutsua**. Tämä erottaa sen validoinnista (§3), joka on aina raskas, kysymyksiä esittävä prosessi. Kerääminen on nopea tapa saada idea ylös ilman että se heti pakottaa vastaamaan mihinkään — paine (§1) tulee vasta kun idea siirretään validointiin.

Idea voi päätyä kerätyksi kahdella tavalla: käyttäjä syöttää sen suoraan, tai se on yksi aivoriihen (§2b) tuottamista ehdotuksista. Kumpikaan reitti ei muuta itse kerätty-tilan luonnetta — molemmat ovat yhtä kevyitä, yhtä paineettomia.

### 9.3 Luokittelu

Kerätty idea luokitellaan johonkin tilaan (9.1). Luokittelu on käyttäjän oma päätös, ei automaattinen tai LLM:n tekemä — työkalu ei arvaa mihin idea kuuluu.

### 9.4 Validointi useaan kertaan

Koska idea voi liikkua tilojen välillä vapaasti, sama idea voi käydä validoinnissa (§3) useamman kerran elinkaarensa aikana — esimerkiksi arkistoon laitettu idea nostetaan myöhemmin uudelleen esiin ja validoidaan uudestaan uusilla oletuksilla. Jokainen validointikierros säilyy omana, erillisenä tallenteenaan — mitään aiempaa validointia ei ylikirjoiteta.

### 9.5 Suhde säilytysstrategiaan

Ks. `AGENT-INSTRUCTIONS/DECISIONS/LOG.md` D4 (korvaa D2:n): idean elinkaarilistaus rakennetaan suoraan tämän mallin päälle sellaisenaan, ei erillisenä, myöhemmin laajennettavana sessiolistauksena.

---

*Heurekator — Vision Document v0.6 (sisäinen käyttö)*
*Luonnos perustuen visiokeskusteluun, elokuu 2026.*
*Nimi: Heurekator / Heurekaattori*
*Tagline: The machine that forces eureka moments.*
