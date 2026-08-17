## Phase P1 - Structured evaluation profile + risk register (backend) [DONE]

Implemented and verified end-to-end against a live session (2026-08-17). Build
instructions retired. Later phases consume these frozen contracts:

- `app/models.py::Report` now has 5 fields: `concept_document_markdown: str`,
  `evaluation_profile: list[AreaEvaluationSummary]`, `risk_register:
  list[RiskRegisterEntry]`, `recommendation: Recommendation`,
  `recommendation_rationale: str`. P2 (and any other consumer) reads these field names
  as-is; do not invent alternates.
- `app/models.py::AreaEvaluationSummary` - `area_id: str`, `area_label: str`, `verdict:
  Verdict`, `scores: list[CriterionScore]`, `weaknesses: list[str]`. One entry per
  resolved `Area`, in `AREAS` order. `weaknesses` holds `"{criterion}: {comment}"`
  strings for every score `<= 3`; may legitimately be empty.
- `app/models.py::RiskRegisterEntry` - `description: str`, `kind: Literal["assumption",
  "risk"]`, `priority: Literal["high", "medium", "low"]`.
- `app/core/engine.py::Engine._build_evaluation_profile` (new, static) is the only
  producer of `evaluation_profile`; it reads `session.areas`, never calls the LLM.
  `app/core/engine.py::Engine._generate_report` composes the final `Report` from this
  plus an LLM-produced `ReportNarrative` (`concept_document_markdown`, `risk_register`,
  `recommendation`, `recommendation_rationale`).
- `app/prompts/report.py::build_report_prompt` signature and message content are
  unchanged; only `SYSTEM` changed, to ask for the structured `risk_register` instead of
  leaving assumptions/risks as prose-only context.
- **Known carry-over (not fixed by this phase, folded into P2):** a real end-to-end run
  produced a 56-entry `risk_register`, because `Session.assumptions` / `Session.risks`
  (`app/core/engine.py::submit_answer`) dedup only by exact string match - near-duplicate
  phrasings from different areas all survive. P2 must decide a UI strategy for this
  volume (e.g. default to showing only `priority: "high"` entries, collapsible groups by
  `kind`) rather than rendering all entries as one flat list.
