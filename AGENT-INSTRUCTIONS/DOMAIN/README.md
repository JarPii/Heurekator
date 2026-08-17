# DOMAIN — this project's concept system

Every project develops its own vocabulary — words that mean something specific here,
not just their dictionary sense. Without a written concept system, an agent tends to
solve the *general* version of a problem, because it doesn't know what the domain
already excludes. Respecting the domain's real shape, instead of guessing, is usually
what makes a solution simpler, not more constrained — see
[`../BUILDING/REPO-RULES.md`](../BUILDING/REPO-RULES.md) §1: "A clean change that does
less is better than a messy change that does more." This folder is where "does less"
gets a concrete boundary to check against.

## One concept system, not two documents

A term's meaning and the natural rule it carries are usually the same piece of
knowledge, not two. "Root: the one Person in a Tree with no incoming parent edge"
already states a cardinality (*the one*) — that's not a separately maintained rule, it's
what the word means when defined precisely. So [`CONCEPTS.md`](CONCEPTS.md) holds both
in one place: term definitions, some of which reference other terms and by doing so
carry a constraint.

- **Base term** — a definition that stands on its own, referencing no other term in the
  system.
- **Derived term** — a definition that references one or more other terms, using
  `[[Term]]` link syntax. The reference target must be another heading in
  `CONCEPTS.md`.

Base vs. derived is never authored — it's a property of the definition, computed by
`../SCRIPTS/check-domain-concepts.sh` from whether it contains any `[[...]]` reference.
Don't tag a term "base" or "derived" by hand; write the definition and let the checker
tell you which it turned out to be.

## Writing a derived definition so the rule actually shows up

The constraint only exists if the definition is precise. "A Root is a Person in a Tree"
states a fact but excludes nothing — a general solution still looks valid against it.
"A Root is *the one* Person in a Tree with no incoming parent edge" excludes multi-root
trees by construction. When writing a derived term, use the word that actually bounds
it — *the one*, *every*, *at most one*, *never* — not a vaguer relationship. A derived
definition that doesn't narrow anything is a base term wearing a link for no reason.

## The boundary with DECISIONS/LOG.md

Most definitions just describe what a word already means here — that's documentation,
not a decision. But when a term's definition is a deliberate choice between two
reasonable alternatives (e.g. "confirmed match" could reasonably mean a strict or a
loose criterion, and this project picked one), that choice crosses the same threshold as
[`../BUILDING/REPO-RULES.md`](../BUILDING/REPO-RULES.md) §0 already set: it changes the
vision/roadmap-level model of the domain, so it also gets a row in
[`../DECISIONS/LOG.md`](../DECISIONS/LOG.md) (rejected alternative + why), linked from
the term's entry. The two documents don't compete — one says what a word means, the
other says why it was made to mean that instead of the other reasonable thing.

## Tests instead of documents — the honest `Enforced by:` list

1. Every `[[Term]]` reference in `CONCEPTS.md` resolves to a real heading in the same
   file — no dangling reference to a term that was never defined or got renamed.
   **Enforced by:** script (`../SCRIPTS/check-domain-concepts.sh`).
2. No term is defined twice under the same heading. **Enforced by:** script.
3. A derived definition's language actually bounds the relationship (§"Writing a
   derived definition" above) rather than just name-dropping another term.
   **Enforced by:** review only — precision of language is a judgment call no script
   can make.
4. A term whose definition reflects a deliberate choice between real alternatives also
   gets a row in `../DECISIONS/LOG.md` (§"The boundary" above). **Enforced by:** review
   only — same reason `DECISIONS/README.md` §4 item 1 is review only: nothing can check
   whether a choice *should* have been recorded, only whether the ones that exist are
   well-formed.

Run before committing a change to `CONCEPTS.md`:

```bash
./SCRIPTS/check-domain-concepts.sh
```

## Why this folder is generic

`DOMAIN/README.md` (this file) is the portable method and travels unchanged, like
`BUILDING/`, `PLANNING/`, `SUBAGENTS/`, and `DECISIONS/README.md`. `CONCEPTS.md` is
expected to be full of this project's own vocabulary, so — like `DECISIONS/LOG.md` — it
is deliberately excluded from `../SCRIPTS/check-portability.sh`'s scan.
