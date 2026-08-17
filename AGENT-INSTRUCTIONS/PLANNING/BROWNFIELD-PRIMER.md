# BROWNFIELD-PRIMER.md - Onboarding AGENT-INSTRUCTIONS into an existing project

This guide is for the case where a project already has working code but no
`AGENT-INSTRUCTIONS/` yet. The `adopt.sh` script has already seeded the empty
template files. The job now is to fill them from the **actual code** — not from
memory, not from guesses.

This is the opposite of `VISION-PRIMER.md`: instead of interviewing the developer
about a future product, the agent reads an existing codebase and extracts what it
already knows.

---

## When to use this

Use this guide when:
- `AGENT-INSTRUCTIONS/` was just seeded by `adopt.sh` (Scenario 2a).
- `PROJECT.md §1` still contains `<placeholders>`.
- The project has existing code, tests, and possibly a deployed service.

Do **not** use this when starting a brand-new project — use `VISION-PRIMER.md`
instead.

---

## 1. Read before you write — the no-guess protocol

Every field filled in `PROJECT.md`, `DOMAIN/CONCEPTS.md`, and `WORKFLOWS/MAP.md`
must come from a concrete source in the repo. For each item below, the source is
listed explicitly. If the source doesn't exist, say so — do not invent it.

---

## 2. Fill in PROJECT.md — reading order

Work through `PROJECT.md`'s sections in this order. For each section, the agent
reads the listed sources before writing anything.

### §1 — What this repo is

Read:
- Top-level `README.md` (if any) — look for a one-paragraph project description.
- `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` — the `description`
  field and module name.
- The main entry point (e.g. `main.py`, `index.ts`, `cmd/`) — what does it start?

Write: one or two sentences naming the product, its purpose, and its users.
If multiple services exist, name them. If it is unclear, write what is observable
and flag the gap.

Development model: count contributors in `git log --format='%ae' | sort -u` and
look for branch conventions in `.github/` or a `CONTRIBUTING.md`.

### §2 — Layout

Read:
- Top-level directory listing.
- Any existing architecture or `ARCHITECTURE.md` / `docs/` files.
- `docker-compose.yml` / `Procfile` / `fly.toml` / Kubernetes manifests — for
  services, ports, and deployed processes.

Write: a `tree`-style layout of the meaningful top-level directories plus any
services. List stable docs that describe subsystems; if none exist, say so.

### §3 — Canonical verification commands

Read:
- `Makefile` — look for `test`, `build`, `lint`, `e2e` targets.
- `package.json` — `scripts` block.
- `pyproject.toml` / `pytest.ini` / `setup.cfg` — test configuration.
- `go.mod` — look for `go test ./...` usage in CI files.
- `.github/workflows/*.yml` — what the CI actually runs; this is the most reliable
  source because it proves the commands work.

Write: the exact commands, copied verbatim. Note any prerequisites (env vars,
services, seed data). Do not invent commands — only copy ones that exist.

### §4 — Hard invariants

Read:
- Auth / permission middleware (look for `@require_auth`, `middleware/auth*`,
  `guard`, `policy`, `can?`).
- Data access layer — are there "safe view" wrappers or row-level security?
- Secret handling — look for `.env.example`, secret management config, how keys
  are injected.
- AI / automation write paths — does any code path write user data automatically?
- Dev fixtures — are there seeding scripts that could corrupt production if run
  there?

Write: numbered invariants — one per concrete rule discovered. Prefer "data X
must only be accessed through Y" over generic statements. If an area has no clear
invariant from the code, say so explicitly rather than inventing one.

### §5 — Deploy

Read:
- `fly.toml` / `Dockerfile` / `Procfile` / `.github/workflows/deploy*.yml`.
- Any `DEPLOY.md` or `ops/` directory.

Write: where it deploys, the command, and any fallback paths the code explicitly
handles.

---

## 3. Fill in DOMAIN/CONCEPTS.md

Read:
- Model/schema files (`models.py`, `schema.prisma`, `*.proto`, `types.ts`,
  `entities/`).
- Domain-specific type names, enum values, and state machine states.
- Any existing glossary, data dictionary, or `GLOSSARY.md`.

For each significant noun the codebase uses:
- Write it as a `### Term` heading.
- Write a one-sentence definition from what the code actually does, not from
  general knowledge.
- If the definition references another term in the file, use `[[Term]]` syntax.
- If the term's meaning was a choice between alternatives (e.g. "session" could
  mean a browser session or a DB record — the code picks one), flag it for a
  `DECISIONS/LOG.md` entry.

Do not add a term you cannot support with a specific file and line.

---

## 4. Fill in WORKFLOWS/MAP.md

Read:
- E2E / integration test files (`tests/e2e/`, `cypress/`, `playwright/`,
  `features/*.feature`).
- The E2E test names are the use-case names — copy them verbatim.
- If no E2E tests exist, read the main user-facing routes
  (`routes/`, `pages/`, `views/`, `controllers/`) and derive use cases from
  handler names and HTTP method + path combinations.

For each user-facing workflow:
- Group related use cases under one `### Workflow name` heading.
- List them in the order a user would actually walk through them.
- Use the format `` 1. `<spec file>` — `<case name>` `` exactly.
- If no spec file exists yet, write the case name only and mark it `(no spec yet)`.

---

## 5. Ask the developer for what cannot be read from code

After completing steps 2–4, list what is still missing or ambiguous:

- Any `<placeholder>` that survives in `PROJECT.md` after the reading pass.
- Hard invariants the code suggests but does not make explicit (e.g. "it looks
  like user data is never written by automation — is that intentional?").
- Workflow steps that exist in the UI but have no test coverage.
- Model fields whose semantics are unclear from names alone.

Ask only about gaps. Do not re-ask about things already found in the code.

---

## 6. Verify and commit

```bash
# Run from the project root (AGENT-INSTRUCTIONS/ is a subdirectory)
AGENT-INSTRUCTIONS/SCRIPTS/check-portability.sh
AGENT-INSTRUCTIONS/SCRIPTS/check-domain-concepts.sh
AGENT-INSTRUCTIONS/SCRIPTS/check-decision-log.sh
AGENT-INSTRUCTIONS/SCRIPTS/check-workflow-map.sh

# Regenerate agent files if SUBAGENTS/ changed
python3 AGENT-INSTRUCTIONS/SCRIPTS/gen_agents.py
```

All four checks must pass before committing. A stale `[[Term]]` reference or a
workflow entry pointing at a missing spec file is a real error, not a warning.

---

## 7. Copy-paste primer — brownfield onboarding session

Send this message to start a brownfield onboarding session:

> I have an existing project and I've just seeded `AGENT-INSTRUCTIONS/` into it
> using `adopt.sh`. I'd like you to run the brownfield onboarding process from
> `AGENT-INSTRUCTIONS/PLANNING/BROWNFIELD-PRIMER.md`:
> read the codebase and fill in `AGENT-INSTRUCTIONS/PROJECT.md`,
> `AGENT-INSTRUCTIONS/DOMAIN/CONCEPTS.md`, and `AGENT-INSTRUCTIONS/WORKFLOWS/MAP.md`
> from what you actually find in the code. After the reading pass, tell me what
> gaps remain that need my input. Do not invent anything — only write what the
> code supports.

---

## 8. Cross-references

- Starting a new project instead: `VISION-PRIMER.md`.
- Turning the filled-in PROJECT.md into a plan: `PLAN-AUTHORING-SCOPING.md`.
- Running the adoption script: `../SCRIPTS/adopt.sh`.
- Syncing upstream engine updates later: `../SCRIPTS/pull-instructions.sh`.
