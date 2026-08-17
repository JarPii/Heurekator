# Heurekator — Vision Document v0.4 (sisäinen käyttö)

> *The machine that forces eureka moments.*

---

## 1. Visio

Heurekator on sisäinen työkalu, joka ei arvioi ideoita — se pakottaa idean kantajan arvioimaan itse. Työkalu kuljettaa käyttäjän strukturoidun, sokraattisen prosessin läpi, jossa jokainen vastaus arvioidaan, jokainen oletus haastetaan ja jokainen ristiriita tuodaan esiin. Lopputulos ei ole pelkkä arvio, vaan joko aiempaa syvällisempi, viestittämiskelpoinen konsepti — tai perusteltu hylkäys.

Tässä vaiheessa työkalu on tarkoitettu omaan ja oman organisaation käyttöön: ideoiden seulontaan ennen kuin niihin sidotaan aikaa tai resursseja. Ei tuotetta, ei markkinaa — vain väline parempaan ajatteluun.

## 2. Ongelman kuvaus

Ideoita syntyy jatkuvasti, mutta useimmat niistä pysyvät pinnallisina ajatuksina. Tyypillinen kaava on:

> Idea → innostus → (ehkä toteutus) → pettymys

Ideaa ei altisteta riittävälle kritiikille ennen kuin resursseja on sidottu. Syy on harvoin idean laatu — useimmiten se on prosessin puute: ei ole olemassa helppoa, jäsenneltyä tapaa pakottaa ajattelua syvemmälle kuin "tuntuuko tämä hyvältä".

Sama pätee sisäisiin ideoihin yhtä lailla kuin ulkoisiin: tiimin sisällä syntyvä idea saa usein vapaakortin, koska sitä ei koskaan altisteta samalle paineelle kuin ulkopuolelle esitettyä ideaa.

## 3. Mitä työkalu tekee

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
6. **Sessiolistaus** — pääsy takaisin vanhoihin ideoihin ilman että session-tunnus pitää muistaa
7. **Vektorointi/semanttinen haku** — kun ideamäärä kasvaa riittävän suureksi; aina englanninkielisiin raportteihin, ei alkuperäiskielisiin keskusteluihin (§3.5); ei vielä ajankohtainen — ks. `AGENT-INSTRUCTIONS/DECISIONS/LOG.md` D2

---

*Heurekator — Vision Document v0.4 (sisäinen käyttö)*
*Luonnos perustuen visiokeskusteluun, elokuu 2026.*
*Nimi: Heurekator / Heurekaattori*
*Tagline: The machine that forces eureka moments.*
