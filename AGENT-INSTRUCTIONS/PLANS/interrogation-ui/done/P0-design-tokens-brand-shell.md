## Phase P0 — Design tokens + brand shell (done)

**Delivered:** a single dark-only design-token set and a reusable logo masthead. No
screen content (`#idea-form`, `#chat`, `#report`) was restyled.

**Contract for P1-P3:**
- All color/typography tokens are defined exactly once, in `frontend/style.css`'s
  `:root` block. Names: `--ground`, `--surface`, `--surface-2`, `--line`, `--paper`,
  `--paper-dim`, `--ink-gold`, `--ink-green`, `--ink-rust`, `--font-mono`,
  `--font-serif`, plus `color-scheme: dark`. Read `frontend/style.css` for exact values
  — do not restate them from memory or redefine a token under a new name.
- Later phases reuse these tokens by name. No per-screen ad hoc color values
  (`full-plan.md` design rule 5).
- `body`'s `max-width: 640px` and the light-dark()-based rules for `.message`, `pre`,
  `.area-card`, `.verdict-pill`, `.risk-item`, `.priority-*`, etc. were left untouched —
  they still resolve to their dark branch (since `color-scheme: dark` now applies
  globally) but are not yet expressed in the new token set. Restyling them is P1-P3's
  job, not a P0 leftover to fix.
- The `.masthead` / `.lockup` pattern (centered header, bottom border in `var(--line)`,
  responsive logo image capped at `24rem`) is established in `frontend/style.css` and
  `frontend/index.html` and may be reused, not redefined, by later screens that need a
  similar bordered-section shell.
- Brand asset lives at `frontend/assets/heurekator-lockup.png`, served by the existing
  `StaticFiles` mount at `/assets/heurekator-lockup.png`. Treat it as a fixed input —
  never regenerate/crop/resize it in a later phase.

**User-verified** (2026-08-17): dark navy background renders correctly; logo shows no
seam against the page background; idea-submission flow (textarea → "Aloita" → question
appears) still works; no devtools console errors; logo scales responsively at ~375px
width with no overflow.

**Commit:** `4f651df`.
