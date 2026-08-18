This plan is complete. P0-P3 are all done, compressed into `done/`, and user-confirmed
(`ROADMAP.md` R1.5 flipped to `valmis`). There is no active phase here and nothing left
to implement in this plan.

---

Before starting new work, note one thing surfaced while closing this plan out: the
`interrogation-ui` plan's own status table
(`AGENT-INSTRUCTIONS/PLANS/interrogation-ui/full-plan.md`) still lists Phase P2 as
`active`, but P2's code was already implemented and committed (`57976b9`, `ad7dbbe`)
before this `mode-selector` plan (R1.5) interrupted it. `interrogation-ui/phases/
P2-interrogation-chat-screen.md` is still `Status: active` too - neither was compressed
into `done/` or browser-verified against P2's own move-on gate ("full session runs
through all 7 areas to completion"). Per `../../BUILDING/WORKING-FROM-PLANS.md` ("If the
plan and code disagree, stop and surface it"), do not silently resolve this - confirm
with the user whether P2 is actually finished (run its `User test`), then either compress
it into `done/` and detail P3 ("Report screen") forward, or fix whatever is actually
missing.
