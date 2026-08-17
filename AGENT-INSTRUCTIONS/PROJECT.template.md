> **FROZEN TEMPLATE — do not edit.** This is the diff baseline
> `SCRIPTS/check-portability.sh` compares `PROJECT.md` against. Editing this file
> defeats the check. Fill in `PROJECT.md` instead; this file exists only to stay blank.

# PROJECT.md - <Project name>

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

<One or two sentences: what the product/service does, who it's for.>

Development model: <one developer / multiple agents on separate branches / etc.> If
multiple agents coordinate concurrently, describe the coordination mechanism here (e.g.
a scope ledger) — do not invent one if it doesn't exist yet.

## 2. Layout

```text
<repo-root>/
  <dir>/    <what it owns>
  <dir>/    <what it owns>
```

Services (if any — docker-compose, deployed processes, etc.): <name, port, purpose>.

Stable docs to read before changing a subsystem (architecture, security/privacy,
roadmap, etc.) — list them here with a one-line pointer to what each covers. If this
repo has a maintained code map, seam index, or config index, name its path here; if not,
say explicitly that none exists so other docs don't assume one.

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

The single copy of "how to prove a change works" — other docs (`BUILDING/`,
`PLANNING/`) reference this section instead of repeating commands.

```bash
# backend / unit tests
<command>

# build
<command>

# end-to-end / integration
<command>
```

Note any prerequisites (a real DB vs. a fake, env vars, services that must be up) and
the expected clean baseline (pass count, where that count is tracked, if anywhere).

## 4. Hard invariants: never violate

The concrete, binding list for this repo — access gates for sensitive data, what an
AI/automation path may and may not write, secret handling, dev-fixture safety, "one
source of truth," network exposure, etc. Number them so other docs can cite
`PROJECT.md §4.<n>`.

1. <invariant>
2. <invariant>

If a task seems to require breaking one of these, stop and ask.

## 5. Deploy

<Where this deploys, how, and any fallback paths that must not be removed. If there is
no deploy target yet, say so rather than leaving this section silently wrong.>

## 6. Multi-agent coordination

<If multiple agents/branches can work concurrently, describe the mechanism (scope
ledger, branch naming, merge order). If not applicable, say so explicitly rather than
leaving a stale assumption — see §1.>
