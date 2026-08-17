# BUILDING — build & implementation guidance

Entry point for any code change. Read these before and during implementation. Each file
below holds the actual rules and commands; this README only routes you to the right one.

## Read first, always

- **`REPO-RULES.md`** — the operative rules for all work here: the no-hack rule and the
  read-before-write discipline, this repo's hard invariants (see `../PROJECT.md` §4),
  repo orientation, code style, the pre-finish review checklist, and the priority order.
  Start here on every task.
- **`VERIFICATION-COMMITS-DEPLOY.md`** — how to prove a change works and ship it: the
  canonical backend baseline test commands (§1, referenced by everything else), the
  frontend human-verification ritual, commit + safety-checkpoint rules, deployment
  caveats, and the required completion-summary format.
- **`DEBUGGING.md`** — scientific debugging loop for bugs, flakes, and unexplained
  behavior: predict, observe, resolve, narrow, fix, verify without guessing.
- **`../DECISIONS/README.md`** — read `../DECISIONS/LOG.md` before touching an area
  that already has an entry there; it records what was decided, what was rejected, and
  why, so the same rejected approach doesn't get proposed again next session.
  `REPO-RULES.md` §3 covers the stop rule this feeds into.
- **`../DOMAIN/README.md`** — read `../DOMAIN/CONCEPTS.md` before designing a solution.
  It's this project's own vocabulary — base terms and terms derived from them, where the
  derivation itself states the domain's natural constraints. Not knowing it is why a
  solution ends up more general than the domain actually requires.
- **`../WORKFLOWS/README.md`** — read `../WORKFLOWS/MAP.md` before adding a use case. It's
  an index of named workflows and the sequence of use cases each one walks through; a
  new use case that isn't placed in one is an orphan nobody can find later.

## When executing a plan or phase

- **`WORKING-FROM-PLANS.md`** — how to implement safely from a plan: load only
  `full-plan.md` (top matter + design rules + status table) plus the one active
  `phases/<id>.md`; do exactly that scope; run the gate; compress to `done/`. Authoring
  and detailing those phases is a separate activity — see `../PLANNING/`.

## Orientation while building (don't grep blind)

- **`../PROJECT.md`** — this repo's facts: layout, stable docs, canonical test/build
  commands, hard invariants, deploy notes. Read it once per session; the files above
  point to it rather than repeating repo-specific detail.
