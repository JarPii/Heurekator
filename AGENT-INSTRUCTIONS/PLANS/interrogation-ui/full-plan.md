# Interrogation UI Plan

> **Status:** scoped forward plan - created 2026-08-17 on branch main.
> **Scope:** replace `frontend/`'s current generic chat UI with the D1
> ("Kuulustelupöytäkirja") visual direction, combined with the Heurekator brand assets
> (`Heurekator_logo*.png`) added to the repo root this session. This is `ROADMAP.md`'s
> R1. Covers `frontend/index.html`, `frontend/app.js`, `frontend/style.css` only.
> **Out of scope:** anything in `app/` beyond the one field D6 adds to
> `submit_answer`'s response (see below); D3 (multilingual, `ROADMAP.md` R2), D4 (idea
> lifecycle, R3), or any other `ROADMAP.md` item.
> **Target:** internal-only prototype, matching `Visio.md`'s own scope (§6) — not
> production-grade.
>
> **Parts:**
> - **Part 0 - Groundwork.** Shared design tokens (palette, type, logo asset) and a page
>   masthead — no screen-specific restyling yet.
> - **Part A - Idea intake screen.** `#idea-form`.
> - **Part B - Interrogation (chat) screen.** `#chat`.
> - **Part C - Report screen.** `#report`.
>
> **How to use this plan:** the per-turn verdict stamp question below is settled (D6,
> option B) — Phase P2 now includes one small `app/` change alongside the frontend
> work. Discuss and edit phase boundaries first. When implementing, first shape the
> selected phase (outcome, boundaries, tradeoffs), then expand exactly one settled
> phase into an implementation-grade phase from current code before coding.

## Why this plan exists

D1 chose a visual direction for the frontend but nothing was built — `frontend/` is
still the original generic chat UI (grey/blue bubbles, plain form) from the initial MVP
commit. This session also added four brand PNGs to the repo root
(`Heurekator_logo.png`, `Heurekator_logo_text.png`, `Heurekator_text.png`,
`Heurekator_pictures.png`) and a visual reference combining them with D1's direction
was published as an artifact:
`https://claude.ai/code/artifact/9c016805-ccdb-4b62-8893-a70165b1f7be` (treat as the
visual target, not literal code — it's a static mockup with placeholder content, not
real DOM/JS). `ROADMAP.md` names this as R1, the first item in the sequence toward the
rest of the vision, precisely because it is small, self-contained, and unblocked by any
open decision — except for the one this scoping pass surfaced below.

## Per-turn evaluation stamp — settled (D6)

D1's whole visual thesis is a literal rubber-stamp verdict landing at the moment an
answer is judged ("arviointi lyö kirjaimellisen leiman" — `D1-ui-direction.md`). Today
`app/core/engine.py::submit_answer` (line 53) computes an `Evaluation` (verdict +
scores) for every answer, but the route (`app/main.py::submit_answer`, lines 39-49)
never returns it — the frontend currently only ever learns the *next question* and
`area_index`, never the verdict of what was just submitted. `area_index` alone is
enough to render a 7-area progress track (areas resolve strictly in `AREAS` order, so
"before current index = resolved" needs no new data), but it is not enough to show a
live stamp on the answer that was just judged.

**Decided: option B** — `Engine.submit_answer` also returns the `Evaluation` it
already computes; `app/main.py`'s route adds one field (e.g. `verdict`) to its
non-`done` JSON response. Small, additive, backward-compatible — no existing field
changes shape. Logged as `../../DECISIONS/LOG.md` **D6** (rejected alternative: no
backend change, verdict visible only in the final report — see
`../../DECISIONS/D6-verdict-stamp-api.md` for the full reasoning). This raises Phase
P2's gate level from `standard` to `full`, same reasoning `report-fidelity`'s P1 used
when it changed an API response shape. Exact field name/shape is decided when P2 is
detailed (`PLAN-PHASE-DETAILING.md`), not here.

## Phase status

| Phase | Title | Status | Gate level | Depends on | Phase file | Exit state | Move-on gate |
|---|---|---|---|---|---|---|---|
| P0 | Design tokens + brand shell | done | standard | - | `done/P0-design-tokens-brand-shell.md` | shared CSS tokens + masthead (logo, palette, type) exist; no screen content restyled yet | browser-verified: page loads with new palette/logo, all three sections still function |
| P1 | Idea intake screen | planned | standard | P0 | - | `#idea-form` matches the direction | browser-verified: full idea-submission flow unchanged |
| P2 | Interrogation (chat) screen | planned | full (D6) | P0 | - | `#chat` matches the direction; area progress track shown; live per-turn verdict stamp | browser-verified: full session runs through all 7 areas to completion |
| P3 | Report screen | planned | standard | P0 | - | `#report` matches the direction | browser-verified: finished report renders correctly end to end |

Exactly one phase is `active` at a time. P0 is done; P1 is not yet detailed to
implementation grade (see `done/P0-design-tokens-brand-shell.md`'s contract) — a
review+advance session must detail it before it can be promoted to `active`.

## Implementation chunks + orchestration breakpoints

| Chunk | Phases | Nature | Boundary validation | Freeze / plan update | Gate |
|---|---|---|---|---|---|
| 0 | P0 | Groundwork | Browser: tokens applied, masthead correct, no console errors | Freeze token names/values for P1-P3 to reuse | Commit + human verify |
| 1 | P1 | UI-bearing | Browser: submit idea, first question appears | - | Commit + human verify |
| 2 | P2 | UI-bearing | Browser: full session through all 7 areas | Freeze verdict-stamp field name/shape (D6) | Commit + human verify |
| 3 | P3 | UI-bearing | Browser: finished report renders correctly | - | Commit + human verify |

## How to implement this plan

1. Read `../../PROJECT.md` §2 (layout) and §4 (hard invariants) before starting — none
   of the four invariants should change as a side effect of a visual rework; if a phase
   seems to require touching one, stop and ask.
2. Never invent an API field beyond what D6 settled (that a verdict field is added —
   not its exact name/shape, which Phase P2's detailing decides).
3. One phase per commit. Only one phase is `active` in the status table at a time.
4. Before coding, expand the selected phase into `phases/<id>.md` from current
   `frontend/` code: exact selectors, exact markup, exact JS functions touched.
5. Do exactly the phase scope. P0 must not restyle any screen's actual content — only
   the shared shell/tokens. P1-P3 must not redefine tokens P0 established; if a real
   gap in the token set is found, say so explicitly rather than adding an ad hoc color.
6. No frontend build step is introduced — `frontend/` stays buildless static
   HTML/JS/CSS (`../../PROJECT.md` §2).
7. Verification is manual browser verification per `../../PROJECT.md` §3 — no
   automated test suite exists in this repo; do not add one as a side effect of this
   plan.
8. The visual reference is the published artifact linked above plus
   `../../DECISIONS/D1-ui-direction.md` and the four `Heurekator_*.png` files at the
   repo root — treat the artifact as the visual spec (palette, type pairing, stamp
   language, layout concept), not as copy-paste-able code.
9. Fail loudly: no fabricated fallback content if a brand image fails to load —
   standard broken-image behavior is acceptable; no preloading/fallback logic is needed
   for a local single-user tool.

## Design rules (binding)

1. No change to `app/` except the single field D6 adds to `submit_answer`'s response —
   everything else in this plan is `frontend/`-internal (HTML/CSS/JS).
2. `frontend/` stays buildless (`../../PROJECT.md` §2) — no bundler, no framework, no
   npm dependency added.
3. Existing fetch/session-handling logic in `app.js` (the `state` object, event
   listeners, API calls) is preserved as-is; only DOM structure/rendering and CSS
   change, except for reading the one new verdict field D6 adds.
4. Hard invariants `../../PROJECT.md` §4 (all four) stay true — no auth added, no key
   handling touched, no encryption added to session storage, no human-review gate added
   before LLM output reaches the UI. This plan only changes how already-trusted output
   is displayed, same reasoning `report-fidelity`'s plan used for the same invariant.
5. Color/typography tokens (background, gold accent, verdict inks, mono/serif stacks)
   are defined once in Phase P0 and reused by name in P1-P3 — no per-screen ad hoc
   color values.
6. Brand image assets are copied into `frontend/` (exact path decided during P0
   detailing) rather than referenced from the repo-root originals — `app/main.py`
   mounts only `frontend/` via `StaticFiles`, so anything served must live inside it.
7. D1 committed to a single, deliberately dark visual world (`D1-ui-direction.md`) —
   this plan does not add a light theme.

## Current state (verified enough for scoping)

- `frontend/index.html` - `#idea-form`, `#chat` (`#messages`, `#answer-form`),
  `#report` — three plain sections, one visible at a time; generic labels, an `<h1>`
  and italic tagline, no branding.
- `frontend/app.js` - `state = {sessionId}`; fetches `POST /api/sessions`,
  `POST /api/sessions/{id}/answer`; `addMessage()` renders flat chat bubbles;
  `renderReport()` / `renderEvaluationProfile()` / `renderRiskRegister()` already
  produce the full structured report markup from `report-fidelity` P1/P2 — this plan
  only needs to restyle their *output*, the data flow is already complete and correct.
- `frontend/style.css` - generic `light-dark()` system-font styling, ~155 lines, no
  design tokens, no brand colors.
- `app/main.py` - `POST /api/sessions` returns `{session_id, question, area_index}`;
  `POST /api/sessions/{id}/answer` returns `{done, question, area_index}` or
  `{done, report}`. `area_index` is already present on every non-`done` response —
  enough to render a 7-area progress track without any backend change.
- `app/core/engine.py::submit_answer` (line 53) computes `evaluation` locally but the
  route never returns it yet — D6 adds this (see above).
- `Heurekator_logo.png` (869×966), `Heurekator_logo_text.png` (3476×1039),
  `Heurekator_text.png` (2659×634), `Heurekator_pictures.png` (moodboard/reference
  only) — added to repo root this session; solid navy background sampled at
  `#051527`.
- `../../DECISIONS/D1-ui-direction.md` - binding visual direction: dark, monospace
  question-stamps ("ALUE 02/07 — KOHDERYHMÄ"), evaluation shown as a literal
  rubber-stamp ("KESTÄVÄ", tilted).

What later phases inherit:
- P0's token names/values, frozen before P1-P3 start (chunk boundary above).
- D6's verdict field, exact name/shape frozen once P2 is detailed.

## Scoped phases

## Phase P0 - Design tokens + brand shell

**Status:** planned.
**Depends on:** none.
**Scope:** establish the shared visual foundation — CSS custom properties for the
navy/gold/ink palette sampled from the brand PNGs, the monospace+serif type pairing,
the brand logo served from within `frontend/` — plus a minimal masthead, without
restyling any of the three screens' actual content yet.
**Expected gate level:** standard.

**Current state / reason:**
- `frontend/style.css` has no tokens today; nothing in `frontend/` references the new
  brand PNGs, which currently live only at the repo root (outside the `StaticFiles`
  mount).

**Likely areas to touch:**
- `frontend/style.css` - new `:root` tokens (ground/surface/paper/ink-gold/ink-green/
  ink-rust, mono/serif font stacks).
- `frontend/index.html` - masthead markup (logo `<img>`, tagline).
- A new `frontend/assets/` (or similar, decided during detailing) directory holding the
  copied/optimized logo file.

**Must not:**
- Restyle `#idea-form`, `#chat`, or `#report` content — that is P1-P3.
- Add a build step.

**Verification shape:**
- Manual browser check: page loads, shows the navy background, logo, and tagline; no
  console errors; the three existing sections (still visually generic below the
  masthead) still function exactly as before.

**Exit:** shared tokens + masthead exist and are visually correct in isolation.
**Move-on gate:** browser-verified by the user.

## Phase P1 - Idea intake screen

**Status:** planned.
**Depends on:** P0.
**Scope:** restyle `#idea-form` per the direction (case-field textarea, monospace
field labels, stamp-style "Aloita" button) using P0's tokens.
**Expected gate level:** standard.

**Current state / reason:**
- `frontend/index.html`'s `#idea-form` is a bare label + textarea + button;
  `frontend/app.js`'s `startBtn` listener logic is unaffected by a visual restyle.

**Likely areas to touch:**
- `frontend/index.html` - `#idea-form` markup.
- `frontend/style.css`.
- `frontend/app.js` - only if new elements need wiring, which the scope as written
  should not require.

**Must not:**
- Touch the fetch call or the `state` object in `app.js`.
- Add a language selector — that belongs to `ROADMAP.md` R2 (D3); a static one added
  here would just need rewiring later.

**Verification shape:**
- Manual browser check: full idea-submission flow still works end to end (idea text →
  first question appears).

**Exit:** `#idea-form` matches the direction; existing submit flow unchanged.
**Move-on gate:** browser-verified by the user.

## Phase P2 - Interrogation (chat) screen

**Status:** planned.
**Depends on:** P0.
**Scope:** restyle `#chat` per the direction — area progress track (derived from the
existing `area_index`), monospace question labels, serif Q/A text, and the live
per-turn verdict stamp (D6).
**Expected gate level:** full (D6 changes an API response shape).

**Current state / reason:**
- `frontend/app.js::addMessage` renders flat generic bubbles today.
- `area_index` is already delivered on every response but never rendered.
- D6: `submit_answer`'s response will gain a verdict field — exact name/shape decided
  when this phase is detailed.

**Likely areas to touch:**
- `frontend/index.html` - `#chat` markup.
- `frontend/app.js` - `addMessage` and/or a new render function for the area track;
  read and render the new verdict field.
- `frontend/style.css`.
- `app/core/engine.py::submit_answer` return signature, `app/main.py::submit_answer`
  route (D6).

**Must not:**
- Change the evaluation logic itself (the `Engine`'s resolved/verdict decision) — only
  expose data already computed.
- Touch `app/core/criteria.py`.

**Verification shape:**
- Manual browser check: run a full session through several areas, confirm the area
  track advances correctly and verdict stamps appear as expected on each submitted
  answer.

**Exit:** `#chat` matches the direction; area progress visible; live verdict stamp
shown per D6.
**Move-on gate:** browser-verified by the user; a full session reaches the report
screen without error.

## Phase P3 - Report screen

**Status:** planned.
**Depends on:** P0.
**Scope:** restyle `#report`'s existing structured output (`renderReport` /
`renderEvaluationProfile` / `renderRiskRegister` already produce the right data via
`report-fidelity` P1/P2) into the paper-card concept document, status-grid evaluation
profile, and prioritized risk register from the direction, plus the recommendation
stamp.
**Expected gate level:** standard.

**Current state / reason:**
- `frontend/style.css`'s current `.area-card` / `.verdict-pill` / `.risk-item` rules
  are generic `light-dark()` styling predating D1; the DOM structure `renderReport()`
  builds may need light restructuring (e.g. grid wrapper elements), but the data it
  receives is unchanged.

**Likely areas to touch:**
- `frontend/app.js` - `renderReport` / `renderEvaluationProfile` /
  `renderRiskRegister` markup structure (not their data access).
- `frontend/style.css`.

**Must not:**
- Touch `app/` at all.
- Change what data reaches `renderReport` — the `Report` shape is frozen by the
  `report-fidelity` plan.

**Verification shape:**
- Manual browser check: full session end to end; confirm the concept document,
  evaluation profile, risk register, and recommendation all render correctly and match
  the direction.

**Exit:** `#report` matches the direction end to end.
**Move-on gate:** browser-verified by the user.

## Carry-overs / deferred

- D3 (multilingual) - language selector, translated UI shell strings — explicitly
  `ROADMAP.md` R2, not this plan.
- D4 (idea lifecycle) - session listing, idea state — explicitly `ROADMAP.md` R3, not
  this plan.
- Automated test suite - out of scope; matches the rest of the repo
  (`../../PROJECT.md` §3).
- A light theme - D1 committed to a single dark visual world; not added by this plan.
