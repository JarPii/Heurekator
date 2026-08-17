# WORKING-FROM-PLANS.md - Working From Plans

Most non-trivial work here is driven by a plan. When the user points you at a plan,
these rules apply.

For the actual session prompts that run this loop one phase at a time — reviewing a
finished phase and detailing the next, or implementing one already-detailed phase — see
[`../PLANNING/IMPLEMENTATION-PRIMERS.md`](../PLANNING/IMPLEMENTATION-PRIMERS.md). This
file is the rules; that one is the copy-paste sessions that apply them.

---

## 1. Plan execution rules

- **Load the right files, and only those.** A plan is a folder `AGENT-INSTRUCTIONS/PLANS/<slug>/`. For a work session read `full-plan.md` (top matter + design rules + the phase status table) plus the one `phases/<id>.md` file the status table marks `active`, and any `done/<id>.md` frozen contracts it depends on. Do not load the whole plan history or other phase files — that bounded context is what keeps a weak model from forgetting and hallucinating. Re-read these before each session and periodically during long ones; treat the phase file's file lists, signatures, and MUST NOT rules as binding.
- **The status table is the source of truth for progress.** Exactly one phase is `active`. Do not start a phase the table has not promoted.
- **One phase at a time.** Do not start a phase until the previous phase's verification passes. Commit one phase per commit.
- **Complete the phase's Completion checklist (gate) before the next phase.** If a phase carries a Completion checklist, every item must be checked and its verification must pass before the next phase starts. Never tick a box you have not actually verified.
- **Honor the phase's gate level.** Detailed phases declare `minimal`, `standard`, `full`, or `security`. Treat that as the minimum verification/review bar from `PLAN-PHASE-DETAILING.md`; add stricter checks when the code or risk demands it.
- **Run the phase's User test with the user, then compress.** Every phase file has a `User test` section, which must state *why* it's needed (automation can't reach it, redundant confirmation, or N/A — `PLAN-PHASE-DETAILING.md` §8b), not just what to do. Hand those steps to the user and get confirmation before moving on. On confirmation, compress the phase file into `done/<id>.md` (frozen contract only) and flip the status table row to `done`. Keep `done/<id>.md` to the **decisions, invariants, and contract guarantees** a later phase depends on — not re-stated signatures or config values. If this repo maintains seam/config index docs (see `../PROJECT.md` §2), exact signatures and config values live there, not duplicated into `done/`; otherwise point at the real source file instead of restating it (one source of truth — `../PROJECT.md` §4).
- **Hand off the next phase to a fresh session.** After compressing and detailing forward (Primer A in `../PLANNING/IMPLEMENTATION-PRIMERS.md`), write `PLANS/<slug>/NEXT-SESSION.md` with the filled-in Primer B for the new phase, then commit and push. Implementing that phase starts in a clean session that reads only that file — it doesn't need this session's review/detailing history, so it shouldn't pay for it.
- **Shape vague phases before writing the pre-implementation spec.** When the active phase is still broad, first discuss/record the outcome, boundaries, tradeoffs, and open questions. Then write the spec from current code: exact files, new/changed signatures copied to match real surrounding code, migration filename, and test names. If you cannot write that from the code, you are not ready. Read more first.
- **Do exactly the phase's scope, no more.** Plans deliberately defer things. Do not pull future features forward, and do not improve unrelated code while you are there.
- **If the plan and code disagree, stop and surface it.** Do not silently reinterpret the plan or quietly diverge.
- **Match the phase's exit criteria literally.** "Behavior unchanged" means the app must look and act identically. Verify; do not assume.

---

## 2. Pre-implementation spec

Before coding a phase, write a short spec from current code. Include:

- exact file paths to edit;
- exact existing signatures/classes/routes/tables/config keys read from code;
- exact before -> after signatures for changed functions;
- gate level and why that level fits the phase risk;
- every caller/wiring point that must change;
- migration filename and schema/version convention if schema changes;
- test files and test names;
- permanent docs that need behavior updates;
- explicit MUST NOT rules for this phase.

If you cannot write this from current code, keep reading. If a named symbol does not
exist, stop and surface the drift.

---

## 3. Phase scope and chunk boundaries

- Phases should be one coherent session and one commit when possible. Cohesive multi-file slices are fine; do not split only because more than one file changes.
- Later phases must consume real frozen contracts, not guessed signatures.
- At chunk boundaries, validate behavior, freeze real APIs/schema/config, and rewrite downstream phase details.
- If a phase is genuinely too large or crosses unrelated seams after reading code, split it before implementing and state why. Do not split reflexively into one-file phases.

---

## 4. Common failure mode

Renaming or relocating a big file and calling it "modularized" is not enough.
Splitting means state and responsibility actually move into smaller units with clear
contracts, not the same blob under a new name.

---

## 5. Verification for planned work

Before claiming a phase done, run the backend baseline defined in
`AGENT-INSTRUCTIONS/BUILDING/VERIFICATION-COMMITS-DEPLOY.md` §1 (the canonical command
list), plus the touched-module tests, plus the frontend build if frontend changed.
Tests must not need real provider keys or network.

---

## 6. Planning priority

The priority order is the one in `AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md` §9, with one
plan-specific addition: **stay inside the active phase's scope** (slots in at priority 3,
after the user request and the invariants/no-hack rules, before "keep changes small"). Do
not restate the full list here; read `REPO-RULES.md` §9.
