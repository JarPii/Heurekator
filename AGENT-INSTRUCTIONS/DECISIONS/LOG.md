# DECISIONS/LOG.md — the compact, binding record

Read `../DECISIONS/README.md` first for the rules this file enforces. This file itself
stays short on purpose: one row per decision, machine-checkable by
`../SCRIPTS/check-decision-log.sh`. Anything that needs paragraphs goes in a narrative
file `DECISIONS/<id>-<slug>.md`, linked from the last column — never inlined here.

**Format rules (do not deviate — the checker parses this literally):**

- One markdown table, columns in this exact order: `ID | Date | Decision | Rejected | Why rejected | Status | Narrative`.
- `ID` — `D1`, `D2`, ... strictly increasing, never reused, never renumbered.
- A row exists **only** when the decision changes the vision or roadmap
  (`../BUILDING/REPO-RULES.md` §0, "Discuss, compare, decide") **and** a concrete
  alternative was rejected for it. A conclusion that only resolves the current
  discussion/task is not logged here, even if an alternative was considered — that
  covers most decisions.
- `Rejected` and `Why rejected` are never empty for a real row.
- `Status` is `active` or `superseded by D<n>`.
- **Append-only.** Once a row is committed, `Date` / `Decision` / `Rejected` /
  `Why rejected` never change. Reversing a decision adds a **new** row and, in the same
  change, flips the old row's `Status` to `superseded by D<n>` — the old row is never
  deleted or silently left `active`.

| ID | Date | Decision | Rejected | Why rejected | Status | Narrative |
|----|------|----------|----------|---------------|--------|-----------|
| D1 | 2026-08-17 | UI-suunta: "Kuulustelupöytäkirja" — tumma, pöytäkirjamainen visuaalinen kieli, leimasin-tyyliset arvioinnit | "Sokraattinen pöytäkirja" (klassinen keskitetty dialogi-layout); "Diagnostiikkalaite" (mittaristo/dashboard-tyyli) | Kaikki kolme olivat toteuttamiskelpoisia, mutta vain Kuulustelupöytäkirja ottaa Visio.md §1:n ydinsanan "pakottaa" kirjaimellisesti visuaalisena kielenä — se muut kaksi pehmentävät painetta (dialogi rauhoittaa, mittaristo kliinistyy) kun taas kuulustelu-estetiikka pitää sen näkyvänä joka näytöllä | active | [D1-ui-direction.md](D1-ui-direction.md) |
| D2 | 2026-08-17 | Säilytysstrategia: pysytään `JSONFileStore`:ssa ja lisätään kevyt sessiolistaus (ei uutta infraa); semanttinen/vektorihaku siirretään myöhempään vaiheeseen | Postgres + pgvector nyt | Yhden käyttäjän prototyyppi, ei tietokantaa, ei migraatioita, ei deploy-kohdetta tällä hetkellä (`PROJECT.md` §5-§6); embeddausputki toisi uuden LLM-kutsun ja kustannuksen ilman että nykyinen ideamäärä perustelisi sitä. `SessionStore`-abstraktio (`app/core/store.py`) tekee myöhemmästä vaihdosta halvan, joten päätöstä ei tarvitse tehdä nyt varmuuden vuoksi | active | [D2-persistence-strategy.md](D2-persistence-strategy.md) |
| D3 | 2026-08-17 | Nelikielisyys (fi/en/fr/pl, `Visio.md` §3.5): kieli valitaan pudotusvalikolla idean syöttövaiheessa; koko UI-kuori käännetään heti kaikille neljälle kielelle; loppuraportti tuotetaan erillisellä käännösvaiheella keskustelun päätyttyä | Automaattinen kielentunnistus idean tekstistä; UI-kuoren kääntämisen lykkääminen myöhempään vaiheeseen; suora "kirjoita englanniksi" -ohjeistus raportti-promptissa ilman erillistä käännösvaihetta | Automaattinen tunnistus on altis virheille lyhyellä tai sekakielisellä syötteellä, pudotusvalikko on yksiselitteinen. Osittainen kielitodiste (kysymykset valitulla kielellä mutta painikkeet suomeksi) tuntuisi keskeneräiseltä ranskan-/puolankieliselle käyttäjälle. Erillinen käännösvaihe antaa enemmän kontrollia (esim. mahdollisuus tarkistaa käännös myöhemmin) kuin promptiin upotettu ohjeistus, vaikka lisää yhden LLM-kutsun ja viiveen per sessio | active | [D3-multilingual-support.md](D3-multilingual-support.md) |

<!--
Example row (format reference only — delete this comment block once the table has
real entries; do not leave example rows inside the real table above):

| D1 | 2026-08-01 | Store sessions in Postgres, not Redis | Redis | no durable audit trail required by §4.2, and it added a second datastore to operate | active | - |
-->
