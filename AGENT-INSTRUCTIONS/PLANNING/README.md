# PLANNING — turning requirements into implementable phases

Authoring and detailing plans. Executing a detailed phase is a build activity, not a
planning one: `../BUILDING/WORKING-FROM-PLANS.md`.

**Before authoring anything, read `../BUILDING/REPO-RULES.md`.** Its no-hack /
read-before-write discipline IS the authoring mentality: do not invent files, signatures,
routes, tables, or scope; read the real code first and stop-and-ask when a named thing
does not exist. A plan that defers cleanly beats one that papers over unknowns.

## Pick your task — then read the matching guide before you act

You are not ready to write until you have read the guide for what you are doing:

- **Just ran `adopt.sh` on a new empty project?** → read **`VISION-PRIMER.md`** first.
  Run the structured discovery interview with the developer to produce `VISION.md`,
  candidate domain terms, and first workflow entries. Only then move to scoping.
- **Just ran `adopt.sh` on an existing codebase?** → read **`BROWNFIELD-PRIMER.md`** first.
  The agent reads the existing code and fills in `PROJECT.md`, `DOMAIN/CONCEPTS.md`,
  and `WORKFLOWS/MAP.md` from what is actually there. Only ask the developer for gaps.
- **Turning requirements into a plan?** → read **`PLAN-AUTHORING-SCOPING.md`** first.
  If the idea is still fuzzy, start with that guide's research pass before writing the
  plan. Output: small, ordered, intentionally-vague TODO phases + a status table in
  `PLANS/<slug>/full-plan.md`. No implementation detail yet.
- **Making one phase implementable?** → read **`PLAN-PHASE-DETAILING.md`** and copy
  **`phase-template.md`**. The phase must name real files, signatures, callers,
  migrations, and tests so a weak model invents nothing. If you cannot write that from the
  code, you are not done reading the code.
- **A phase failed its retest?** → read **`PLAN-PHASE-REMEDIATION.md`**. Keep the working
  parts, re-detail the fix in place to full grade. Do not restart; do not just append a
  bug list.
- **Running a plan one phase at a time?** → **`IMPLEMENTATION-PRIMERS.md`** has the two
  copy-paste sessions: Primer A (review a finished phase, detail the next), Primer B
  (implement one detailed phase).

## Cross-references

- Plan-folder convention (what to load, never a monolith): `../PLANS/README.md`.
- Executing a detailed phase: `../BUILDING/WORKING-FROM-PLANS.md`.
- Subagents that offload detailing/review reads: `../SUBAGENTS/README.md`.
