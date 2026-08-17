# Implementation primers

Two copy-paste primer messages for running a plan one phase at a time. They encode the
loop that the planning guides describe, so each session starts with the right framing
and the right files. Fill the placeholders and send.

- `<plan>` — the plan slug or short name (e.g. "router", `ai-router-and-roadmap-plan`).
- `<phase-id>` — the phase id from the `full-plan.md` status table (e.g. `D12.3d.1`).

The two roles are deliberate: a strong model **reviews + advances** the plan (judging
correctness and detailing the next phase), a weak model **implements** one already-detailed
phase. Keep them separate; do not ask the weak model to detail or to judge "is this up to
standard" — that is the strong model's job.

---

## Primer A — strong model: review the finished phase, then advance the plan

> Phase `<phase-id>` of the `<plan>` plan is implemented. Verify it is correct and up to
> repo standards: no dead code, no unrequested "innovations" or scope creep, no tech
> debt, and the permanent docs are current. Read the phase document and all the context
> it touches before judging.
>
> If everything is correct: compact this phase into `done/` (frozen
> contract only), flip its `full-plan.md` status row to `done`, then detail forward —
> promote and write a `phases/` document for each subsequent phase up to and
> including the next one that still has unmet requirements. Each detailed phase must be
> ACTUALLY small-model implementable: re-read it against the real code and rewrite it
> until an implementer could follow it without inventing or deciding anything.
>
> Once the next phase is detailed, write `AGENT-INSTRUCTIONS/PLANS/<plan>/NEXT-SESSION.md`:
> one line on what this phase completed, then Primer B copied from
> `AGENT-INSTRUCTIONS/PLANNING/IMPLEMENTATION-PRIMERS.md` with `<plan>` and `<phase-id>`
> filled in for the new phase. Overwrite any previous `NEXT-SESSION.md` — only one phase
> is ever active. Commit and push before ending the session. Tell me the file is ready
> and that I can start a fresh session there — implementing the next phase does not need
> this session's review/detailing history, so it shouldn't carry the cost of it.
>
> If it is NOT correct: compact ONLY the working parts into the frozen contract, add new
> remediation sub-phases for what is broken, and give me a summary of what needs fixing.
> Do NOT do the fixes yourself. For very small discrepencies, like one stale document or
> a couple one-line changes, you can fix them independently and continue as if the
> implementation was correct.
>
> Read `AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md`,
> `AGENT-INSTRUCTIONS/BUILDING/WORKING-FROM-PLANS.md`,
> `AGENT-INSTRUCTIONS/PLANNING/PLAN-PHASE-DETAILING.md`, and — if remediating —
> `AGENT-INSTRUCTIONS/PLANNING/PLAN-PHASE-REMEDIATION.md`. To resolve any exact
> signature, read the doc `AGENT-INSTRUCTIONS/PROJECT.md` §2 names for that (if any)
> instead of grepping.
> You should delegate research to the `seam-scout` subagent, run `invariant-reviewer` over
> the finished phase, and run `phase-spec-auditor` over each phase you detail.

---

## Primer B — weak model: implement one detailed phase

> Read phase `<phase-id>` of the `<plan>` plan document. Implement it. Read all relevant context first. Ask me about anything that
> is unclear or needs a decision — do not guess. No writing subagents; only use the
> read-only `phase-implementation-reviewer` after an implementation pass.
>
> Add this to your TODO: when the implementation is done, spawn the read-only
> `phase-implementation-reviewer` subagent with the phase document, current diff, and
> all necessary context files. It must re-read the phase document itself and all
> necessary context files, then report every problem it finds. Fix every valid problem
> yourself. Iterate with new subagents until the reviewer reports no problems.
>
> When the phase is correctly implemented: commit, then rebuild using the dev-stack
> command in `AGENT-INSTRUCTIONS/PROJECT.md` §5. Then set up the app so I can test it,
> and tell me exactly what to test and how — using the phase's `User test` section,
> which states why each step is there (automation can't reach it, or it's a fast
> confirmation of something already covered) rather than re-running a full manual
> pass of what the automated tests already proved.
>
> Read `AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md`,
> `AGENT-INSTRUCTIONS/BUILDING/VERIFICATION-COMMITS-DEPLOY.md`, and
> `AGENT-INSTRUCTIONS/BUILDING/WORKING-FROM-PLANS.md`.

---

## Notes

- Primer A's "detail forward" step is governed by `PLAN-PHASE-DETAILING.md`; it may
  legitimately stop after one phase if the next phase needs user decisions first.
- Primer B assumes the phase is already detailed to implementation grade. If the phase
  document still contains choices ("pick one of", "debug first"), it is not ready —
  send it back through Primer A, do not implement it.
- The dev rebuild command and baseline test commands an implementer must pass are in
  `AGENT-INSTRUCTIONS/PROJECT.md` §3 and §5.
- **`PLANS/<slug>/NEXT-SESSION.md` is the handoff, not a permanent doc.** It exists only
  so a fresh session can start Primer B from git alone, without inheriting the Primer A
  session's review/detailing context and its token cost. It gets overwritten every
  cycle — there is never more than one next phase to hand off, matching the one-`active`
  row in `full-plan.md`.
- **This file lives in `PLANNING/`, not `BUILDING/`, even though Primer B is a
  build-time activity.** Primer A is a PLANNING-stage activity (review + detail-forward);
  the file serves both roles in one place, and moving it would only relocate the
  discoverability problem to the other side. `BUILDING/README.md` and
  `BUILDING/WORKING-FROM-PLANS.md` cross-reference it instead of it moving.
