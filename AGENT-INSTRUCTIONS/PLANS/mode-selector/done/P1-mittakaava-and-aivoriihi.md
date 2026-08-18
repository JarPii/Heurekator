## Phase P1 - Third choice (Aivoriihi) + mittakaava screen [DONE]

Implemented and browser-verified. Build instructions retired. Later phases consume
these frozen contracts:

- `frontend/index.html` - `#mode-select`'s `.mode-choices` now holds three buttons:
  `#mode-idea-btn` (enabled), `#mode-ongelma-btn` and `#mode-aivoriihi-btn` (both
  `disabled`, `title="Ei vielä toteutettu"`, each with a `.mode-choice-note`
  "(tulossa)" span) - confirmed non-interactive (no click, no tab focus, tooltip
  shown). `#mittakaava-select` (new section, `hidden` by default) sits between
  `#mode-select` and `#idea-form`, with four `.mode-choice` buttons carrying
  `data-mittakaava` values `sisainen_toiminta` / `toimitus` / `uusi_ominaisuus` /
  `uusi_ratkaisu` - these exact four strings are the frozen `Mittakaava` value set
  (also now the `app.models.Mittakaava` Literal, per P2).
- `frontend/app.js` - `state.mittakaava` (initialized `null`) holds the choice.
  `modeIdeaBtn`'s handler now routes to `#mittakaava-select` (not straight to
  `#idea-form`); a click-wiring loop on `#mittakaava-select`'s four buttons sets
  `state.mittakaava` and reveals `#idea-form`. No handler exists for
  `#mode-aivoriihi-btn` - `disabled` in markup is its only behavior, same pattern as
  `#mode-ongelma-btn`.
- `frontend/style.css` - `#mittakaava-select` reuses P0's `.mode-select-label`/
  `.mode-choices`/`.mode-choice` classes unchanged; later phases reuse these same
  classes for any further choice screens rather than duplicating rules.
- Confirmed by browser test: full session (mode-select → Idea → mittakaava-select →
  any choice → idea submit → first question) runs with no console error; disabled
  buttons are truly non-interactive; both selector screens wrap sensibly at ~375px.
- Known carry-over: making "Ongelma"/"Aivoriihi" functional is still R4/R5's job, not
  this plan's. P2 (`../done/P2-mittakaava-aware-questions.md` once compressed) gave
  the mittakaava choice its first real consumer.
