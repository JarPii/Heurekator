# D9 — Kysymysten muotoiluperiaate koskee kaikkia kolmea prosessia, myös aivoriihtä

**Tausta.** Käyttäjä kuvasi yhteisen kysymysten muotoiluperiaatteen kolmelle
etusivun (`Visio.md` §1.2) prosessille: a) kysymyksen mittakaava perustuu aiempiin
valintoihin, b) kysymystä edeltää aina lyhyt yhteenveto tähänastisesta, c)
puutteellinen yhteenveto laukaisee jatkokysymyksen. Agentti kysyi eksplisiittisesti
sovelletaanko tätä myös aivoriiheen (§2b), koska `Visio.md` §2b:n silloinen teksti
kuvasi aivoriihen olevan tietoisesti täysin paineeton: "ei arviointia, ei sopeutuvaa
haastamista, ei painetta" — ja periaatteen b/c-kohdat muistuttavat rakenteeltaan
juuri sopeutuvaa haastamista.

**Vaihtoehdot, jotka käytiin läpi keskustelussa:**

1. **Periaate koskee vain juurisyytä (§2a) ja idean validointia (§3).** Aivoriihi
   säilyy täysin koskemattomana, alkuperäisen paineettoman kuvauksen mukaisena —
   pelkkä vapaa ideointi ilman yhteenveto/tarkennus-rakennetta.
2. **Periaate koskee kaikkia kolmea, myös aivoriihtä.** Aivoriihi saa saman
   yhteenveto-ennen-kysymystä ja puutteellinen-yhteenveto-laukaisee-jatkokysymyksen
   -rakenteen kuin muutkin, mutta sovellettuna ideoiden leveyteen/kattavuuteen — ei
   niiden laatuun.

**Valinta ja syy.** Käyttäjä valitsi vaihtoehdon 2. Peruste: johdonmukaisuus kolmen
prosessin välillä — sama kysymysten muotoilulogiikka koko työkalun läpi — painoi
enemmän kuin aivoriihen alkuperäinen, täysin paineeton kuvaus. Tämä ei kuitenkaan
tarkoita että aivoriihi menettäisi §2b:n ydinperiaatteen (ei idean *laadun*
arviointia, laatu tulee vasta §3:ssa) — vain että se saa saman rakenteellisen
kehyksen (yhteenveto → tarkennus tarvittaessa) kuin muut kaksi prosessia, kohdistuen
kattavuuteen laadun sijaan.

**Vaikutus visioon.** `Visio.md` §2b:n avausosuutta muutettiin: "ei arviointia, ei
sopeutuvaa haastamista, ei painetta" korvattiin tarkemmalla muotoilulla, joka erottaa
laadun arvioinnin (yhä poissa aivoriihestä) ja leveyden hakemisen (nyt osa
aivoriihtä, yhteenveto+tarkennus-mekanismin kautta). Uusi §1.2 kirjaa periaatteen
yhteisenä, kaikkia kolmea prosessia koskevana sääntönä.

**Vaikutus roadmapiin.** Ei uutta vaihetta — periaate on suunnitteluvaatimus jonka
R4 (§2a) ja R5 (§2b) noudattavat kun ne aikanaan scoopataan. §3 (idean validointi)
on jo koodissa; sen nykyinen sopeutumislogiikka (`Visio.md` §3.3) täyttää periaatteen
pääosin, mutta eksplisiittinen "yhteenveto ennen jokaista kysymystä" -muoto ei ole
vielä varmistettu koodista — jää huomioitavaksi jos/kun §3:n kysymysmoottoria
seuraavan kerran muokataan.

**Ei vielä ratkaistu.** Mikä täsmälleen lasketaan "puutteelliseksi yhteenvedoksi"
aivoriihen kontekstissa (esim. kuinka moni näkökulma riittää, milloin ideat ovat
"yksiulotteisia") — tämä on eri kysymys kuin §2a:n/§3:n syvyys-pohjainen
puutteellisuus, ja jää R5:n scopingiin.
