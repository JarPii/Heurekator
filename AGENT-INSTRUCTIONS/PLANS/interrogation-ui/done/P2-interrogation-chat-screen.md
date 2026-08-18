## Phase P2 — Interrogation (chat) screen (done)

**Delivered:** `#chat` restyled to the Kuulustelupöytäkirja direction (D1) — per-question
gold monospace area-stamp label (`ALUE nn/07 — <AREA>`), monospace question / serif
answer text, a live tilted per-turn verdict stamp (green for `kestävä`, rust for the
other four verdicts), and a continuous page-flowing transcript (`#messages` lost its
`max-height`/`overflow-y` crop; each turn calls `scrollIntoView`). `#answer-form`'s
textarea/button reuse P1's exact `#idea-form` pattern, scoped under `#answer-form`'s own
ids. D6: `Engine.submit_answer` now returns a 4-tuple including `evaluation.verdict`;
`POST /api/sessions/{id}/answer`'s non-`done` response gained one field, `verdict`
(the verdict of the answer just judged) — no other field changed shape.

**Contract for P3+:**
- `POST /api/sessions/{id}/answer` non-`done` response: `{done: false, question,
  area_index, verdict}` — `verdict` is the raw `Verdict` string (`README.md`'s API
  section is the source of truth for the exact shape).
- `frontend/app.js`: `AREA_LABELS` (7 entries, byte-matching `app/core/criteria.py`'s
  `AREAS` order/labels), `formatAreaLabel`, `stampVerdict`, and `addMessage(role, text,
  areaIndex)` (returns the created element; call `scrollIntoView` yourself if a caller
  needs it in view).
- `frontend/style.css`: `.area-label`, `.message.assistant .message-text`,
  `.message.user .message-text`, `.verdict-stamp` (+ the four-verdict rust variant) —
  distinct from `.verdict-pill`, which stays `#report`-only (P3's territory).
- `.verdict-pill` and all `#report`-scoped rules, and `#idea-form`'s markup/CSS, are
  untouched — byte-identical to their pre-P2 state.

**Superseded rule:** this phase document's own "Must not introduce an automated E2E
test harness as a side effect of this phase's `full` gate" is reversed by
`../../../DECISIONS/D10-playwright-e2e-suite.md` — a permanent Playwright suite
(`e2e/`) now exists in this repo, added explicitly (not as a side effect) to close this
phase out. `e2e/tests/socratic-loop.spec.js` is this phase's automated proof of its own
move-on gate.

**User-verified** (2026-08-17, styling/interaction) **+ automated** (2026-08-18,
`e2e/tests/socratic-loop.spec.js`, D10): area stamp, verdict stamp, transcript flow,
and `#answer-form` styling confirmed in the browser; a full session through all 7
areas to the report screen, with no console/page errors, is now proven by the E2E
spec on every run rather than only checked once by hand.

**Commits:** `57976b9`, `ad7dbbe` (implementation); E2E closure + D10 committed
separately this session.
