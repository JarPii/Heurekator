This session compressed Phase P1 into `done/P1-idea-intake-screen.md` and detailed
Phase P2 ("Interrogation (chat) screen") to implementation grade, auditor-verified.
Nothing has been implemented for P2 yet — it is ready to build.

---

Read phase P2 of the interrogation-ui plan document
(`AGENT-INSTRUCTIONS/PLANS/interrogation-ui/phases/P2-interrogation-chat-screen.md`).
Implement it. Read all relevant context first. Ask me about anything that is unclear or
needs a decision — do not guess. No writing subagents; only use the read-only
`phase-implementation-reviewer` after an implementation pass.

Add this to your TODO: when the implementation is done, spawn the read-only
`phase-implementation-reviewer` subagent with the phase document, current diff, and all
necessary context files. It must re-read the phase document itself and all necessary
context files, then report every problem it finds. Fix every valid problem yourself.
Iterate with new subagents until the reviewer reports no problems.

This phase's gate level is `full` (it changes `POST /api/sessions/{id}/answer`'s
response shape, per decision D6) — also spawn the read-only `invariant-reviewer`
subagent before considering the phase done, per the phase document's own completion
checklist.

When the phase is correctly implemented: commit, then start the app using the run
command in `AGENT-INSTRUCTIONS/PROJECT.md` §3 (`frontend/` is buildless — there is no
separate build step for this phase). Then set up the app so I can test it, and tell me
exactly what to test and how — using the phase's `User test` section, which states why
each step is there (automation can't reach it, or it's a fast confirmation of something
already covered) rather than re-running a full manual pass of what the automated tests
already proved.

Read `AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md`,
`AGENT-INSTRUCTIONS/BUILDING/VERIFICATION-COMMITS-DEPLOY.md`, and
`AGENT-INSTRUCTIONS/BUILDING/WORKING-FROM-PLANS.md`.
