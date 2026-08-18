## Phase P2 - Mittakaava-aware question framing [DONE]

Implemented and browser-verified for the "sisäinen toiminta" case. Build instructions
retired. Later phases consume these frozen contracts:

- `app/models.py` - `Mittakaava` is the 4-value `Literal` (`sisainen_toiminta`,
  `toimitus`, `uusi_ominaisuus`, `uusi_ratkaisu`) - the canonical value set, matching
  `frontend/index.html`'s `data-mittakaava` attributes exactly. `Session.mittakaava`
  is a required field (no default) - any code constructing a `Session` must supply it.
- `app/core/criteria.py` - `MITTAKAAVA_FRAMING: dict[Mittakaava, str]` holds one
  prompt-context sentence per mittakaava value - the location for tuning this framing
  without touching `engine.py`, same pattern as `AREAS`/`EVALUATION_CRITERIA`.
- `app/prompts/question.py::build_question_prompt` now requires a `mittakaava`
  argument and always includes `MITTAKAAVA_FRAMING[mittakaava]` in the LLM context.
  Any future caller must supply it - there is no default/optional path.
- `app/core/engine.py::Engine.start_session` now requires `mittakaava`; it is stored
  on the `Session` and `_ask_next_question` reads `session.mittakaava` - no other
  method signature changed.
- `app/main.py::StartRequest` now requires `mittakaava` - `POST /api/sessions`'s
  request contract is `{idea, mittakaava}`, documented in `README.md`.
- `frontend/app.js` - the `POST /api/sessions` call always sends
  `mittakaava: state.mittakaava` (set during the P1 mittakaava-select screen).
- **Verified:** "sisäinen toiminta" produces an Area 1 question about internal
  cost/inefficiency, with no national/global market-size framing (the bug that
  motivated this phase).
- **Not independently re-verified:** the "uusi ratkaisu" contrast case (P2's own User
  test step 3, meant to prove the framing *shifts* rather than just drops
  market-size language). The `MITTAKAAVA_FRAMING` mechanism is symmetric and
  code-reviewed for all four values, but only one of the four was seen live. If a
  future session touches question framing and finds "uusi ratkaisu" behaving
  oddly, this is the first place to check.
- **Explicit accepted breaking change (carried from the phase doc):** the 11
  pre-existing `data/sessions/*.json` files from earlier manual testing lack
  `mittakaava` and will fail `Session.model_validate_json` if ever reloaded - treated
  as disposable local runtime state, not a migration concern.
- **Additional UI polish bundled into this phase's frontend touch**, in response to
  live testing feedback, not originally scoped by this phase but landed in the same
  session: a loading indicator (`startBtn`/answer-submit button text swaps to
  "Aloitetaan…"/"Arvioidaan…" while a request is in flight), equal-width
  `.mode-choice` buttons (`flex: 1 1 0` + `min-width: 10.5rem`), the app's reading
  column widened from 640px to 900px (`body`'s `max-width`), a `#case-heading`
  showing the original idea/problem text at the top of `#chat`, and a manual
  cache-busting query string on `style.css` (now `?v=4`) after the browser was found
  to be serving a stale cached copy twice in a row. None of these touch `app/`.
