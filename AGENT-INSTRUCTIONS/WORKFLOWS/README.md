# WORKFLOWS — how use cases fit into something bigger

An individual task is a use case. This project's use cases already live where they
belong: as automated end-to-end specs (`../PROJECT.md` §2-§3 name the harness, location,
and naming convention — see also `../PLANNING/PLAN-PHASE-DETAILING.md` §8b, which
requires a phase to turn its use cases into those specs in the first place). That's the
one source of truth for what a use case does; nothing here restates it.

What's missing without this folder is the bigger picture: which use cases belong to the
same real-world journey, and in what order. That's a workflow — the "backbone" in Jeff
Patton's user story mapping sense: a named sequence of use cases a user or actor
actually walks through, not a bag of unrelated specs.

## One index, not a second description

[`MAP.md`](MAP.md) is an **index**, not documentation of behavior. Each entry is a
reference — `<spec file>` + `<case name>` — never a restatement of what the spec does.
If you find yourself writing more than one line about a use case in `MAP.md`, that
content belongs in the spec itself (a comment, a better case name) or, for a workflow
that genuinely needs more explanation than an ordered list can carry, a narrative file
`WORKFLOWS/<workflow-slug>.md` linked from the entry — the same two-layer split as
`DECISIONS/` and `DOMAIN/`.

## The boundary with DECISIONS/LOG.md

Adding a use case to an existing workflow, in the obvious next slot, is just keeping the
map current — not a decision. But changing a workflow's *shape* — reordering its steps,
splitting it into two, merging two workflows, removing a step users no longer take —
changes the vision/roadmap-level model of how the product actually works. That crosses
the same threshold `../BUILDING/REPO-RULES.md` §0 already set, so it also gets a row in
`../DECISIONS/LOG.md` (rejected alternative + why), same as a `DOMAIN/CONCEPTS.md` term
whose definition was a real choice (`../DOMAIN/README.md`).

## Keeping the map current

`../PLANNING/PLAN-PHASE-DETAILING.md` §9 already requires a detailed phase to name the
permanent docs its behavior change touches. When a phase adds an automated use-case spec
that's a step in an existing or new workflow, `MAP.md` is one of those docs — update it
in the same change, not as a follow-up.

## Tests instead of documents — the honest `Enforced by:` list

1. Every entry's spec file path exists on disk. **Enforced by:** script
   (`../SCRIPTS/check-workflow-map.sh`).
2. Every entry's case name is found (as text) inside that spec file. **Enforced by:**
   script — a text match, not a real parse of this project's test framework. This
   package doesn't assume Playwright, Cucumber, pytest, or anything else, so the check
   is a grep, not a parser. A match increases confidence; it doesn't prove the string is
   actually a case identifier there and not, say, a comment.
3. A workflow's step order reflects the sequence an actor actually follows. **Enforced
   by:** review only — sequencing correctness is a judgment call no script can make.
4. An entry stays a reference, never a second description of what the use case does
   (§"One index" above). **Enforced by:** review only.

Run before committing a change to `MAP.md`:

```bash
./SCRIPTS/check-workflow-map.sh
```

## Why this folder is generic

`WORKFLOWS/README.md` (this file) travels unchanged, like `DECISIONS/README.md` and
`DOMAIN/README.md`. `MAP.md`, and any `WORKFLOWS/<workflow-slug>.md` narrative file, are
expected to be full of this project's own use cases and file paths, so — like
`DECISIONS/LOG.md` and `DOMAIN/CONCEPTS.md` — they are deliberately excluded from
`../SCRIPTS/check-portability.sh`'s scan.
