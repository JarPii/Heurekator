# Mode Selector Plan

> **Status:** scoped forward plan - created 2026-08-17 on branch main.
> **Scope:** `ROADMAP.md` R1.5 (D7). Add one new screen, `#mode-select`, shown before
> `#idea-form` on app load: two choices, "Idea" and "Ongelma". "Idea" routes into the
> existing, unchanged §3 flow (`#idea-form` → `#chat` → `#report`). "Ongelma" is shown
> but visibly disabled/labeled not-yet-implemented (D7 — depends on `Visio.md` §2a,
> `ROADMAP.md` R4, not yet scoped).
> **Out of scope:** any `§2a` backend logic (root-cause question chain, stopping
> criterion) — R4 builds that, not this. Any change to `#idea-form`, `#chat`, `#report`
> internals — those stay exactly as `interrogation-ui`'s P0-P2 left them. D3
> (multilingual), D4 (idea lifecycle) — unrelated roadmap items.
> **Target:** internal-only prototype, matching `Visio.md`'s own scope (§6).
>
> **Parts:** single phase — this is a small, self-contained UI addition, no backend
> change, no schema change.
>
> **How to use this plan:** one phase, detailed directly since scope and current code
> are already fully verified (D7's narrative). See `phases/P0-mode-selector.md`.

## Why this plan exists

D7 (`../../DECISIONS/D7-mode-selector.md`) settled this during `interrogation-ui`
Phase P2's user testing: the app has no entry point for `Visio.md` §2a's separate
problem-validation mode — it always asks for an "idea" and immediately runs the
idea-validation engine (§3) against it, silently assuming the idea's underlying
problem is real. `ROADMAP.md` R1.5 records this as its own roadmap step, inserted
after R1 (shares R1's `frontend/` token/style foundation) and before R2.

## Phase status

| Phase | Title | Status | Gate level | Depends on | Phase file | Exit state | Move-on gate |
|---|---|---|---|---|---|---|---|
| P0 | Mode selector screen | active | standard | `interrogation-ui` P0 (tokens) | `phases/P0-mode-selector.md` | `#mode-select` shown first; "Idea" reaches existing flow unchanged; "Ongelma" visibly disabled | browser-verified: both choices behave as specified, existing Idea flow unregressed |

Exactly one phase. No later phases are scoped yet — if `Visio.md` §2a is later solved
(R4), "Ongelma" becoming real is a new plan, not an extension of this one, since it
would add real backend logic this plan explicitly excludes.

## How to implement this plan

1. Read `../../PROJECT.md` §2 (layout) and §4 (hard invariants) before starting — this
   phase changes no backend code and no invariant.
2. `frontend/` stays buildless — no bundler, no framework, no npm dependency added.
3. Reuse `interrogation-ui` P0's frozen design tokens (`--ground`, `--surface`, `--line`,
   `--paper`, `--ink-gold`, `--font-mono`, `--font-serif`, etc.) — no new ad hoc colors.
4. "Ongelma"'s disabled state must be honest per `../../BUILDING/REPO-RULES.md` §2: a
   clearly labeled, non-functional control — not a button that does nothing silently,
   not a fake flow.
5. One phase, one commit.
6. Verification is manual browser verification per `../../PROJECT.md` §3 — no automated
   test suite exists in this repo.

## Design rules (binding)

1. No change to `app/` — this plan is `frontend/`-internal only (HTML/CSS/JS).
2. `#idea-form`, `#chat`, `#report` markup/CSS/JS stay byte-identical to
   `interrogation-ui`'s P2 end-state — this plan only adds a new screen shown *before*
   them, gated by `hidden`, same pattern the existing three sections already use.
3. Reuse D1's token set and visual language (`../../DECISIONS/D1-ui-direction.md`) — the
   selector is not a new visual direction, it is two more stamp-style choices in the
   same Kuulustelupöytäkirja world.
4. `PROJECT.md` §4 invariants unaffected — no auth, no key handling, no session storage
   change, no new LLM call (this phase adds zero LLM calls — "Idea" reuses the existing
   `POST /api/sessions` call unchanged, "Ongelma" makes no call at all since it is
   disabled).

## Current state (verified enough for scoping)

- `frontend/index.html` - `<main id="app">` currently renders `<header class="masthead">`
  then `#idea-form` (visible), `#chat` (hidden), `#report` (hidden) in sequence — no
  screen currently exists before `#idea-form`.
- `frontend/app.js` - no mode-selection state exists; `state = { sessionId: null }` is
  the only app state; `#idea-form`'s `start-btn` listener is the current entry point,
  firing immediately on page load readiness (no gating screen before it).
- `frontend/style.css` - P0's tokens (`interrogation-ui` `done/P0-design-tokens-brand-shell.md`)
  and the `.masthead`/`.lockup` pattern are established and reusable as-is.
- `../../DECISIONS/D7-mode-selector.md` - binding decision and rationale.
- `ROADMAP.md` R1.5 - this plan's roadmap anchor.

What later phases inherit: nothing yet — this is the first and only phase.

## Scoped phases

## Phase P0 - Mode selector screen

**Status:** planned.
**Depends on:** `interrogation-ui` Phase P0 (design tokens), done.
**Scope:** add `#mode-select`, a new section shown on load, before `#idea-form`, with
two stamp-style choice buttons: "Idea" and "Ongelma". Choosing "Idea" hides
`#mode-select` and shows `#idea-form` exactly as it behaves today (no change to that
flow). "Ongelma" is rendered as a visibly disabled control with a short label
explaining it is not yet available.
**Expected gate level:** standard — no API/schema change, no invariant touched, purely
additive frontend markup/JS/CSS.

**Current state / reason:**
- No mode-selection concept exists anywhere in `frontend/` today; `#idea-form` is
  always the first visible screen.

**Likely areas to touch:**
- `frontend/index.html` - new `#mode-select` section, markup for the two choices.
- `frontend/app.js` - a small click handler toggling `#mode-select`/`#idea-form`
  visibility for the "Idea" choice; the "Ongelma" control needs no handler beyond
  `disabled`/non-interactive styling.
- `frontend/style.css` - new rules for the two choice controls, reusing D1's tokens.

**Must not:**
- Add any backend call, route, or `app/` change for "Ongelma" — it must not pretend to
  start a process it cannot run.
- Change `#idea-form`, `#chat`, or `#report`'s existing markup, CSS, or JS.
- Add a build step or new dependency.

**Verification shape:**
- Manual browser check: on load, `#mode-select` appears first with both choices
  visible; "Ongelma" is clearly non-interactive/disabled-looking and does not navigate
  anywhere; "Idea" reveals `#idea-form` and the existing idea-submission flow works
  exactly as before, end to end through a full session.

**Exit:** `#mode-select` is the app's first screen; "Idea" reaches the unchanged §3
flow; "Ongelma" is honestly non-functional.
**Move-on gate:** browser-verified by the user.

## Carry-overs / deferred

- Making "Ongelma" functional - depends on `Visio.md` §2a being resolved (`ROADMAP.md`
  R4: stopping criterion, question logic) and scoped as its own plan.
- Any styling/behavior change to `#idea-form`, `#chat`, `#report` - out of this plan,
  covered by `interrogation-ui`.
