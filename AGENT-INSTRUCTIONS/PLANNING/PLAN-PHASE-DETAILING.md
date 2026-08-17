# PLAN-PHASE-DETAILING.md - How to expand one scoped phase into implementation detail

This guide is for turning **one vague/scoped phase** from a first-pass plan into a
phase a weaker model can implement safely. It deliberately applies after
`PLAN-AUTHORING-SCOPING.md`, not during the initial requirements conversation.

> **Output target:** one implementation-grade phase file
> `AGENT-INSTRUCTIONS/PLANS/<slug>/phases/<id>-<title>.md`, detailed enough that the
> implementer can do exactly the written steps without inventing files, signatures,
> routes, tables, or tests, and a `User test` section the user runs to prove it works.
> Write only this one file; do not pre-write other phases.

---

## 1. Inputs

Start with:

- the one phase the status table in `full-plan.md` marks `active` (or the one being promoted to `active`);
- that phase's scoped entry and its neighbors from `full-plan.md`;
- the frozen contracts in `done/` that earlier phases left;
- any user answers to open questions;
- the code map named in `AGENT-INSTRUCTIONS/PROJECT.md` §2, if any;
- relevant architecture/security docs;
- current code, read directly before writing the detailed phase.

When a phase is still vague, do not jump straight to a mechanical build script. First
do a **phase-shaping pass**: discuss or briefly write the intended outcome, boundaries,
tradeoffs, open questions, and likely seams. Brainstorm enough to decide what belongs
in this phase and what is intentionally deferred, then turn the settled scope into the
implementation-grade file below. If the user has already supplied explicit decisions,
record those decisions instead of reopening them.

Do not detail multiple vague phases at once unless the user explicitly asks. The goal
is a coherent implementation session, not the smallest possible diff. Set the selected
phase to `active` in the status table and create exactly one `phases/<id>-<title>.md`
file for that active phase.

---

## 2. Research protocol

Before writing the detailed phase:

1. Read `AGENT-INSTRUCTIONS/PROJECT.md` §2 and any code map it names.
2. Read the source vague phase and its neighboring phases for dependencies.
3. Shape the phase before detailing: name the user-visible / operator-visible outcome,
   the non-goals, and any decisions or tradeoffs that need user input.
4. Open every likely file named by the scoped phase.
5. Grep/read every function, class, route, table, config key, and test surface you expect to mention.
6. Confirm whether earlier phases have changed contracts since the scoped plan was written.
7. If code and the vague phase disagree, stop and report the drift instead of adapting silently.

The detailed phase must be based on current code, not on memory or the vague phase's
guesses. The phase-shaping pass is for scope and tradeoffs; the final build steps still
must be concrete enough that the implementer invents nothing.

You may delegate the mechanical location/signature gathering (steps 4–5) to the
`seam-scout` subagent — it returns exact `file:line` defs, callers, covering tests, and
config from the seam/config indexes, keeping that read off the strong model. You still
compose and verify the detailed phase yourself. Once written, `phase-spec-auditor` can
check the phase is actually implementable before handoff.

---

## 3. Required output shape

Write a single phase using the skeleton in **`AGENT-INSTRUCTIONS/PLANNING/phase-template.md`**. Copy that
template into `AGENT-INSTRUCTIONS/PLANS/<slug>/phases/<id>-<title>.md` and fill every
placeholder from current code. The sections are, in order: heading + `Status` /
`Depends on` / `Scope` / `Gate level`; `Current state (verified)`; `Read first (do not invent)`;
`Build plan`; `Callers / wiring to update`; `Config / schema / migrations`;
`Rules / MUST NOT`; `Tests`; `Automated tests (E2E)` (when §8b applies); `User test`;
`Completion checklist (gate)`; `Exit`.

This is the place for exact detail. If the implementation model follows only those
bullets, the phase should complete.

---

## 3a. Gate levels

Every detailed phase must choose exactly one gate level. The level controls the minimum
review/verification required before the phase can be compressed to `done/` and the next
phase can start. Higher risk always wins; when unsure, choose the stricter level.

### `minimal`

Use for documentation-only changes, comments/docstrings, typo fixes, or behavior-neutral
mechanical edits that cannot affect runtime behavior.

Required gate:

- changed files re-read for accuracy;
- relevant docs links/paths checked;
- no tests required unless the edit changes generated docs, commands, or examples.

Do not use when code behavior, config, schema, permissions, UI behavior, deploy scripts,
or tests change.

### `standard`

Use for normal implementation phases with bounded runtime behavior and no security- or
data-access-sensitive changes.

Required gate:

- targeted tests for touched modules;
- canonical backend baseline from `VERIFICATION-COMMITS-DEPLOY.md` §1 when backend changed;
- frontend build when frontend changed;
- permanent docs updated when behavior changed;
- safety commit before handoff.

### `full`

Use when the phase changes cross-package contracts, migrations, durable state, AI routing
or tool behavior, frontend/backend API shape, plan-critical seams, or anything where a
fresh review can catch integration mistakes.

Required gate:

- everything in `standard`;
- explicit caller/wiring audit against current code;
- phase document re-read after implementation to catch missed requirements;
- invariant review before completion when hard invariants or permanent docs may be stale;
- user test confirmation for UI-bearing or workflow-visible phases.

### `security`

Use when the phase touches anything covered by a hard invariant in `../PROJECT.md` §4:
typically permissions, identity/auth, privacy settings, secrets/credentials, AI data
exposure, or destructive data operations.

Required gate:

- everything in `full`;
- explicit check against every relevant hard invariant in `../PROJECT.md` §4;
- deny-by-default / least-privilege negative test where applicable;
- no raw secret, token, or sensitive-payload logging;
- invariant-reviewer or equivalent fresh review before handoff.

Gate level affects minimum verification only. A phase may add stricter checks in its
Completion checklist.

---

## 4. Detail bar

Every detailed phase must enumerate:

- one gate level (`minimal`, `standard`, `full`, or `security`) and the reason for it;
- every file touched;
- every exact function/method/class changed;
- every before -> after signature change;
- every caller that must change, found by grep/read and listed explicitly;
- every construction/wiring point;
- every import/export change;
- every route shape or frontend API change;
- every config key and loader/validator change;
- every migration filename, table/function/view touched, and schema apply/version convention;
- every test file and test name;
- every automated end-to-end use-case spec required by §8b (spec file + case name), or an explicit deferral;
- every permanent doc update required by behavior changes.

Do not rely on "obvious" follow-up work. If it is needed, write it as a step.

---

## 5. Converting scoped TODOs into exact steps

For each TODO in the vague phase:

1. Locate the existing seam that owns it.
2. Decide whether the TODO is in scope for this phase or should remain deferred.
3. If in scope, write file-by-file steps in implementation order.
4. If deferred, name the honest seam or gate that defers it. Do not fake data.
5. Add tests that prove the behavior and prevent the regression that motivated the TODO.

Example conversion:

Scoped TODO:

- "Expose the job's retry count through the existing status poll."

Detailed step:

- "`backend/services/job_status.py`, `JobStatusService.status_for(...)` - include the
  latest retry count from the existing job-runs table in the returned payload; do not
  add a second results table. Update `routes/jobs.py` response shaping and the frontend
  consumer if the payload shape changes."

Then continue until callers, tests, docs, and gates are explicit.

---

## 6. No-invention protocol

Detailed phases exist because weak implementers invent APIs when plans are vague.
Prevent that directly:

- Never say "resolve the workspace" without naming the real function that resolves it.
- Never say "update callers" without listing the callers.
- Never say "add a route" without naming the dispatch file and route module shape.
- Never say "store it" without naming the table/store method or creating it in an explicit schema step.
- Never say "add config" without naming the config path and loader validation.
- Never say "use the existing service" without naming the service class/method.

If the needed symbol does not exist, either create it as an explicit step or stop and
ask. Do not assume the implementer will invent the right thing.

**The implementer invents nothing AND decides nothing.** The author must already KNOW the exact
change and where. That means:

- Prove the approach against the real code before writing the step; when reading is not conclusive
  (a runtime behavior, a value, which of two code paths is live), RUN it — repro script, live query,
  instantiate the object and call it, measure — until you can state one instruction. Do not ship a
  hypothesis ("likely", "should be").
- No deferred choices in a step: never "debug first", "pick one of", "choose", "if X then… else…",
  "try". If you are tempted to branch, you have not finished researching — collapse it to one step.
- Confirm the file/symbol you name is on the LIVE executing path (grep the caller; reject dead or
  duplicate copies). A step aimed at dead code is a silent failure.
- Give exact values, not ranges (a starting value the user explicitly deferred is the only exception,
  and you still pick it).
- A genuine product/authority/UX decision that cannot be settled by running the code is the USER's,
  not the implementer's — stop and ask (`AskUserQuestion`), then write the resolved instruction.

---

## 7. Keep phase scope small

The detailed phase should normally map to one coherent implementation session and one
commit. A good phase may touch several files when those files are part of one natural
vertical slice (for example: config schema + loader + one composition point + tests, or
one backend contract + its frontend consumer + docs). Do not split only because more
than one file changes.

Default to keeping the originally selected phase intact when it remains easy to explain
as one outcome and the build steps fit in one bounded session. Split only when the scope
would force the implementer to juggle unrelated decisions, separate behavior changes, or
too many seams at once. If it is merely a moderate, cohesive multi-file edit, keep it as
one phase.

If detailing reveals that the vague phase is genuinely too large, split it before
writing build steps.

Split when:

- backend and frontend can land independently behind a stable contract;
- migration and behavior change can be separated;
- implementation would touch unrelated seams;
- verification requires a deploy or human UI check before safe continuation;
- exact steps exceed what one weak model can hold.
- the phase contains multiple product/authority/UX decisions that need separate user discussion.

When split, update the scoped plan or write child phases (`D11.1`, `D11.2`, etc.) with
clear gates. Include one sentence explaining why the split is needed; do not split as a
habit or to create one-file phases.

---

## 8. Verification and gates

Every detailed phase ends with a hard gate. Include:

- exact targeted test commands for touched modules;
- the backend baseline (canonical command list in `AGENT-INSTRUCTIONS/BUILDING/VERIFICATION-COMMITS-DEPLOY.md` §1);
- frontend build if any frontend code changed;
- deploy/live validation if the scoped plan requires it;
- the `User test` section's manual steps (always present), plus explicit human browser verification for UI-bearing phases;
- safety commit before any human verification handoff.

Checklist items must be objectively verifiable. Avoid vague boxes like "works well".

Tests must not require real provider keys or network. Do not edit or delete tests just
to make them pass. If a test's intent changed, reconcile that deliberately in the
phase and explain why.

For UI-bearing phases, require a working-state commit before handing browser steps to
the user. The agent cannot see rendered UI, so browser behavior, visual appearance,
and interaction feel require human confirmation before the next dependent phase.

## 8a. Rules to include in detailed phases

Do not leave safety rules implicit. Write the rules relevant to this phase into
`MUST NOT` and gate items directly, as concrete file/symbol-level prohibitions.

The canonical lists are the **hard invariants** in `AGENT-INSTRUCTIONS/PROJECT.md` §4 and
the **no-hack rules** in `AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md` §1. Do not restate
them here — pull the ones this phase can plausibly violate and make them specific to the
code it touches. For example, a phase reading sensitive data must spell out which
invariant from PROJECT.md §4 gates that read; a phase adding config must say "no
hardcoded model/provider names" (REPO-RULES §1). When in doubt, re-read both.

---

## 8b. Automated use-case coverage (the automated test phase)

The manual `User test` proves a slice works once, by hand. It is not a regression net
and does not by itself show that every use case is covered. A `full`- or
`security`-gated phase that is UI-bearing or workflow-visible must therefore also turn
its use cases into **automated end-to-end tests** in this repo's E2E harness — the
harness, its test location, and its naming convention are named in `../PROJECT.md`
§2-§3. This automated coverage is a gate item, not optional follow-up.

**Enumerate use cases by derivation, not memory.** Completeness is not something you
recall; derive it from fixed axes so nothing silently drops:

1. **Actor × capability.** Cross each actor/role this phase's surface is exposed to
   (the catalog in `../PROJECT.md` §4) with each capability the phase adds or changes.
   Every cell yields an allowed-path case and a denied-path case.
2. **Lifecycle / workflow transitions.** Each step-to-step transition in the product
   workflow (`../PROJECT.md` §1) that this phase participates in is a use case.
3. **Path axes per workflow.** happy path; empty / partial / invalid input; wrong-role
   or unauthenticated; concurrent or repeated action (idempotency); upstream-dependency
   failure. Include only axes that can actually occur here, and justify any you drop.

**Coverage table.** List the derived use cases and track each to closure. A row is done
only when every column is filled or explicitly deferred with a reason:

| Use case (actor + intent) | Described | Manual User test | Automated E2E |
|---|---|---|---|
| <role> does X — allowed | scoped | step N | `<repo E2E spec>` |
| <role> blocked from X — deny | scoped | step N | `<repo E2E spec>` |

The manual `User test` stays for what only a human can judge — visual appearance,
layout, interaction feel — and for cases the harness cannot yet reach. The automated
specs are the durable regression net. A `security`-gated phase must automate the
deny-by-default / least-privilege case (§3a), not merely describe it.

Automate first, then decide what's left for the human — do not derive it the other way
around. Every `User test` section must say *why* it exists (`phase-template.md`'s User
test bullet), as one of: **automation can't reach it** (visual/UX — the only kind
`VERIFICATION-COMMITS-DEPLOY.md` §3 actually requires a human for), **redundant
confirmation** (already proven by the automated specs above; ask for a fast look, not a
re-test), or **N/A** (no UI surface changed, automated/baseline tests already prove it —
the only case where the section may have no steps). Never write manual steps that repeat
what an automated spec in the same phase already proves.

Do not assert coverage you did not write. If a case cannot be automated in the current
harness, record it in the table as deferred with the honest reason, never as covered.

---

## 9. Permanent docs rule

If behavior changes, the detailed phase must name permanent docs to update: the code map
named in `AGENT-INSTRUCTIONS/PROJECT.md` §2, if any, and the relevant architecture doc.
Those docs must describe the new reality without referencing the plan, phase id, or
temporary roadmap.

If §8b applies and the new automated use-case spec is a step in an existing or new
workflow, `AGENT-INSTRUCTIONS/WORKFLOWS/MAP.md` is one of those permanent docs — add or
place the entry in the same change, not as a follow-up (`WORKFLOWS/README.md`).

Plans can mention phases. Code comments and permanent docs should not.

---

## 10. Done for detailed phase authoring

Before handing the detailed phase to an implementer, verify:

- [ ] It is a single `phases/<id>-<title>.md` file, and the status table marks that phase `active`.
- [ ] It expands exactly one selected scoped phase, or explicitly splits it.
- [ ] Current state is verified against the tree.
- [ ] Every symbol/table/route/config key named is real or created by an earlier explicit step.
- [ ] Every caller, wiring point, migration, test, and doc update is listed.
- [ ] No duplicate pipeline/store/path is introduced unless the requirement explicitly demands one.
- [ ] Permission and data-safety invariants are written into `MUST NOT` and checklist items.
- [ ] Verification commands and phase gate are explicit.
- [ ] A `User test` section gives concrete manual steps and expected results.
- [ ] If §8b applies, the use-case coverage table is filled and every required automated E2E spec is named (spec file + case), or its deferral is justified.
- [ ] The gate includes compressing to `done/<id>.md` and flipping the status row once the user confirms.

---

## 11. After planning

Explain to the user what the implementation of the plan actually accomplishes.
Do not use too technical terms, focus more on the core IDEA and the actual user 
experience of the changes.

---

## 12. When a detailed phase lands but fails verification

This guide covers expanding a *fresh* scoped phase. When a phase was already detailed,
implemented, and then **failed its `User test` / owner retest** (or shipped latent defects), do
not re-author from scratch and do not just append a bug list. Use
`PLAN-PHASE-REMEDIATION.md`. It defines how to:

- keep and **compact the working parts** into a "do not rebuild" list;
- diagnose every reported symptom down to a root cause at file:line, plus hunt **latent defects**
  and **tech debt** the implementation created;
- **re-detail the fixes to the same implementation grade as this document requires** — every fix
  step names real files/symbols, before→after signatures, caller ripples, schema/config, and
  tests, so a weak model can implement the fix without inventing anything.

The bar is identical: a fix step that only describes what is wrong is incomplete. Fix steps must
meet §4 (detail bar) and §6 (no-invention protocol) exactly as original build steps do. The phase
stays `active` and stays one `phases/<id>-<title>.md` file through remediation.
