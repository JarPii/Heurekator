# D7 — Tilan valintanäyttö ennen idean syöttöä (Ongelma / Idea)

**Tausta.** Käyttäjätestauksen aikana (`PLANS/interrogation-ui/phases/P2-interrogation-chat-screen.md`)
kävi ilmi, että `app/core/criteria.py`:n Area 1:n seed question — suora kopio
`Visio.md` §3.2:n omasta Ongelman määrittely -alueesta ("mitä ongelmaa idea ratkaisee,
ja onko ongelma todellinen?") — saa arviointimoottorin vaatimaan käyttäjältä todistetta
ongelman olemassaolosta ja laajuudesta (esim. "millä aineistolla osoitat että tämä
koskettaa vähintään 10 000 ihmistä") heti ensimmäisen kysymyksen kohdalla, vaikka
käyttäjä oli juuri pyydetty syöttämään *idea*, ei ongelma.

Juurisyy: sovellus pyytää käyttäjää aina syöttämään "idean" (`#idea-form`, "Kuvaa
ideasi"), ja koko seitsemän-alueinen kierros (§3, idean validointi) olettaa idea→ongelma
-yhteyden jo annetuksi ja oikeaksi. Todellinen ongelman juurisyyanalyysi (`Visio.md`
§2a) on rakenteellisesti eri prosessi — toistuva miksi-ketju, ei kiinteä
seitsemän-alueen patteristo — eikä sitä ole koodattu ollenkaan. Näitä kahta ei voi
korjata siirtämällä yhtä kysymystä, koska ne kysyvät perustavanlaatuisesti eri asiaa:
onko idea kestävä (§3) vs. onko ongelma edes todellinen (§2a).

**Vaihtoehdot, jotka käytiin läpi keskustelussa:**

1. **Korjata vain Area 1:n seed question** (poistaa "onko ongelma todellinen"
   `criteria.py`:stä ja `Visio.md` §3.2:sta) — pieni, nopea, mutta ei ratkaise
   perusongelmaa: käyttäjällä ei ole mitään tapaa aloittaa ongelman validoinnista, jos
   se on se mitä hän oikeasti haluaa tehdä.
2. **Ratkaista §2a:n kaksi avointa kysymystä (pysähtymiskriteeri, kysymyslogiikka) heti
   ja rakentaa molemmat flow't (Ongelma + Idea) kokonaan toimiviksi samalla kertaa.**
3. **Lisätä valintanäyttö (Ongelma / Idea) sovelluksen aloitusnäytöksi ennen nykyistä
   `#idea-form`:ia; "Idea" johtaa olemassa olevaan §3-validointiin sellaisenaan,
   "Ongelma" näkyy vaihtoehtona mutta on selvästi merkitty ei-vielä-toteutetuksi
   (`REPO-RULES.md` §2:n sallima, eksplisiittisesti merkitty degraded path) kunnes §2a
   on ratkaistu erikseen.**

**Valinta ja syy.** Käyttäjä valitsi vaihtoehdon 3. Vaihtoehto 1 hylättiin, koska se
korjaisi vain oireen (yksi kysymysteksti) muttei sitä, että sovellus ei tarjoa mitään
reittiä todelliseen ongelman validointiin — käyttäjä joutuisi silti aina aloittamaan
"idealla" vaikka hänellä ei vielä olisi mitään ideaa, vain ongelma. Vaihtoehto 2
hylättiin, koska §2a:n kysymyslogiikka ja pysähtymiskriteeri (`ROADMAP.md` R4:n oma
avoin kohta) vaativat oman, huolellisen suunnittelukeskustelun eikä niitä haluttu
ratkaista kiireessä tämän UI-keskustelun sivutuotteena — sama periaate kuin
`PLAN-PHASE-DETAILING.md`:n "jos et voi kirjoittaa tätä koodista, älä keksi sitä."
Vaihtoehto 3 tekee valinnan näkyväksi käyttäjälle heti, ilman että mitään keksitään:
"Idea"-haara on jo olemassa oleva, toimiva §3-prosessi; "Ongelma"-haara on rehellisesti
merkitty kesken olevaksi kunnes se oikeasti on.

**Vaikutus roadmapiin.** Uusi vaihe lisätään `ROADMAP.md`:hen nimellä **R1.5 — Tilan
valintanäyttö**, R1:n ja R2:n väliin (ei riipu kummastakaan, mutta luontevin paikka
koska se laajentaa samaa `frontend/`-työtä jota R1 juuri teki). Ei korvaa eikä muuta
R4:ää (Ongelma validointi) — R4 on yhä se, joka joskus tekee "Ongelma"-haarasta
oikeasti toimivan; tämä päätös vain lisää sille näkyvän, rehellisesti merkityn
paikan käyttöliittymään etukäteen.

**Mitä tämä ei muuta.** `Engine`n arviointilogiikka, `criteria.py`:n seitsemän aluetta,
ja koko olemassa oleva §3-prosessi pysyvät koskemattomina — "Idea"-haara on sama
prosessi kuin ennen, vain yhden valintanäytön takana. Ei muutosta `PROJECT.md` §4:n
invarianteille.
