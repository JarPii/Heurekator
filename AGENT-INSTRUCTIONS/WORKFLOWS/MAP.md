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

No E2E test suite exists yet (see `../PROJECT.md` §3), so these reference the FastAPI
route handlers themselves rather than spec files — the literal route path is the
matched text.

1. `app/main.py` — `/api/sessions` — user submits an idea; the engine returns the first
   question for the first `Area`.
2. `app/main.py` — `/api/sessions/{session_id}/answer` — user answers; the engine
   evaluates the answer and returns either another question on the same `Area`, the
   first question of the next `Area`, or the final `Report` once every `Area` is
   resolved.
3. `app/main.py` — `/api/sessions/{session_id}` — fetch a session's full current state
   (used for debugging; not part of the frontend's normal flow — see `README.md`).
