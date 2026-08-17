# Agent instructions

This repo's build rules, planning process, and decision record live in
`AGENT-INSTRUCTIONS/`. They are not optional background reading — they are the
operating instructions for any agent working here.

## Read at the start of every session

1. `AGENT-INSTRUCTIONS/PROJECT.md` — what this repo is, its layout, the canonical
   test/build commands, and the hard invariants (§4) that must never be violated.
2. `AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md` — the operative rules for all work:
   discuss-before-acting, no-hack discipline, read-before-write, errors that reach the
   user, and the review checklist to run before finishing.

Read `AGENT-INSTRUCTIONS/DECISIONS/LOG.md` before touching an area that already has a
row there — it records what was rejected and why, so a settled question is not reopened
by accident.

## Read when the task calls for it

| Situation | Read |
|---|---|
| Executing a plan phase | `AGENT-INSTRUCTIONS/BUILDING/WORKING-FROM-PLANS.md` |
| Turning requirements into a plan | `AGENT-INSTRUCTIONS/PLANNING/PLAN-AUTHORING-SCOPING.md` |
| Making one phase implementable | `AGENT-INSTRUCTIONS/PLANNING/PLAN-PHASE-DETAILING.md` |
| A bug, flake, or unexplained behavior | `AGENT-INSTRUCTIONS/BUILDING/DEBUGGING.md` |
| Verifying, committing, deploying | `AGENT-INSTRUCTIONS/BUILDING/VERIFICATION-COMMITS-DEPLOY.md` |
| Designing anything in this domain | `AGENT-INSTRUCTIONS/DOMAIN/CONCEPTS.md` |
| Adding a use case | `AGENT-INSTRUCTIONS/WORKFLOWS/MAP.md` |

`AGENT-INSTRUCTIONS/BUILDING/README.md` and `AGENT-INSTRUCTIONS/PLANNING/README.md`
route to the rest.

## This file

Seeded once by the AGENT-INSTRUCTIONS installer and never overwritten by a sync — it
belongs to this repo. Add project-specific agent guidance here; keep the portable
process rules in `AGENT-INSTRUCTIONS/` where a sync can update them.
