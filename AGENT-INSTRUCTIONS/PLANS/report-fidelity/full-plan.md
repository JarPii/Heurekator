# Report Fidelity Plan

> **Status:** scoped forward plan - created 2026-08-17 on branch main.
> **Scope:** the final `Report` a `Session` produces once every `Area` is resolved —
> its data shape (`app/models.py`), how it is generated (`app/prompts/report.py`,
> `app/core/engine.py`), and how it is shown (`frontend/`).
> **Out of scope:** the Socratic question/evaluation loop itself (`app/core/engine.py`
> ask/evaluate/adapt logic), the criteria set (`app/core/criteria.py`), auth, multi-user
> session listing (a separate, already-known gap — see `../../PROJECT.md` §4.1).
> **Target:** internal-only prototype, matching `Visio.md`'s own scope (§6) — not
> production-grade.
>
> **Parts:**
> - **Part A - Core behavior.** `Report` schema + report prompt + engine gain the
>   structured evaluation profile and prioritized risk register `Visio.md` §3.4 promises.
> - **Part B - Product/UI.** The local web-chat renders the new structured fields
>   instead of only `recommendation` + `recommendation_rationale` + free-form markdown.
>
> **How to use this plan:** discuss and edit phase boundaries first. When implementing,
> first shape the selected vague phase (outcome, boundaries, tradeoffs, open questions),
> then expand exactly one settled phase into an implementation-grade phase from current
> code before coding.

## Why this plan exists

`Visio.md` §3.4 ("Lopputulos") promises the user four things at the end of a session:
a concept document, an **arviointiprofiili** (score per evaluation criterion + named
weaknesses), a **riskirekisteri** (assumptions and risks, *prioritized*), and a
recommendation. The current `Report` model (`app/models.py`) only carries
`concept_document_markdown`, `recommendation`, and `recommendation_rationale`. The
per-criterion scores are computed during the loop (`Evaluation.scores` on every
`AreaProgress`) but are never passed into the report-generation prompt
(`app/prompts/report.py::build_report_prompt` only forwards the transcript and two flat,
unordered lists of assumption/risk strings) and never reach the `Report` object itself.
Nothing in the code rejected this scope — it was simply not built yet. Per
`../../BUILDING/REPO-RULES.md` §0, closing this gap does not change the vision (the
vision already states it); it is execution catching up to an existing commitment, so it
does not need a `DECISIONS/LOG.md` row — it needs this plan.

## Phase status

| Phase | Title | Status | Gate level | Depends on | Phase file | Exit state | Move-on gate |
|---|---|---|---|---|---|---|---|
| P1 | Structured evaluation profile + risk register (backend) | next | standard | - | - (detail when selected) | `Report` carries real per-criterion scores and a prioritized risk register; report prompt receives `session.areas` | manual API verification (curl) shows the new fields populated and non-empty on a real session |
| P2 | Render the new fields in the chat UI | planned | standard | P1 | - | user sees the evaluation profile and prioritized risks in the browser, not just the recommendation + raw markdown | human browser verification |

## Implementation chunks + orchestration breakpoints

| Chunk | Phases | Nature | Boundary validation | Freeze / plan update | Gate |
|---|---|---|---|---|---|
| 0 | P1 | Backend/domain | Manual end-to-end run against a real session shows populated, non-empty structured fields | Freeze the `Report` field names/shapes P2 consumes | Commit |
| 1 | P2 | UI-bearing | Browser-verified by the user | Freeze rendered layout | Commit + human verify |

## How to implement this plan

1. Read `../../PROJECT.md` §2 (layout) and §4 (hard invariants — especially §4.4: LLM
   output is trusted without human review; this plan does not add a review gate, it
   only makes the LLM's existing output visible and structured).
2. Never invent a field, route, or config key. If `Evaluation.scores`' criterion names
   turn out to be inconsistent across areas (they are free-text, not an enum — see
   `app/core/criteria.py::EVALUATION_CRITERIA`), report that as drift instead of
   silently normalizing it in a way that hides the inconsistency.
3. One phase per commit. Only P1 is active until its move-on gate passes.
4. Before coding, expand the selected phase into `phases/<id>.md` from current code:
   exact field names, exact prompt changes, exact frontend render logic.
5. Do exactly the phase scope — P1 must not touch frontend rendering; P2 must not touch
   the `Report` schema.
6. No config knobs are introduced by this plan; nothing here is a model name, price, or
   threshold.
7. Verification is manual (curl / browser) per `../../PROJECT.md` §3 — no automated test
   suite exists yet in this repo; do not invent one as a side effect of this plan.
8. Fail loudly: if the LLM's structured output for the report is malformed, this must
   surface as an error (as `MistralClient.complete_structured` / `AnthropicClient`
   already do via `RuntimeError`/`SDKError`), not a silently empty profile.

## Design rules (binding)

1. `Evaluation.scores` (already collected per area, per `app/models.py`) is the single
   source of truth for the evaluation profile — do not have the LLM re-derive scores
   from the transcript inside the report-generation call.
2. The risk register's "prioritized" requirement (`Visio.md` §3.4) is an explicit
   priority field per risk/assumption (settled 2026-08-17, see Phase P1) — not list
   order, and not prose the LLM happens to order well.
3. `app/core/criteria.py` (the fixed 7 areas, `EVALUATION_CRITERIA` names) stays
   untouched — this plan consumes that data, it does not change what is asked or how
   answers are scored.
4. Hard invariant `../../PROJECT.md` §4.4 stays true after this plan: no human-in-the-loop
   gate is added before an LLM's output changes what the user sees. This plan makes
   existing untrusted output more visible, not more trusted.
5. `DOMAIN/CONCEPTS.md`'s `Report` term definition must be updated in the same commit
   that changes the `Report` schema, so the domain doc does not silently drift from the
   code (`../../SCRIPTS/check-domain-concepts.sh` will not catch this — it is a
   review-only rule, per `../../DOMAIN/README.md`).

## Current state (verified enough for scoping)

- `app/models.py` - `Report` has exactly 3 fields: `concept_document_markdown: str`,
  `recommendation: Recommendation`, `recommendation_rationale: str`. No scores, no risk
  list.
- `app/models.py` - `AreaProgress.evaluations: list[Evaluation]`, and
  `Evaluation.scores: list[CriterionScore]` (`criterion: str`, `score: int 1-5`,
  `comment: str`) already exist and are populated every round by
  `app/core/engine.py::submit_answer`. This is the unused data source.
- `app/models.py` - `Session.assumptions: list[str]` and `Session.risks: list[str]` are
  flat, deduplicated, insertion-ordered lists (`app/core/engine.py::submit_answer`
  appends new ones as they're identified) — no priority field exists anywhere.
- `app/prompts/report.py::build_report_prompt` - passes `session.idea`, the full
  transcript, and the two flat lists as prose into the prompt. Does not pass
  `session.areas` at all.
- `app/core/engine.py::_generate_report` - calls `build_report_prompt(session)` then
  `self._llm.complete_structured(system, messages, Report)`. This is the one call site
  that would need the new data wired through.
- `frontend/app.js::renderReport` - renders exactly `recommendation`,
  `recommendation_rationale`, and `concept_document_markdown` (as a `<pre>` block). No
  UI exists for per-criterion scores or a risk list today.
- `DOMAIN/CONCEPTS.md` - the `Report` term's current definition matches today's 3-field
  shape; it will need updating alongside the schema change (design rule 5 above).

What later phases inherit:
- P1's real `Report` field names and shapes, frozen before P2 starts (chunk boundary
  above).
- The existing `LLMClient.complete_structured` seam (`app/llm/base.py`) — no new LLM
  abstraction is needed; this is a schema change plus a richer prompt, not a new call
  pattern.

## Scoped phases

## Phase P1 - Structured evaluation profile + risk register (backend)

**Status:** planned.
**Depends on:** none.
**Scope:** extend `Report` (and the report-generation prompt/call) so the final output
carries a real, structured evaluation profile (per-area or per-criterion scores plus
named weaknesses) and a prioritized risk register, instead of only recommendation text
and free-form markdown.
**Expected gate level:** standard.

**Current state / reason:**
- `Evaluation.scores` exists per area today and is discarded after driving the
  ask/evaluate/adapt loop's area-resolution decision — never surfaced in the final
  `Report`.
- `Session.risks` / `Session.assumptions` are flat and unordered; `Visio.md` §3.4 calls
  for the risk register to be prioritized.

**Likely areas to touch:**
- `app/models.py` - `Report` gains new field(s) for the evaluation profile and the
  prioritized risk register.
- `app/prompts/report.py` - `build_report_prompt` must pass `session.areas` (scores per
  area/criterion) instead of only the transcript + flat lists.
- `app/core/engine.py` - `_generate_report` likely unchanged in shape (still one
  `complete_structured` call) but confirm once the new `Report` fields are settled.
- `AGENT-INSTRUCTIONS/DOMAIN/CONCEPTS.md` - `Report` term definition update (design rule 5).

**Must not:**
- Touch `app/core/criteria.py` (the fixed areas/criteria list) — out of scope.
- Touch `frontend/` — that is P2.
- Add a human-approval gate before the report is generated — that would violate
  `../../PROJECT.md` §4.4 as currently stated; if that invariant should change, that is
  a vision-level decision, not part of this plan.

**Verification shape:**
- Manual: run a full session via `curl` against a live server (as done during earlier
  debugging of this app) and inspect the JSON `Report` for non-empty, structured score
  and risk-register fields.
- No automated test suite exists (`../../PROJECT.md` §3) — do not add one as an
  incidental part of this phase; that is a separate, larger gap.

**Exit:** `Report`'s JSON shape (returned by `POST /api/sessions/{id}/answer` on
completion) includes a populated evaluation profile and a prioritized risk register on
a real end-to-end run.
**Move-on gate:** the manual curl-based check above passes, `DOMAIN/CONCEPTS.md` is
updated in the same commit, and `../../SCRIPTS/check-domain-concepts.sh` still passes.

**Settled (2026-08-17):**
1. Evaluation profile is **per-area**: 7 areas, each carrying its own criterion scores —
   matches how `AreaProgress.evaluations` already stores the data; no cross-area
   aggregation logic and no dependency on the LLM naming criteria identically across
   calls.
2. Risk register priority is an **explicit field** (e.g. `high`/`medium`/`low`) the LLM
   assigns per risk/assumption at report-generation time — verifiable in the data,
   not inferred from list order surviving JSON round-trips and frontend rendering
   unchanged.
3. Consequence of (1): `CriterionScore.criterion` free-text drift across areas
   (`app/core/criteria.py::EVALUATION_CRITERIA` names four criteria, but nothing forces
   exact string match) is no longer a blocking concern for this phase — each area's
   scores are shown as that area's own list, never merged with another area's, so
   near-duplicate labels from different calls never collide.

## Phase P2 - Render the new fields in the chat UI

**Status:** planned.
**Depends on:** P1 (needs P1's real, frozen `Report` field names/shapes).
**Scope:** update `frontend/app.js::renderReport` (and `style.css` as needed) so the
evaluation profile and prioritized risk register P1 adds are actually visible to the
user, not just present in the API response.
**Expected gate level:** standard.

**Current state / reason:**
- `renderReport` today only shows `recommendation`, `recommendation_rationale`, and
  `concept_document_markdown` in a `<pre>` block — no UI exists for structured scores or
  risks.

**Likely areas to touch:**
- `frontend/app.js` - `renderReport`.
- `frontend/style.css` - minor additions for whatever layout `renderReport` needs
  (e.g. a small score table/list, a risk list with priority labels).

**Must not:**
- Touch `app/` — this phase is presentation only, consuming whatever P1 froze.
- Introduce a frontend build step — this repo's frontend is deliberately buildless
  (`../../PROJECT.md` §2).

**Verification shape:**
- Human browser verification: run a full session end-to-end in the browser and confirm
  the evaluation profile and prioritized risks are visibly and legibly rendered.

**Exit:** a user finishing a session in the browser sees the evaluation profile and
prioritized risk register, not just the recommendation and raw markdown.
**Move-on gate:** user confirms in the browser that the new report view is correct and
legible.

## Carry-overs / deferred

- Multi-user session listing (`../../PROJECT.md` §4.1's related gap: no
  `GET /api/sessions` index) — explicitly out of scope for this plan; tracked separately.
- Automated test suite — explicitly out of scope; this plan's verification stays manual,
  matching the rest of the repo today.
- Any change to `../../PROJECT.md` §4.4 (LLM output trusted without human review) — out
  of scope; would be a vision-level decision requiring its own discussion and, if made,
  a `DECISIONS/LOG.md` row.
