# PLANS

Working plans live here. A plan is a **folder**, not a single file — the folder
convention (`full-plan.md` / `phases/<id>.md` / `done/<id>.md`) and its rules are
defined once in [`../PLANNING/PLAN-AUTHORING-SCOPING.md`](../PLANNING/PLAN-AUTHORING-SCOPING.md)
§0; read that instead of this file repeating the diagram.

- Author `full-plan.md` first: `../PLANNING/PLAN-AUTHORING-SCOPING.md`.
- Detail the active phase into `phases/<id>.md`: `../PLANNING/PLAN-PHASE-DETAILING.md`.
- If a phase lands but fails its retest, re-detail the same `phases/<id>.md` in place per
  `../PLANNING/PLAN-PHASE-REMEDIATION.md` (keep working parts, fix steps at full grade) —
  do not restart, do not just append a bug list.
- Execute a detailed phase: `../BUILDING/WORKING-FROM-PLANS.md`.
- See every plan's status table (plus decisions and vision) in one place without
  opening each `full-plan.md`: `../README.md` "Optional: status dashboard"
  (`../SCRIPTS/gen_dashboard.py`). Keep the phase status table current — it is what
  the dashboard reads.

## Legacy plans

No flat legacy plans remain in this directory. New plans should continue using the
folder layout defined in `PLAN-AUTHORING-SCOPING.md` §0.

## Why this folder is generic

`PLANS/README.md` (this file) is the portable method and travels unchanged, like
`DECISIONS/README.md`, `DOMAIN/README.md`, and `WORKFLOWS/README.md`. The plan folders
themselves (`full-plan.md`, `phases/<id>.md`, `done/<id>.md`) are expected to be full of
this project's own scope and file paths, so — like `DECISIONS/LOG.md`,
`DOMAIN/CONCEPTS.md`, and `WORKFLOWS/MAP.md` — they are deliberately excluded from
`../SCRIPTS/check-portability.sh`'s scan.
