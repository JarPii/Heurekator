# WORKFLOWS/MAP.md — the compact, binding index

Read [`../WORKFLOWS/README.md`](README.md) first — it explains why this is an index
over use cases (which live as this project's automated E2E specs, see `../PROJECT.md`
§2-§3) rather than a second description of them.

**Format rules (do not deviate — `../SCRIPTS/check-workflow-map.sh` parses this
literally):**

- Everything below the `## Workflows` heading is machine-parsed. Keep prose/instructions
  above it, as here.
- One heading per workflow: `### <Workflow name>`, followed by a numbered list — the
  order is the sequence an actor actually walks through.
- Each list item: `` 1. `<spec file>` — `<case name>` `` optionally followed by
  ` — <one-line note>`. The spec file path is relative to the repo root. The case name
  must appear as text inside that file (checked by
  `../SCRIPTS/check-workflow-map.sh`) — not restated behavior, just enough to identify
  which case.
- If a workflow needs more than an ordered list can carry, add a narrative file
  `WORKFLOWS/<workflow-slug>.md` and link it after the workflow's heading.
- Reordering, splitting, merging, or removing a step is a workflow-shape change — see
  `README.md`'s "The boundary with DECISIONS/LOG.md". Adding a use case to its obvious
  next slot is not.

## Workflows

### Idea runs through the Socratic loop

1. `e2e/tests/socratic-loop.spec.js` — `idea validation session runs through all 7 areas to the report` — mode select → mittakaava select → idea intake → all 7 areas (answer → evaluate → next question, or the area-cap advance after `MAX_ATTEMPTS_PER_AREA`) → final report.

`app/main.py` — `/api/sessions/{session_id}` (fetch a session's full current state) is
used for debugging only, not part of the frontend's normal flow (see `README.md`), so
it is not part of this workflow.
