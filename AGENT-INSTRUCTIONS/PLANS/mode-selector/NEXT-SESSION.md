This session compressed Phase P1 and Phase P2 into `done/`, and detailed Phase P3
("Area-cap advance signal") to implementation grade. Nothing has been implemented for
P3 yet — it is ready to build.

---

Read phase P3 of the mode-selector plan document
(`AGENT-INSTRUCTIONS/PLANS/mode-selector/phases/P3-area-cap-advance-signal.md`).
Implement it. Read all relevant context first. Ask me about anything that is unclear
or needs a decision — do not guess. No writing subagents; only use the read-only
`phase-implementation-reviewer` after an implementation pass.

Add this to your TODO: when the implementation is done, spawn the read-only
`phase-implementation-reviewer` subagent with the phase document, current diff, and
all necessary context files. It must re-read the phase document itself and all
necessary context files, then report every problem it finds. Fix every valid problem
yourself. Iterate with new subagents until the reviewer reports no problems.

This phase's gate level is `standard` (no API/schema change — the signal is inferred
client-side from fields P2 already returns), so the `invariant-reviewer` pass is not
required, but run it anyway if you touch anything beyond `frontend/`.

When the phase is correctly implemented: commit, then start the app using the run
command in `AGENT-INSTRUCTIONS/PROJECT.md` §3 (`frontend/` is buildless — there is no
separate build step for this phase; if you add or change any file under `frontend/`,
bump the `?v=N` cache-busting query string on `frontend/index.html`'s `style.css`
link — currently `?v=4` — the browser has twice been seen serving a stale cached copy
otherwise). Then set up the app so I can test it, and tell me exactly what to test and
how — using the phase's `User test` section, which states why each step is there
(automation can't reach it, or it's a fast confirmation of something already covered)
rather than re-running a full manual pass of what the automated tests already proved.

Read `AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md`,
`AGENT-INSTRUCTIONS/BUILDING/VERIFICATION-COMMITS-DEPLOY.md`, and
`AGENT-INSTRUCTIONS/BUILDING/WORKING-FROM-PLANS.md`.
