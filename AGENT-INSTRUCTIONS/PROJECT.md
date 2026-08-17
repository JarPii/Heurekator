> **FROZEN TEMPLATE — do not edit.** This is the diff baseline
> `SCRIPTS/check-portability.sh` compares `PROJECT.md` against. Editing this file
> defeats the check. Fill in `PROJECT.md` instead; this file exists only to stay blank.

# PROJECT.md - Heurekator

The one file that holds every repo-specific fact the rest of `AGENT-INSTRUCTIONS/`
points to. `BUILDING/`, `PLANNING/`, and `SUBAGENTS/` are portable process/engine docs
meant to be copied into any repo unchanged. `DECISIONS/`, `DOMAIN/`, `WORKFLOWS/`, and
`PLANS/` are only *partly* portable: each folder's own `README.md` is the generic
method and travels unchanged, but its payload — `DECISIONS/LOG.md` and any
`DECISIONS/<id>-*.md` narrative, `DOMAIN/CONCEPTS.md`, `WORKFLOWS/MAP.md`, and the plan
folders under `PLANS/` — is expected to be full of this project's own facts and is not
portable. This file (`PROJECT.md`) is what makes the portable docs apply to *this* repo.
When copying `AGENT-INSTRUCTIONS/` into a new project, rewrite this file first — the
rest should mostly not need touching.

**This is the one file this package ships that's meant to be rewritten per project.**
`PROJECT.template.md` sitting next to it is the frozen, untouched blank version — never
edit that one. `SCRIPTS/check-portability.sh` diffs this file against that template to
catch project-specific facts that leaked into a file that's supposed to stay generic —
scoped to the portable docs above, not to the payload files just named, which are
excluded by design. Run it before committing changes to anything outside this file.
Note this doesn't make `PROJECT.md` the *only* project-specific file a repo ends up
with — `DECISIONS/LOG.md`, `DOMAIN/CONCEPTS.md`, `WORKFLOWS/MAP.md`, `PLANS/` content,
and whatever other project-specific files a repo adds outside this package (a vision or
roadmap doc, its own lint/CI config) are project-specific too; they just aren't tracked
by this diff because they were never meant to be blank.

---

## 1. What this repo is

Heurekator runs a single idea through a structured, Socratic question-and-evaluation
loop instead of producing a passive validation report: every answer is scored against
fixed criteria, and a weak answer gets a follow-up question on the same subject area
instead of being accepted (see `Visio.md`). Built for internal use — the developer and
their own organization, not external users (`Visio.md` §6). A FastAPI backend
(`app/main.py`) drives the loop against an LLM and serves a minimal local web-chat
frontend (`frontend/`).

Development model: one developer (`git log --format='%ae' | sort -u` shows a single
author). No CI, no branch-naming convention, no multi-agent coordination exists yet —
see §6.

## 2. Layout

```text
Heurekator/
  app/                    FastAPI backend
    main.py                 HTTP routes; wires the LLM client, session store, and
                             engine together at import time
    models.py                pydantic schemas (Session, Evaluation, Report, ...)
    core/
      engine.py               orchestrates ask -> answer -> evaluate -> adapt -> next
      criteria.py              the 7 fixed subject areas + evaluation criteria names
                                (tunable here without touching engine.py)
      store.py                  SessionStore abstraction; JSONFileStore is the only
                                 implementation
    llm/
      base.py                   LLMClient abstraction
      factory.py                  picks a provider from the LLM_PROVIDER env var
      mistral_client.py            Mistral implementation (default), with 429
                                    rate-limit retry/backoff
      anthropic_client.py           Anthropic implementation (alternative)
    prompts/
      question.py, evaluation.py, report.py   one prompt-builder per pipeline stage
  frontend/                static HTML/JS/CSS chat UI, no build step, served via
                            FastAPI's StaticFiles mount at "/"
  data/sessions/            one JSON file per session, written by JSONFileStore
                             (gitignored — local runtime state, not source)
  AGENT-INSTRUCTIONS/        this package
  Visio.md                   the project's vision document (internal-use scope, v0.5)
  requirements.txt, .env.example, README.md
```

Services: a single FastAPI process (`uvicorn app.main:app`), default port 8000 — the
README notes this port is sometimes already taken locally (e.g. by VS Code) and to pass
`--port` in that case. No docker-compose, no queue, no separate services.

Stable docs to read before changing a subsystem: `README.md` (setup + API surface),
`Visio.md` (product vision and scope, v0.5 — internal use only). No `ARCHITECTURE.md`,
no maintained seam index, and no config index exist; this `PROJECT.md` §2 is currently
the closest thing to one.

`DECISIONS/LOG.md` — the append-only record of what was decided and rejected, and why.
Read it at the start of a session touching an area with prior entries; see
`DECISIONS/README.md` for the format and the stop rule that keeps rejected paths from
resurfacing.

`DOMAIN/CONCEPTS.md` — this project's own vocabulary: base terms and terms derived from
them, where the derivation itself carries the domain's natural constraints. Read it
before designing a solution so it doesn't generalize past what the domain actually
allows; see `DOMAIN/README.md`.

`WORKFLOWS/MAP.md` — an index of named workflows, each an ordered sequence of use-case
references into this project's own E2E specs (§3 below names the harness). Read it
before adding a use case, so it lands in its real sequence instead of as an orphan; see
`WORKFLOWS/README.md`.

## 3. Canonical verification commands

**Gap: no automated test suite exists.** There is no `tests/` directory, no `pytest`
config, no `Makefile`, and no `.github/workflows/` — nothing in the repo defines a
repeatable, scripted way to prove a change works. The only verification done so far was
manual: starting the server and exercising the HTTP API by hand (`curl`) during
development. This should be treated as an open gap, not filled in with an invented
command.

```bash
# run the app (the closest thing to a verification command that exists today)
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # then fill in MISTRAL_API_KEY (or ANTHROPIC_API_KEY + LLM_PROVIDER=anthropic)
uvicorn app.main:app --reload
```

Prerequisites: a real `MISTRAL_API_KEY` or `ANTHROPIC_API_KEY` — every request the
engine makes is a live LLM call; there is no mock/fake mode wired into the app itself.
No database or other service is required; state is a local JSON file per session under
`data/sessions/`.

## 4. Hard invariants: never violate

1. **No authentication or authorization exists anywhere in `app/main.py`.** Anyone who
   can reach the process and knows (or guesses) a session UUID can read or continue that
   session via `GET/POST /api/sessions/{id}...`. This is intentional for the current
   single-user/internal scope (`Visio.md` §6), not an oversight — but it means this app
   must not be exposed to the open internet or to untrusted users without adding auth
   first.
2. **API keys are read only from the environment / `.env`**
   (`app/llm/anthropic_client.py`, `app/llm/mistral_client.py`) and must never be
   committed. `.env` is gitignored; `.env.example` holds placeholders only.
3. **Session state is plaintext JSON on local disk**, one file per session under
   `data/sessions/` (`app/core/store.py`, `JSONFileStore`), with no encryption. Treat
   any idea or answer text a user enters as stored in the clear on whatever machine runs
   the server.
4. **LLM output is trusted without human review.** `Evaluation.verdict` — a field an
   LLM produces — directly drives session state transitions (area progression,
   completion) in `app/core/engine.py::submit_answer`. No human-in-the-loop gate exists
   before a model's structured output changes session state.

If a task seems to require breaking one of these, stop and ask.

## 5. Deploy

No deploy target exists. The app runs locally only, via `uvicorn app.main:app` (see
README.md). There is no `Dockerfile`, no CI, and no hosting config in the repo.

## 6. Multi-agent coordination

Not applicable. One contributor (`git log` shows a single author), one branch (`main`),
no scope ledger or branch-naming convention exists. Do not assume one.
