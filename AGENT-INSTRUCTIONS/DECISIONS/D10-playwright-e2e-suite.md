# D10 — Playwright becomes a permanent E2E suite, reversing the "no test suite" gap

**Tausta.** `interrogation-ui`-suunnitelman Phase P2:n oma vaihedokumentti kielsi
nimenomaisesti automaattisen E2E-ajurin lisäämisen tämän vaiheen sivutuotteena ("Must
not introduce an automated E2E test harness as a side effect of this phase's `full`
gate"), ja `full-plan.md`:n "Carry-overs / deferred" -kohta merkitsi testisviitin koko
suunnitelman ulkopuolelle. `PROJECT.md` §3 kuvasi tämän eksplisiittisesti avoimeksi
aukoksi, "not filled in with an invented command". P2:n koodi oli kuitenkin jo
toteutettu ja commitoitu (`57976b9`, `ad7dbbe`) ennen kuin `mode-selector`-suunnitelma
(R1.5) keskeytti session, eikä vaiheen omaa move-on-gatea ("full session runs through
all 7 areas to completion") oltu koskaan todennettu loppuun asti. Käyttäjä pyysi
viemään P2:n loppuun Playwright-testein.

**Vaihtoehdot, jotka käytiin läpi keskustelussa:**

1. **Kertakäyttöinen, repoon lisäämätön Playwright-ajo.** `npx`:llä skratsihakemistosta
   ajettu kertaluontoinen skripti, joka vain todistaa P2:n move-on-gaten (koko
   7-alueen sessio läpi) kertaalleen. Ei package.json:ia, ei node_modulesia, ei
   pysyvää muutosta repoon — kumoaisi P2:n MUST NOT -säännön ja `PROJECT.md` §3:n
   "ei testisviitti" -tilan vain käytännössä, ei kirjaimellisesti.
2. **Pysyvä Playwright-testisviitti repoon.** `package.json` + `@playwright/test`
   devDependencynä, oma `e2e/`-hakemisto, testit ajettavissa toistuvasti myöhemminkin.
   Kumoaa sekä P2:n MUST NOT -säännön että `PROJECT.md` §3:n kirjatun aukon pysyvästi.

**Valinta ja syy.** Käyttäjä valitsi vaihtoehdon 2 eksplisiittisesti, kun molemmat
vaihtoehdot ja niiden seuraukset esitettiin (repo saa ensimmäistä kertaa
Node/npm-riippuvuuden Python-backendin ja buildlessin frontendin rinnalle; testit
tekevät oikeita LLM-kutsuja koska sovelluksessa ei ole mock-tilaa, joten ajo on hidas
ja kuluttaa oikeaa API-kiintiötä). Peruste: pysyvä sviitti antaa regressiosuojan myös
tuleville vaiheille (esim. `interrogation-ui` P3, tulevat `ROADMAP.md`-vaiheet) sen
sijaan että sama manuaalinen 7-alueen läpikäynti pitäisi tehdä käsin joka kerta
uudelleen — tämä on nimenomaan se aukko jonka `PROJECT.md` §3 kirjasi mutta jonka
täyttämistä "ei haluttu keksiä" ilman käyttäjän omaa päätöstä.

**Vaikutus projektiin.**
- `PROJECT.md` §2:n layout-taulukkoon lisätään `e2e/`.
- `PROJECT.md` §3:n "Gap: no automated test suite exists" -kappale korvataan
  Playwright-asennus-/ajokomennoilla; taustaehto (oikeat LLM-kutsut, ei mock-tilaa)
  säilyy samana kuin ennenkin, nyt vain automaation kautta.
- `WORKFLOWS/MAP.md`:n "Idea runs through the Socratic loop" -työnkulku osoittaa
  jatkossa oikeaan spec-tiedostoon (`e2e/tests/socratic-loop.spec.js`) reittikäsittelijöiden
  sijaan.
- `interrogation-ui/phases/P2-interrogation-chat-screen.md`:n oma "Must not introduce
  an automated E2E test harness" -sääntö on tämän päätöksen myötä vanhentunut sille
  yksittäiselle vaiheelle; `done/P2-interrogation-chat-screen.md` mainitsee tämän
  eksplisiittisesti kumoamisena, ei hiljaisena ohituksena.

**Ei muuta:** `PROJECT.md` §4:n invariantit (autentikointi, avainten käsittely,
sessiotallennus, LLM-tulosten luotettu käyttö) — testisviitti ajaa sovellusta täysin
olemassa olevien rajapintojen läpi, ei lisää eikä poista mitään niistä.
