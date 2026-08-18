# Heurekator — Vision Document v0.7 (sisäinen käyttö)

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

Yllä oleva kaavio näyttää yhden, tyypillisen polun idean elämässä — ei koko mallia. "IDEAN ELINKAARI" ei ole oma, kertaluontoinen vaihe aivoriihen ja validoinnin välissä, vaan §9:n mukainen tilajoukko jonka *sisällä* validointi on yksi tila muiden joukossa: idea voi palata validointiin useaan kertaan, myös vuosien tauon jälkeen arkistosta nostettuna (§9.4), eikä minkään tilan välillä ole pakotettuja siirtymäsääntöjä (§9.1). Kaavio kuvaa siis validoinnin ensimmäistä kertaa, ei elinkaarta kokonaisuutena — ks. §9 täydestä mallista.

## 1.2 Etusivu ja aloitusvalinnat

*Uusi ajatus, ei vielä toteutettu.*

Sovelluksen aloitusnäyttö on etusivu (dashboard), joka kokoaa yhteen erilaisia
näkymiä — tarkka sisältö tarkentuu myöhemmin, ei vielä ratkaistu.

### Ensimmäinen valinta: mikä prosessi

Käyttäjä valitsee kolmesta lähtöpisteestä, laajentaen `DECISIONS/LOG.md` D7:n
kaksisuuntaisen valinnan (Idea/Ongelma) kolmisuuntaiseksi (ks. D8):

- **Juurisyy** — ongelman validointi (§2a)
- **Aivoriihi** — laaja ideointi jollekin teemalle (§2b); teema valitaan omasta
  valikosta, joko aiemmin validoidusta ongelmasta tai suoraan annettuna (D8) — ei
  pakkoreittiä juurisyyn kautta
- **Idean validointi** — sokraattinen paine yhdelle idealle (§3), sovelluksen
  ensimmäinen ja tähän mennessä ainoa toteutettu prosessi

Kuten D7:ssä, jokainen ei-vielä-toteutettu haara näkyy valintana mutta on selvästi
merkitty kesken olevaksi (`AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md` §2:n sallima,
eksplisiittisesti merkitty degraded path) kunnes sen taustalla oleva logiikka on
ratkaistu (§2a:n osalta R4, §2b:n osalta R5 — ks. `ROADMAP.md`).

### Toinen valinta: mittakaava

Ensimmäisen valinnan jälkeen käyttäjä luokittelee prosessin mittakaavan — aina
käyttäjän oma valinta, ei automaattinen eikä LLM:n tekemä (sama periaate kuin §9.3:n
idean tila-luokittelussa):

- **Sisäinen toiminta** — oma, tiimin, tai koko organisaation toiminnan kehittäminen
- **Toimitus** — toimitusprojektin akuutti ongelma; sisältää sekä korjaavan
  toimenpiteen (lyhyen aikavälin ratkaisu) että ehkäisevän toimenpiteen (pysyvämpi
  ratkaisu samaan juurisyyhyn) — toimitusten laadun parantamiseen tähtäävä
- **Uusi ominaisuus** — laajennus olemassa olevaan toimitukseen
- **Uusi ratkaisu** — kokonaan uusi, mahdollisesti myytävä ratkaisu, joko toimitusten
  oheen tai täysin erillisenä — innovaatioon tähtäävä

### Kolmas taso: Heurekatorin oma luokittelu

Näiden sisällä Heurekator voi tehdä omaa, tarkentuvaa luokittelua (esim. mekaaninen,
ohjelmallinen, työtapa) — ei vielä määritelty, tarkentuu myöhemmin.

### Kysymysten muotoiluperiaate

Kaikissa kolmessa prosessissa (juurisyy, aivoriihi, idean validointi) kysymykset
muotoillaan samalla periaatteella (ks. `DECISIONS/LOG.md` D9):

a) kysymyksen mittakaava perustuu edellä tehtyihin valintoihin (prosessi + mittakaava)
b) jokaista kysymystä edeltää lyhyt yhteenveto siitä, mitä on jo saatu aikaan
c) jos yhteenveto paljastaa puutteen, seuraa jatkokysymys joka kohdistuu juuri siihen
   puutteeseen

Aivoriihessä (§2b) tämä koskee ideoiden *leveyttä/kattavuutta*, ei laatua — laadun
arviointi pysyy yksinomaan idean validoinnin (§3) vastuulla.

**Ei vielä ratkaistu:** etusivun tarkka sisältö; mittakaava-luokittelun tarkat rajat
(esim. milloin "toimitus" vs. "uusi ominaisuus"); mihin tietomalliin
mittakaava-valinta tallentuu ennen kuin §9:n idea-elinkaarimalli (R3) on olemassa;
kolmannen tason luokittelun tarkka sisältö.

## 2. Ongelman kuvaus

Ideoita syntyy jatkuvasti, mutta useimmat niistä pysyvät pinnallisina ajatuksina. Tyypillinen kaava on:

> Idea → innostus → (ehkä toteutus) → pettymys

Ideaa ei altisteta riittävälle kritiikille ennen kuin resursseja on sidottu. Syy on harvoin idean laatu — useimmiten se on prosessin puute: ei ole olemassa helppoa, jäsenneltyä tapaa pakottaa ajattelua syvemmälle kuin "tuntuuko tämä hyvältä".

Sama pätee sisäisiin ideoihin yhtä lailla kuin ulkoisiin: tiimin sisällä syntyvä idea saa usein vapaakortin, koska sitä ei koskaan altisteta samalle paineelle kuin ulkopuolelle esitettyä ideaa.

## 2a. Ongelman validointi

*Uusi ajatus, ei vielä toteutettu — ks. §1.1:n kokonaiskuva.*

Idea ei ole ainoa asia jonka Heurekator voi altistaa paineelle — myös ongelma, jota idean pitäisi ratkaista, kannattaa validoida ennen kuin siihen aletaan keksiä ratkaisuja. Moni "ratkaisu" epäonnistuu koska se vastaa oireeseen, ei syyhyn: idean validointi (§3) tarkistaa onko *idea* kestävä, mutta ei kyseenalaista onko *ongelma* edes se oikea ongelma.

Menetelmä muistuttaa "kysy viisi kertaa miksi" -tekniikkaa, mutta ohjailevampana: käyttäjä esittää ongelman, ja työkalu esittää sarjan syventäviä miksi-kysymyksiä — ei mekaanisesti tasan viisi kertaa, vaan niin kauan kuin vastaus vielä paljastaa uuden, syvemmän syyn eikä vain toista pintatason oiretta. Rakenteellisesti sama moottori kuin idean validoinnissa (§3.1, §3.3: kysymys → vastaus → arviointi → sopeutus → seuraava kysymys) — mutta oma kysymyslogiikka juurisyiden etsintään, ei §3.2:n seitsemää aluetta.

Lopputulos on dokumentoitu juurisyyketju ("validoitu ongelma"), joka syötetään joko
aivoriiheen (§2b) — heti tai myöhemmin, valittuna aivoriihen teemavalikosta (§1.2) —
tai suoraan idean keräämiseen (§9.2) jos ratkaisu on jo olemassa.

**Ei vielä ratkaistu:** pysähtymiskriteeri (milloin syvyys riittää — kiinteä kierrosmäärä, arviointimoottorin oma "kestävä"-tyyppinen päätös, vai käyttäjän oma valinta?); tarkka kysymyslogiikka; miten "validoitu ongelma" tallentuu suhteessa myöhempiin ideoihin.

## 2b. Aivoriihi

*Uusi ajatus, ei vielä toteutettu — ks. §1.1:n kokonaiskuva ja §1.2:n aloitusvalinnat.*

Aivoriihi tuottaa laajan kirjon mahdollisia ratkaisuideoita jollekin teemalle — myös
hulluja. Teema valitaan aivoriihen aloitusvalikosta (§1.2): joko aiemmin validoitu
ongelma (§2a:n tulos, valittuna historiasta) tai käyttäjän suoraan antama teema, ilman
että sille on tehty juurisyyanalyysiä (ks. `DECISIONS/LOG.md` D8). Kumpikaan reitti ei
muuta itse aivoriihen luonnetta.

Aivoriihi pysyy vapaana idean *laadun* arvioinnista — se ei pisteytä eikä hylkää
ideoita, laatu tulee vasta myöhemmin kun jokin idea nostetaan idean validointiin (§3).
Mutta se saa saman kysymysten muotoiluperiaatteen kuin juurisyy (§2a) ja idean
validointi (§3): jokaista jatkokysymystä edeltää lyhyt yhteenveto tähän mennessä
kerätyistä ideoista, ja jos yhteenveto paljastaa selvän puutteen — esim. ideat
kattavat vain yhden näkökulman — työkalu esittää tarkoituksella leveyttä hakevan
jatkokysymyksen ("entä jos hinta olisi ilmainen?" -tyylisesti) sen sijaan että vain
odottaisi lisää (ks. `DECISIONS/LOG.md` D9). Jos aivoriihi arvioisi ideoiden *laatua*
heti syntyessään, se tukahduttaisi juuri sen mitä aivoriihen pitäisi tuottaa — mutta
leveyden hakeminen ei ole laadun arviointia.

LLM tuottaa ehdotuksia valittua teemaa vasten; käyttäjä voi pyytää lisää, ohjata
suuntaa, tai poimia suoraan. Jokainen aivoriihen tuottama tai sieltä poimittu idea
päätyy §9.2:n mukaisesti kerätyksi — kevyesti, ilman arviointia — ja etenee siitä
eteenpäin kuten mikä tahansa muukin kerätty idea.

**Ei vielä ratkaistu:** montako ideaa yhdellä kierroksella; voiko käyttäjä lisätä omia
ideoita saman aivoriihi-session sisällä ilman LLM:ää; säilyykö koko aivoriihi-sessio
yhtenä tallenteena vai vain sen tuottamat yksittäiset kerätyt ideat; mikä täsmälleen
lasketaan "puutteelliseksi yhteenvedoksi" aivoriihen kontekstissa (leveys/kattavuus, ei
syvyys kuten §2a:ssa/§3:ssa) — tarkka logiikka jää R5:n scopingiin.

### 2b.1 Ääni ja litterointi

*Uusi ajatus, ei vielä toteutettu.*

Aivoriihi (§2b) tapahtuu tyypillisesti ryhmässä, jossa kirjurina toimiminen samalla kun ideoidaan on vaikeaa. Heurekator kuuntelee kokoushuonetta, litteroi puheen **elävästi kesken kokouksen** (ei nauhoitus + jälkikäsittely), ja poimii litteroidusta tekstistä ideoita jatkuvasti.

- **Elävä litterointi.** Teksti syntyy kesken kokouksen, ei jälkikäteen.
- **Yksi yhdistetty transkripti, ei puhujaerottelua.** Aivoriihen luonteessa idea irtoaa esittäjästään joka tapauksessa — kuka sanoi minkäkin ei ole oleellista tässä vaiheessa.
- **Äänifasilitaattori.** Heurekator ei vain kuuntele, vaan myös puhuu: se lukee ääneen omat provokaationsa ja jatkokysymyksensä kesken ideoinnin (esim. "entä jos hinta olisi ilmainen?"), samaan tapaan kuin ihminen fasilitaattori tekisi. Kukaan ei joudu katsomaan ruutua kesken ideoinnin.

**Tekninen paino, syytä tunnistaa etukäteen.** Tämä on kunnianhimoisin yksittäinen osa koko visiota tähän mennessä. Elävä, kaksisuuntainen ääni-vuorovaikutus on eri laji kuin mikään muu Heurekatorin osa: se vaatii striimatun audioyhteyden (ei pyyntö-vastaus-mallia kuten loput sovelluksesta), puheentunnistuspalvelun joka tukee striimausta, jatkuvan tai jaksottaisen ideapoiminnan kasvavasta transkriptista, puheentuottamispalvelun, ja logiikan joka päättää *milloin* fasilitaattori puuttuu peliin ääneen — liian usein häiritsee, liian harvoin ei auta. Tämä ei kulje minkään olemassa olevan `LLMClient`-toteutuksen (`app/llm/base.py`) kautta — puhe sisään/ulos on eri kyvykkyyslaji kuin teksti sisään/ulos, ja todennäköisesti vaatii kolmannen palveluntarjoajan Mistralin/Anthropicin rinnalle.

**Ei vielä ratkaistu:** milloin/kuinka usein fasilitaattori puhuu (kiinteä väli, hiljaisuuden tunnistus, vai LLM:n oma harkinta); mikä puheentunnistus-/puheentuottamispalvelu; miten litteroitu, ideapoiminnalla käsitelty aineisto tallentuu suhteessa kerättyihin ideoihin (§9.2). Ks. `AGENT-INSTRUCTIONS/DECISIONS/LOG.md` D5 kolmesta jo tehdystä alipäätöksestä (elävä vs. jälkikäteinen, yhdistetty transkripti vs. puhujaerottelu, äänifasilitaattorin käyttötarkoitus).

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

*Tämä lista kertoo mitä; toteutusjärjestyksen, riippuvuudet ja kunkin kohdan
nykytilan kertoo `ROADMAP.md` (repon juuressa) — päivitetään useammin kuin tätä
dokumenttia, joten se on ajantasaisempi lähde järjestykselle kuin numerointi alla.*

1. **Prototyyppi** — suppea kysymyspatteristo ja yksinkertainen arviointilogiikka, käytettävissä yhdellä idealla kerrallaan
2. **Oma käyttö** — aja 2–3 omaa tai tiimin ideaa läpi prosessista, arvioi muuttuiko käsitys
3. **Arviointikriteerien kalibrointi** — hio kriteerejä oman käytön kokemuksen perusteella
4. **Lopputuloksen muotoilu** — vakiinnuta konseptidokumentin rakenne omaan käyttöön sopivaksi
5. **Nelikielisyys** — kysymykset, vastaukset ja käyttöliittymä suomeksi, englanniksi, ranskaksi ja puolaksi; raportit aina englanniksi (§3.5)
6. **Idean elinkaarimalli** — kerätyistä ideoista listaus jossa näkyy tila (kerätty/sivuun/validoinnissa/jatkossa/arkistossa), ks. §9 — pääsy takaisin vanhoihin ideoihin ilman että session-tunnus pitää muistaa on tämän osa, ei erillinen ominaisuus
7. **Vektorointi/semanttinen haku** — kun ideamäärä kasvaa riittävän suureksi; aina englanninkielisiin raportteihin, ei alkuperäiskielisiin keskusteluihin (§3.5); ei vielä ajankohtainen — lykkäyksen perustelu on kirjattu `AGENT-INSTRUCTIONS/DECISIONS/LOG.md` D2:een (rivin `Status` on `superseded by D4`, mutta vain sessiolistaus-osaltaan — vektorihaku-lykkäys itsessään ei ole korvattu, ks. D2:n ja D4:n narratiivit)
8. **Ongelman validointi** — juurisyy-analyysi ennen ideointia, sama moottori eri kysymyslogiikalla (§2a) — tuorein ajatus, vaatii vielä muotoilua ennen skoopattavaa suunnitelmaa
9. **Aivoriihi** — laaja, paineeton ideointi validoitua ongelmaa vasten, syöttää tuotokset suoraan keräykseen (§2b, §9.2) — tuorein ajatus, riippuu 8:sta
10. **Ääni ja litterointi** — elävä puheentunnistus + äänifasilitaattori aivoriiheen (§2b.1) — kunnianhimoisin ja teknisesti raskain osa visiota, oma kolmas palveluntarjoajariippuvuus; ei skoopata ennen kuin 8–9 ovat edes runkona olemassa

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

*Heurekator — Vision Document v0.7 (sisäinen käyttö)*
*Luonnos perustuen visiokeskusteluun, elokuu 2026.*
*Nimi: Heurekator / Heurekaattori*
*Tagline: The machine that forces eureka moments.*
