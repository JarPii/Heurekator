# PLAN-AUTHORING-SCOPING.md - How to turn requirements into a scoped phase list

This guide is for the first planning conversation. Its job is **not** to create a
fully implementable plan. Its job is to help the user and agent turn requirements
into small, ordered, reviewable phases that are intentionally still a little vague.

Use this when the user gives requirements and wants to discuss scope, feature areas,
or phase boundaries. Use `PLAN-PHASE-DETAILING.md` later, when one phase is selected
for implementation-grade detail.

> **Output target:** a plan *folder* `AGENT-INSTRUCTIONS/PLANS/<slug>/` whose
> `full-plan.md` holds strong top matter, design rules, implementation rules, chunks,
> gates, and a phase status table, with phases written as scoped TODOs rather than
> exhaustive instructions. Per-phase implementation files are added later, one at a
> time, by `PLAN-PHASE-DETAILING.md`.

---

## 0. Plan folder layout

A plan is a folder, never a single monolith file. One scope doc, one file per phase
built so far, and compressed stubs for completed phases:

```
AGENT-INSTRUCTIONS/PLANS/<slug>/
  full-plan.md          # this document's output: scope, design rules, phase status table, scoped phases
  phases/
    <id>-<title>.md     # one detailed phase file, created only when that phase is about to be built
  done/
    <id>-<title>.md     # completed phase compressed to a short frozen-contract stub
```

Rules:

- `full-plan.md` stays small and never grows into implementation detail. It is the
  map and the single source of truth for phase status.
- A phase file under `phases/` is written only when that phase is selected for
  implementation (see `PLAN-PHASE-DETAILING.md`). Do not pre-write all phases.
- An implementer should never need to load more than `full-plan.md` (top matter +
  design rules + status table) plus the one active phase file. That bound is the
  point: it is what stops a weak model from drowning in a 100KB monolith.
- On phase completion, the phase file is compressed into a `done/` stub holding the
  frozen contract later phases consume, and the status table row is flipped.

---

## 1. Planning conversation mode

Do not jump from requirements to a full detailed plan. First make the scope legible:

1. Ask short questions until the goal, non-goals, risks, and user-visible behavior are clear.
2. Identify feature areas and natural seams in the current system.
3. Break the work into coherent phases that can each be discussed, rewritten, or deleted.
4. Keep each phase detailed enough to show intent, dependencies, and gates.
5. Leave exact signatures, call sites, schema columns, and test names for the later detailed-phase document.

The conversation should feel like shaping a TODO list with constraints, not handing
over a build script. Phases should be small enough to implement safely, but not
artificially tiny: a cohesive vertical slice may span multiple files when it has one
clear outcome and one verification story.

### 1a. Research pass for fuzzy ideas

Use a research pass before writing `full-plan.md` when the user gives an idea rather
than settled requirements. The output is a short requirements note, not a plan.

Use research when:

- the request names a goal but not actors, workflows, or success criteria;
- several product directions are possible and phase boundaries would be arbitrary;
- user-visible behavior, privacy boundaries, or operational constraints need decisions;
- the work might touch data covered by a hard invariant in `../PROJECT.md` §4, AI behavior, identity, or billing-like policy.

Skip research and write the scoped plan directly when:

- the user already supplied clear requirements and non-goals;
- the task is a small bug fix or mechanical change;
- an existing plan or active phase already defines the scope.

Research protocol:

1. Ask short questions until purpose, actors, context, boundaries, needs, risks, and non-goals are clear.
2. Read the code map named in `../PROJECT.md` §2 (if any) and enough stable docs/code to name real owning subsystems.
3. Record decisions, open questions, constraints, and obvious non-goals.
4. Stop before exact implementation detail. Do not name signatures, migrations, or caller lists unless already central and verified.
5. Convert the research note into `full-plan.md` only after the user confirms the direction or the remaining questions are explicitly deferred.

Suggested research note shape:

```markdown
# <Feature / Problem> Research

## Goal
- <user-visible outcome>

## Actors / workflows
- <who does what — list the actor/role catalog and the workflows each touches; these are the seeds the detailed phase expands into enumerated use cases per `PLAN-PHASE-DETAILING.md` §8b>

## Boundaries / non-goals
- <what is intentionally excluded>

## Current system anchors
- `<doc or source path>` - <verified existing seam or constraint>

## Decisions
- <settled decision>

## Open questions before planning
- <question that affects scope or safety>

## Plan recommendation
- <recommended phase shape at a high level>
```

---

## 2. Read enough code, not every implementation detail

Read before writing, but calibrate depth to this document's purpose:

- Read `../PROJECT.md` §2 first, and any code map it names.
- Read the architecture docs for touched subsystems.
- Open enough current files to know where the work belongs and whether named seams exist.
- Do not fabricate APIs, routes, tables, or config keys.
- Do not spend the scoping pass enumerating every caller or exact before/after signature.

If a requirement appears to require a missing subsystem or a new abstraction, mark that
as an open scoping question instead of inventing it.

---

## 3. Plan anatomy

Keep the non-phase parts operationally strict:

1. **Top matter** - status, date/branch if relevant, target bar, scope/non-scope, and how to use the plan.
2. **Phase status table** - the single source of truth for what is done/active/next. One row per phase (see 3a-bis).
3. **Parts/chunks table** - grouped phase ranges, phase nature, boundary validation, freeze/update needs, and gates.
4. **How to implement this plan** - general rules for later implementers: read map/files, never invent, one phase per commit, expand a phase right before coding, config-not-code, run verification, fail loudly.
5. **Binding design rules** - subsystem-specific invariants and repo invariants that must not be violated.
6. **Current state summary** - verified enough to anchor the scope, including limitations and known gaps.
7. **Scoped phases** - small TODO-like phases using the template below.
8. **Carry-overs/deferred** - explicit list of things intentionally not included.

This first-pass plan should be useful for discussion and sequencing. It should not be
enough for a weak model to implement without expansion.

### 3a. Top matter template

Every scoped plan starts with a clear status block and use instructions. Copy this
shape and fill it with the current work:

```markdown
# <Project / Feature Area> Plan

> **Status:** scoped forward plan - revised <date> on branch <branch if relevant>.
> **Scope:** <what systems/features this plan covers>.
> **Out of scope:** <nearby systems/features intentionally excluded>.
> **Target:** <production-grade / prototype / internal-only / migration-only>.
>
> **Parts:**
> - **Part 0 - Groundwork.** Behavior-neutral setup, migrations, seams, or cleanup the rest depends on.
> - **Part A - Core behavior.** Backend/domain/runtime changes that create the capability.
> - **Part B - Product/UI.** User-facing screens, interactions, or browser-verifiable behavior.
> - **Part C - Hardening/deferred.** Follow-up reliability, observability, cleanup, or operator surfaces.
>
> **How to use this plan:** discuss and edit phase boundaries first. When implementing,
> first shape the selected vague phase (outcome, boundaries, tradeoffs, open questions),
> then expand exactly one settled phase into an implementation-grade phase from current code before coding.
```

Rules for top matter:

- Name scope and non-scope explicitly so nearby features do not get pulled in.
- State whether the bar is production-grade or exploratory.
- Split into parts only when parts help discussion; otherwise use one phase list.
- Mention implementation only as a later expansion step, not as detailed instructions.

### 3a-bis. Phase status table (single source of truth)

Right after top matter, `full-plan.md` carries one table that records, for every
phase, its status and the gate that lets work move on. This is the first thing an
implementer reads to learn what is done and what is next. Keep it current — it, not
prose scattered through the file, is authoritative.

```markdown
## Phase status

| Phase | Title | Status | Gate level | Depends on | Phase file | Exit state | Move-on gate |
|---|---|---|---|---|---|---|---|
| P0 | Groundwork | done | standard | - | `done/P0-groundwork.md` | seams/migrations in place | tests green, committed |
| P1 | Thread store | active | full | P0 | `phases/P1-thread-store.md` | store reads/writes via existing seam | tests + user test pass |
| P2 | Read views | next | security | P1 | - (detail when selected) | - | - |
| P3 | UI surface | planned | full | P2 | - | - | - |
```

Status values: `done`, `active` (one at a time), `next`, `planned`.

Rules:

- Exactly one phase is `active`. Do not start another until the active one's move-on
  gate passes.
- `Phase file` points at `phases/<id>.md` while active, `done/<id>.md` once compressed,
  and `-` while still only scoped.
- `Gate level` is a first-pass expectation (`minimal`, `standard`, `full`, or `security`);
  the detailed phase must confirm or change it using `PLAN-PHASE-DETAILING.md`.
- The `Move-on gate` column is the concrete "when to move to the next phase" answer the
  user asked for: it names the automated + user verification that must pass first.
- When a phase completes, flip its row to `done` and repoint its file to `done/`.

### 3b. Implementation chunks and orchestration breakpoints

Add this section for multi-phase work. It explains where to pause, validate, freeze
contracts, and rewrite later phases after earlier phases become real.

```markdown
## Implementation chunks + orchestration breakpoints

Handoff unit = one coherent phase per implementation session/commit. Before
implementation, the selected phase is discussed/scoped, then expanded from current code
into a detailed phase spec. Later phases stay scoped until their dependencies are real.

| Chunk | Phases | Nature | Boundary validation | Freeze / plan update | Gate |
|---|---|---|---|---|---|
| 0 | G1 -> G2 | Groundwork | schema/config/service seams reviewed | freeze created names and rewrite consumers | tests |
| 1 | A1 -> A3 | Core behavior | end-to-end backend behavior validated | compress implemented contract; update downstream TODOs | tests + deploy if needed |
| 2 | U1 -> U2 | UI-bearing | browser steps verified by user | freeze route/state shape | commit + human verify |
```

Chunk rules:

- A chunk boundary is not decoration. It is where the orchestrator validates finished behavior.
- Freeze real names/shapes created by completed phases before detailing later phases.
- If a later phase needs an API/schema from an earlier phase, keep it vague until the earlier gate passes.
- Do not create child phases reflexively. Split when boundaries are genuinely separate;
  keep moderate multi-file slices together when they share one outcome and gate.
- At a boundary, replace completed phase TODOs with a short implemented contract if the plan remains active.
- UI-bearing chunks require a working-state commit and human verification before dependent work continues.

### 3c. How-to-implement section content

Scoped plans still need implementation rules, but they should be general and repeated
inside the plan so implementers do not chase separate guidance. Include a section like:

```markdown
## How to implement this plan

1. Read `AGENT-INSTRUCTIONS/PROJECT.md` §2 (and any code map it names), then read every file named by the selected phase.
2. Never invent a signature, column, table, route, config key, or import. If it does not exist, stop and report drift.
3. One phase at a time, one commit per phase, unless a smaller safety commit is needed. Only one phase is `active` in the status table.
4. Before coding, discuss/scope the selected vague phase, then expand it into its own `phases/<id>.md` file from current code: paths, signatures, callers, migrations, tests, user-test steps, docs. Load only `full-plan.md` (top matter + design rules + status table) and that one phase file while implementing.
5. Do exactly the phase scope. Do not pull later TODOs forward.
6. Config, not code: model names, provider names, prices, thresholds, budgets, prompt pack ids, and policy knobs belong in config.
7. Run targeted tests, baseline backend tests, and frontend build when frontend changed.
8. Fail loudly. No swallowed errors, fabricated fallback data, or fake provider answers.
```

This section is not a substitute for the detailed-phase document. It is a guardrail
that keeps scoped phases from being misread as permission to guess.

### 3d. Current state / foundation section

Every scoped plan needs a grounded summary of what exists today. It can be shorter
than a detailed implementation plan, but it must be real.

Use this shape:

```markdown
## Current state (verified enough for scoping)

- `<stable doc or source path>` - <current responsibility / behavior>.
- `<source path>` - <known seam likely to be extended>.
- `<source path>` - <limitation, bug, or missing capability that motivates work>.

What later phases inherit:
- <existing API/schema/config/seam that should be reused>.
- <known constraint or limitation to preserve>.
```

Rules:

- Include honest limitations, not just happy path.
- Name likely owning subsystems but avoid exact caller lists.
- If current state is uncertain, make that an open question.
- Do not mark something verified unless it was read in current docs/code.

### 3e. Design rules section

Use numbered, binding design rules. They should be concrete enough to reject bad
implementations later.

Example shape:

```markdown
## Design rules (binding)

1. Existing permission/session boundaries stay authoritative.
2. Extend existing service/store/tool seams before creating new ones.
3. User-visible state comes from backend-owned durable state, not frontend-only inference.
4. Config owns policy knobs; code owns mechanics.
5. Fail closed on ambiguous identity, ownership, or visibility.
6. UI phases require human browser verification before dependent work starts.
```

Add subsystem-specific rules from stable architecture docs and current code.

### 3f. Implemented compression section

When a phase completes, its detailed `phases/<id>.md` file is compressed into a
`done/<id>.md` stub holding only the frozen contract later phases consume — the
detailed build instructions are retired so they cannot mislead future detailing. The
`full-plan.md` status table row flips to `done` and repoints at the stub.

Use this shape for `done/<id>.md`:

```markdown
## Phase <id> - <area> [DONE]

Implemented and verified. Build instructions retired. Later phases consume these
frozen contracts:

- `<path>` now owns <capability>; callers use <real method/route/config key>.
- `<schema/config>` now contains <real field/key>; downstream phases must not invent a replacement.
- Known carry-over: <gap intentionally folded into later phase>.
```

Keep only the frozen contract. Do not keep obsolete build steps.

---

## 4. Scoped phase template

Use this lighter template for each phase:

```markdown
## Phase <id> - <short title>

**Status:** planned.
**Depends on:** <previous phase(s) or none>.
**Scope:** <one paragraph: what this phase makes possible>.
**Expected gate level:** <minimal | standard | full | security>.

**Current state / reason:**
- <verified fact or user problem>
- <known limitation or risk>

**Likely areas to touch:**
- `<path or subsystem>` - <why it is likely involved>
- `<path or subsystem>` - <why it is likely involved>

**TODOs:**
1. <small outcome-level task, not exact code instructions>
2. <small outcome-level task>
3. <small outcome-level task>

**Must not:**
- <invariant or shortcut to avoid>
- <out-of-scope feature>

**Verification shape:**
- <test/build/user-verify category, not exact test names unless already obvious>
- <if UI-bearing / workflow-visible: flag that the detailed phase must derive use cases and automate them in the repo E2E harness per `PLAN-PHASE-DETAILING.md` §8b>

**Exit:** <observable state at phase boundary>.
**Move-on gate:** <what must pass — automated tests + user test — before the next phase starts>.
```

When this phase is selected for build, it is expanded into its own
`phases/<id>-<title>.md` per `PLAN-PHASE-DETAILING.md`. The scoped entry here stays as
the map; exact steps live in the phase file.

Good scoped TODO:

- "Expose queued and failed job states through the existing status service without adding a second store."

Too detailed for this document:

- "Change `JobStatusService.status_for(self, job_id, actor)` to `status_for(self, job_id, actor, *, include_failed=False)` and update callers at ..."

Too vague:

- "Fix jobs."

---

## 5. Detail level rules

Include:

- phase purpose and dependencies;
- likely files/subsystems, if verified;
- intended phase boundary and non-goals, especially when the phase could be sliced several ways;
- important invariants and forbidden shortcuts;
- broad TODOs in implementation order;
- whether migration, backend tests, frontend build, live deploy, or human UI verification is likely;
- expected gate level and why that level fits the risk;
- open questions that must be answered before detailing.

Avoid in this document:

- exact function signatures unless already central to a known seam;
- path:line caller lists;
- exact migration filenames;
- exhaustive test names;
- full prompts or config schemas;
- checklist boxes detailed enough for implementation.

Those belong in the detailed-phase expansion.

---

## 6. Chunks and gates

Use chunks to make orchestration visible:

| Chunk | Phases | Nature | Boundary validation | Freeze / plan update | Gate |
|---|---|---|---|---|---|
| 1 | P1 -> P2 | Backend groundwork | Tests + contract review | Expand next phases against real code | Commit |
| 2 | P3 | UI-bearing feature | Build + human verify | Freeze route/state shape | Commit before verify |

Chunk boundaries are where the orchestrator should later:

- validate the just-built behavior;
- freeze real contracts created by earlier phases;
- rewrite downstream vague phases before expanding them;
- compress implemented work into a short contract record.

Do not make later phases depend on guessed signatures from earlier phases. Say the
later phase will be detailed after the earlier gate freezes the real seam. Avoid
splitting every scoped item into children by default; use child phases when there is a
real independent gate, separate risk, or separate discussion to have.

---

## 7. Design rules and invariants

Every scoped plan should restate the relevant hard rules in the plan itself, plus any
subsystem rules. Do not make implementers chase another document for the rules that
decide whether a phase is safe.

Copy the rules relevant to this phase's touched area, verbatim, from:

- **Hard invariants** — `../PROJECT.md` §4 (this repo's binding list: what gates access
  to sensitive data, what an AI/automation path may and may not write, secret handling,
  fixture safety, "one source of truth," etc.).
- **No-hack rules** — `../BUILDING/REPO-RULES.md` §1 (no hardcoded ids/models/keys, no
  duplicate code paths, no swallowed errors, no reaching around a permission/safety
  check, no faked product behavior).

Do not re-derive or paraphrase these from memory; pull the actual current text from
those two places so a stale copy never drifts from the source of truth. Make the
relevant ones binding in phase `Must not` sections.

---

## 8. Open questions are first-class

If a requirement is not settled, write it as an open question near the relevant phase.
Do not silently choose.

Good open question:

- "Should restored decisions reappear in the original message chip, or only in settings until refreshed? Decide before detailed phase."

Bad open question:

- "Figure out backend."

When the user answers, update the scoped phase. Do not expand to implementation detail
until the user selects that phase for detailing.

---

## 9. Done for this scoping document

Before handing over a scoped plan, check:

- [ ] Plan is a folder `PLANS/<slug>/` with `full-plan.md`; no monolith.
- [ ] A phase status table exists and marks exactly one `active` phase (or all `planned` if not started).
- [ ] User goal, non-goals, and target bar are stated.
- [ ] Current state is grounded in real docs/code, with no invented APIs.
- [ ] Work is split into coherent, manageable phases with dependencies, exit state, and a move-on gate each.
- [ ] Phase TODOs are specific enough to discuss but not enough to implement blindly.
- [ ] Non-phase sections carry enough operational discipline for a weaker implementer.
- [ ] Open questions are explicit.
- [ ] Later detailed expansion is delegated to `PLAN-PHASE-DETAILING.md`.
