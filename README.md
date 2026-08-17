# Heurekator (MVP)

Sisäinen työkalu ideoiden sokraattiseen seulontaan. Ks. [Visio.md](Visio.md) (mitä
tehdään) ja [ROADMAP.md](ROADMAP.md) (missä järjestyksessä).

## Arkkitehtuuri

```
frontend/          paikallinen web-chat (staattinen HTML/JS, ei build-vaihetta)
app/main.py         FastAPI-reitit
app/core/engine.py   orkestrointi: kysymys → vastaus → arviointi → sopeutus → seuraava kysymys
app/core/criteria.py osa-alueet ja arviointikriteerit (tunable ilman muuta koodia)
app/core/store.py    tallennusabstraktio (JSONFileStore oletuksena)
app/llm/              LLMClient-abstraktio + Mistral-/Anthropic-toteutukset (factory.py valitsee LLM_PROVIDER:in mukaan)
app/prompts/           kysymys-, arviointi- ja raporttiprompteja moduuleittain
app/models.py          pydantic-skeemat (Session, Evaluation, Report, ...)
data/sessions/         per-sessio JSON-tiedostot
```

Laajennuskohdat on tarkoituksella eristetty rajapintojen taakse:

- **Palveluntarjoajan vaihto**: `LLM_PROVIDER=mistral|anthropic` .env:ssä, ks. `app/llm/factory.py`. Uuden tarjoajan lisäys = uusi `LLMClient`-toteutus samaan hakemistoon.
- **Toinen malli arvioimaan** (vision §5): oma `LLMClient`-instanssi evaluointikutsuja varten, kysyjä ja arvioija voivat olla myös eri tarjoajilta.
- **Tallennuksen vaihto tietokantaan**: toteuta uusi `SessionStore`, `Engine` ei muutu.
- **Kriteeristön kalibrointi**: muokkaa `app/core/criteria.py`, ei tarvetta koskea moottoriin tai portteihin.

## Käyttöönotto

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# muokkaa .env: MISTRAL_API_KEY=... (tai LLM_PROVIDER=anthropic + ANTHROPIC_API_KEY=...)

uvicorn app.main:app --reload
```

Avaa selaimessa `http://localhost:8000`. Jos portti 8000 on jo varattu (esim. VS Codella), käynnistä eri portilla: `uvicorn app.main:app --reload --port 8001`.

## API

- `POST /api/sessions` `{idea}` → `{session_id, question}`
- `POST /api/sessions/{id}/answer` `{answer}` → `{done: false, question}` tai `{done: true, report}`
- `GET /api/sessions/{id}` → koko session tila (debuggaukseen)
