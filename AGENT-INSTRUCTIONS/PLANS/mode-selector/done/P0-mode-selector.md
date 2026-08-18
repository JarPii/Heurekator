## Phase P0 - Mode selector screen (Idea/Ongelma) [DONE]

Implemented and verified. Build instructions retired. Later phases consume these
frozen contracts:

- `frontend/index.html` - `#mode-select` is the app's first visible screen, before
  `#idea-form` (which now carries `hidden`). Two buttons live in one
  `.mode-choices` container: `#mode-idea-btn` (enabled) and `#mode-ongelma-btn`
  (`disabled`, `title="Ei vielä toteutettu"`, carries a `.mode-choice-note`
  "(tulossa)" span) — later phases add more choices to this same container, not a
  second one.
- `frontend/app.js` - `modeSelect`/`modeIdeaBtn` element refs and one click handler
  (`modeSelect.hidden = true; ideaForm.hidden = false;`) own the "Idea" transition.
  `mode-ongelma-btn` has no handler — `disabled` in markup is its only behavior.
- `frontend/style.css` - `#mode-select`, `.mode-select-label`, `.mode-choices`,
  `.mode-choice` (+ `:hover:not(:disabled)`, `:disabled`), `.mode-choice-note` are the
  frozen token-based selector-button pattern; later phases reuse these classes rather
  than duplicating the rules.
- `#idea-form`, `#chat`, `#report` markup/CSS/JS - untouched, byte-identical to
  `interrogation-ui`'s P2 end-state.
- Known carry-over: "Ongelma" stays honestly non-functional until `ROADMAP.md` R4
  exists; D8/D9 (`../../DECISIONS/LOG.md`) extend this screen further in P1.
