# Mode Selector Plan

> **Status:** complete - all phases done, revised 2026-08-18 on branch main.
> **Scope:** `ROADMAP.md` R1.5 (D7, extended by D8/D9). `#mode-select`, shown before
> `#idea-form` on app load: three choices, "Idea", "Ongelma", "Aivoriihi". "Idea" routes
> into the existing, unchanged §3 flow (`#idea-form` → `#chat` → `#report`). "Ongelma"
> and "Aivoriihi" are shown but visibly disabled/labeled not-yet-implemented (D7/D8 —
> depend on `Visio.md` §2a/`ROADMAP.md` R4 and §2b/R5, neither scoped yet). After
> "Idea", a second screen, `#mittakaava-select`, captures the `Visio.md` §1.2 scope
> classification (sisäinen toiminta / toimitus / uusi ominaisuus / uusi ratkaisu)
> before `#idea-form` and is sent to the backend, where it scales the
> question-generation prompt (P2).
> **Out of scope:** any `§2a`/`§2b` backend logic (R4, R5) — those are separate plans
> when scoped. Aivoriihi's own theme menu (D8: pick a validated ongelma or give one
> directly) — that is R5's UI; here "Aivoriihi" is only the honest not-yet-available
> button, same as "Ongelma". Any change to `#idea-form`/`#chat`/`#report` beyond the
> one new request field (P2) and the case-heading/area-cap-note additions (P2/P3) —
> everything else stays as `interrogation-ui`'s P0-P2 left it. Evaluation/report
> prompts (`app/prompts/evaluation.py`, `report.py`) — mittakaava only scales question
> generation. D3 (multilingual), D4 (idea lifecycle) — unrelated roadmap items.
> **Target:** internal-only prototype, matching `Visio.md`'s own scope (§6).
>
> **Parts:**
> - **Part 0 - Two-choice selector (D7).** `#mode-select` with "Idea"/"Ongelma". Done.
> - **Part 1 - Third choice + scope screen (D8/D9).** Add "Aivoriihi" to
>   `#mode-select`; add `#mittakaava-select` after "Idea". Done.
> - **Part 2 - Mittakaava-aware questions.** Send the mittakaava choice to the
>   backend and use it to scale the question-generation prompt (D9). Done.
> - **Part 3 - Area-cap advance signal.** Make the existing `MAX_ATTEMPTS_PER_AREA`
>   gate visible to the user, client-side only. Done.
>
> **How to use this plan:** all phases (P0-P3) are done and compressed (`done/`). This
> plan is complete - no active phase remains.

## Why this plan exists

D7 (`../../DECISIONS/D7-mode-selector.md`) settled this during `interrogation-ui`
Phase P2's user testing: the app has no entry point for `Visio.md` §2a's separate
problem-validation mode — it always asks for an "idea" and immediately runs the
idea-validation engine (§3) against it, silently assuming the idea's underlying
problem is real. `ROADMAP.md` R1.5 records this as its own roadmap step, inserted
after R1 (shares R1's `frontend/` token/style foundation) and before R2.

D8 (`../../DECISIONS/D8-aivoriihi-theme-menu.md`) and D9
(`../../DECISIONS/D9-question-design-principle.md`) extended the vision this plan
implements: the app's entry point is a three-way choice, not two (`Visio.md` §1.2),
and a second, mittakaava-scale choice follows the first. This plan's P1 phase brings
`#mode-select` in line with D8 (add the "Aivoriihi" button) and adds the
`#mittakaava-select` screen `Visio.md` §1.2 describes — both purely additive frontend
work, same shape as P0.

## Phase status

| Phase | Title | Status | Gate level | Depends on | Phase file | Exit state | Move-on gate |
|---|---|---|---|---|---|---|---|
| P0 | Mode selector screen (Idea/Ongelma) | done | standard | `interrogation-ui` P0 (tokens) | `done/P0-mode-selector.md` | `#mode-select` shown first; "Idea" reaches existing flow unchanged; "Ongelma" visibly disabled | browser-verified: both choices behave as specified, existing Idea flow unregressed |
| P1 | Third choice (Aivoriihi) + mittakaava screen | done | standard | P0 | `done/P1-mittakaava-and-aivoriihi.md` | `#mode-select` has three choices; `#mittakaava-select` captures scope before `#idea-form` | browser-verified: all three choices behave as specified, mittakaava screen captures a choice and reaches the unchanged idea flow |
| P2 | Mittakaava-aware question framing | done | full | P1 | `done/P2-mittakaava-aware-questions.md` | `POST /api/sessions` accepts `mittakaava`; the question-generation prompt scales by it | browser-verified for "sisäinen toiminta"; "uusi ratkaisu" not independently re-verified (see `done/P2-...md`) |
| P3 | Area-cap advance signal | done | standard | P2 | `done/P3-area-cap-advance-signal.md` | a visible note explains when an area advanced because the 3-attempt cap was hit, not a `kestävä` verdict | user-confirmed: cap-forced advance shows the note; the genuine-`kestävä`/no-note case follows the same logic but was not independently re-walked (see `done/P3-...md`) |

P0, P1, P2, and P3 are done - this plan is complete. P3 was scoped mid-session: live
testing during P2's verification surfaced that `MAX_ATTEMPTS_PER_AREA`'s existing gate
(`app/core/criteria.py`) has no visible signal, so the user couldn't tell why a
conversation "felt short." P3 made that already-existing gate visible, purely
client-side — no backend change. If `Visio.md` §2a or §2b are later solved (R4/R5),
"Ongelma"/"Aivoriihi" becoming real is a new plan, not an extension of this one, since
it adds real backend logic this plan explicitly excludes.

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
5. **Superseded by P2** — P1 originally scoped the mittakaava choice as frontend-only
   (no backend field, since nothing consumed it). P2 gave it a real consumer (the
   question-generation prompt, per D9), so as of P2 the mittakaava choice *is* sent to
   the backend as `POST /api/sessions`'s `mittakaava` field and stored on `Session`.
   The underlying rule — no unused fields invented ahead of a real consumer — still
   applies to *future* additions; it just no longer applies to mittakaava itself.

## Current state (verified enough for scoping)

- `frontend/index.html` - `<main id="app">` renders `<header class="masthead">`, then
  `#mode-select` (three buttons: `#mode-idea-btn` enabled, `#mode-ongelma-btn` and
  `#mode-aivoriihi-btn` disabled), then `#mittakaava-select` (`hidden`, four scope
  buttons), then `#idea-form` (`hidden`), `#chat` (`hidden`, now also holding
  `#case-heading`), `#report` (`hidden`) - P0-P2's combined output, live in `main`.
- `frontend/app.js` - `state = { sessionId: null, mittakaava: null }`; the full
  mode-select → mittakaava-select → idea-form chain is wired; `POST /api/sessions`
  sends `{ idea, mittakaava }`.
- `app/models.py`/`app/core/engine.py`/`app/main.py`/`app/prompts/question.py`/
  `app/core/criteria.py` - `Mittakaava` threads end to end from the request body to
  the question-generation prompt (P2's frozen contract, `done/P2-...md`).
- `../../DECISIONS/D7-mode-selector.md`, `D8-aivoriihi-theme-menu.md`,
  `D9-question-design-principle.md` - binding decisions and rationale.
- `ROADMAP.md` R1.5 - this plan's roadmap anchor.

What later phases inherit:
- P0/P1's `.mode-select-label`/`.mode-choices`/`.mode-choice` classes.
- P2's `Mittakaava` Literal and `MITTAKAAVA_FRAMING` dict - any later prompt needing
  scope-awareness extends these, not a second mapping.
- P3 (below) needs no new inherited contract - it reads fields P2 already returns.

## Scoped phases

None active - P0-P3 are all done and compressed into `done/`. This plan is complete.

## Carry-overs / deferred

- Making "Ongelma" functional - depends on `Visio.md` §2a being resolved (`ROADMAP.md`
  R4: stopping criterion, question logic) and scoped as its own plan.
- Making "Aivoriihi" functional, including its theme menu (D8: pick a validated
  ongelma or give one directly) - depends on `Visio.md` §2b being resolved
  (`ROADMAP.md` R5) and scoped as its own plan.
- Nesting mittakaava's sub-scopes (oma/tiimi/organisaatio within "sisäinen toiminta";
  korjaava/ehkäisevä within "toimitus", `Visio.md` §1.2) - not yet its own UI control;
  only the four top-level buckets are selectable in this phase.
- Any styling/behavior change to `#idea-form`, `#chat`, `#report` - out of this plan,
  covered by `interrogation-ui`.
