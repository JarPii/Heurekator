# DOMAIN/CONCEPTS.md — this project's terms, base and derived

Read [`../DOMAIN/README.md`](README.md) first — it explains why this is one system
instead of a glossary plus a separate rules doc, and where the boundary with
[`../DECISIONS/LOG.md`](../DECISIONS/LOG.md) is.

**Format rules (do not deviate — `../SCRIPTS/check-domain-concepts.sh` parses this
literally):**

- Everything below the `## Terms` heading is machine-parsed. Keep prose/instructions
  above it, as here.
- One heading per term: `### <Term>`, followed by exactly one definition paragraph.
- To reference another term from within a definition, use `[[Term]]` — the text inside
  the double brackets must exactly match another `### <Term>` heading in this file.
- A definition with zero `[[...]]` references is a base term. One or more makes it
  derived — this is computed, never hand-labeled (see `README.md`).
- A derived definition must actually bound the relationship (*the one*, *every*, *at
  most one*, *never* — not a vague mention). See `README.md`'s "Writing a derived
  definition" section.
- If a term's meaning was a deliberate choice between reasonable alternatives, link its
  `DECISIONS/LOG.md` row at the end of the paragraph: `(see DECISIONS/LOG.md D<n>)`.
- Terms are listed alphabetically for lookup, not in dependency order — the dependency
  graph is computed from the `[[...]]` links, not from position in the file.

## Terms

### Area
One of the seven fixed subject headings a Heurekator process works through — problem
definition, target group, necessity, alternatives, assumptions, sustainability, risk —
defined as the `AREAS` list in `app/core/criteria.py`, each entry carrying an `id`, a
`label`, and a seed question.

### AreaProgress
The record of how far a [[Session]] has gotten on one [[Area]]: the number of attempts
made, whether it is resolved, and every [[Evaluation]] produced for it
(`app/models.py`). A Session holds exactly one AreaProgress per Area, in the same order
as `AREAS`.

### CriterionScore
One 1-5 score plus a short comment for a single named criterion (e.g. `syvyys`,
`konkretia`) within an [[Evaluation]] (`app/models.py`).

### Engine
The orchestrator that drives one [[Session]] through the ask -> answer -> evaluate ->
adapt -> next-question cycle, calling an [[LLMClient]] for both the question and the
[[Evaluation]], and persisting state through a [[SessionStore]] after every step
(`app/core/engine.py`).

### Evaluation
The structured judgment an [[LLMClient]] produces for a single user [[Message]]: a
[[Verdict]], a list of [[CriterionScore]]s, any assumptions or risks the model
identified in that answer, and a rationale (`app/models.py`).

### LLMClient
The abstraction Heurekator calls to generate a question or to produce a structured
[[Evaluation]] or [[Report]]. `MistralClient` (default) and `AnthropicClient` (the only
alternative) are its two implementations, selected by the `LLM_PROVIDER` environment
variable via `app/llm/factory.py` (`app/llm/base.py`).

### Message
One turn in a [[Session]]'s history: a `role` (`user` or `assistant`) and a `content`
string (`app/models.py`).

### Report
The concept document, a recommendation (`jatka`, `kehita_lisaa`, or `hylkaa`), and a
rationale that an [[LLMClient]] generates once every [[Area]] in a [[Session]] is
resolved (`app/models.py`, `app/prompts/report.py`).

### Session
The full state of one idea working through the Heurekator process: the idea text, the
current [[Area]] index, the full [[Message]] history, one [[AreaProgress]] per Area,
the accumulated assumptions and risks, and — once finished — at most one [[Report]]
(`app/models.py`).

### SessionStore
The abstraction the [[Engine]] uses to persist and reload a [[Session]]'s full state.
`JSONFileStore` — one JSON file per session under `data/sessions/` — is its only
implementation (`app/core/store.py`).

### Verdict
One of five fixed outcomes an [[Evaluation]] must resolve to — `pinnallinen`,
`ristiriitainen`, `puuttuva_nakokulma`, `yksiulotteinen`, or `kestava` — which the
[[Engine]] uses to decide whether the current [[Area]] is resolved or needs another
question (`app/models.py`, `app/core/engine.py`).
