## Phase P2 - Render the new fields in the chat UI [DONE]

Implemented and verified via automated browser screenshot (Playwright, headless
Chromium) against a live P1 session's real `Report` data (2026-08-17); user reviewed
the screenshots and confirmed. Build instructions retired. Frozen contracts:

- `frontend/app.js::renderReport(report)` now renders four sections in `Visio.md` §3.4
  order: concept document, evaluation profile (`renderEvaluationProfile`), risk
  register (`renderRiskRegister`), recommendation. Later frontend work should extend
  these three functions rather than re-deriving report rendering elsewhere.
- `renderRiskRegister` groups `risk_register` by `kind` ("Riskit" before "Oletukset"),
  sorts each group by `priority` (high -> medium -> low), and wraps each group in a
  native `<details>`, open by default only when it contains a `high`-priority entry.
  This is the accepted answer to P1's "56-entry risk register" carry-over - any future
  change to that volume/grouping strategy should edit this function, not add a second
  rendering path.
- `frontend/style.css` gained `.area-card`, `.verdict-pill` (+ per-verdict modifiers),
  `.score-list`, `.weaknesses`, `.risk-group`, `.risk-item`, `.priority-badge` (+
  per-priority modifiers), `.recommendation` - all theme-aware via `light-dark()`,
  matching the file's existing convention.
- Verified: no browser console errors on load or render; both light and dark
  `prefers-color-scheme` render correctly; `escapeHtml` applied to every
  LLM-originated string (`description`, `comment`, `area_label`, weakness text).
- Known carry-over: none identified during this phase — verification was via a
  synthetic `fetch` + direct `renderReport()` call against an already-completed
  session's data (not a fresh live click-through of a full 7-area session in the
  browser), so the mid-session chat flow itself (`addMessage`, the answer form) was not
  re-exercised by this verification pass, only the report-rendering code path added by
  this phase.
