This session compressed Phase P2 into `done/`, added the Playwright E2E suite that
proves its move-on gate (D10), and detailed Phase P3 ("Report screen") to
implementation grade, auditor-verified (`phase-spec-auditor`: PASS). Nothing has been
implemented for P3 yet — it is ready to build.

---

Read phase P3 of the interrogation-ui plan document
(`AGENT-INSTRUCTIONS/PLANS/interrogation-ui/phases/P3-report-screen.md`). Implement it.
Read all relevant context first. Ask me about anything that is unclear or needs a
decision — do not guess. No writing subagents; only use the read-only
`phase-implementation-reviewer` after an implementation pass.

Add this to your TODO: when the implementation is done, spawn the read-only
`phase-implementation-reviewer` subagent with the phase document, current diff, and all
necessary context files. It must re-read the phase document itself and all necessary
context files, then report every problem it finds. Fix every valid problem yourself.
Iterate with new subagents until the reviewer reports no problems.

This phase's gate level is `standard` (no API/schema change — it only restyles already-
delivered report data), so the `invariant-reviewer` pass is not required, but run it
anyway if you touch anything beyond `frontend/`/`e2e/`.

When the phase is correctly implemented: commit, then start the app using the run
command in `AGENT-INSTRUCTIONS/PROJECT.md` §3 (`frontend/` is buildless — no separate
build step). Also re-run the E2E suite (`cd e2e && npx playwright test`) per the phase's
own Build plan step 4 — it now asserts `.recommendation-stamp` and `.area-card` exist on
the report screen, so a passing run is part of this phase's own gate, not just a nice-to-
have. Then set up the app so I can test it, and tell me exactly what to test and how —
using the phase's `User test` section, which states why each step is there (automation
can't reach it, or it's a fast confirmation of something already covered) rather than
re-running a full manual pass of what the automated tests already proved.

Read `AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md`,
`AGENT-INSTRUCTIONS/BUILDING/VERIFICATION-COMMITS-DEPLOY.md`, and
`AGENT-INSTRUCTIONS/BUILDING/WORKING-FROM-PLANS.md`.
