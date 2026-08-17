## Phase P1 — Idea intake screen (done)

**Delivered:** `#idea-form`'s label, textarea, and "Aloita" button restyled to the
Kuulustelupöytäkirja direction (D1), reusing P0's frozen tokens only. No markup or JS
change — `frontend/index.html` and `frontend/app.js` are byte-identical to P0's
end-state.

**Contract for P2-P3:**
- `#idea-form label`, `#idea-form textarea` (+ `:focus`), `#idea-form button`
  (+ `:hover:not(:disabled)`, `:disabled`) rules exist in `frontend/style.css`, scoped
  to `#idea-form`'s own ids only — the generic `textarea {}` / `button {}` rules P0 left
  behind are untouched and still apply as the base for `#chat`'s `#answer` textarea and
  submit button.
- No new token was introduced; no existing P0 token was redefined.
- This phase established no new reusable pattern for later phases to inherit — it is a
  self-contained restyle of one section's three elements.

**User-verified** (2026-08-17): label/textarea/button match the direction; textarea
border highlights gold on focus; full idea-submission flow (textarea → "Aloita" →
first question appears) works unchanged; button dims while request is in flight; no
devtools console errors; layout stays legible and overflow-free at ~375px width.

**Commit:** `917756d`.
