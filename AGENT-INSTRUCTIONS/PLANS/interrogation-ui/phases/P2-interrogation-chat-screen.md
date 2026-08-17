## Phase P2 - Interrogation (chat) screen

**Status:** active.
**Depends on:** P0 (`../done/P0-design-tokens-brand-shell.md`), P1
(`../done/P1-idea-intake-screen.md`).
**Scope:** restyle `#chat` into the Kuulustelupöytäkirja direction (D1) — per-question
area stamp label, monospace question / serif answer text, a live tilted per-turn
verdict stamp on each judged answer (D6), and a continuous page-flowing transcript
(no boxed scroll-crop) — plus the one `app/` change D6 settled: `submit_answer`
returns the verdict of the answer it just judged. `#answer-form`'s textarea/button are
restyled to reuse the exact pattern P1 established for `#idea-form` (frozen contract,
`../done/P1-idea-intake-screen.md`), scoped under `#answer-form`. No change to
`#idea-form` or `#report`.
**Gate level:** full - D6 changes `POST /api/sessions/{id}/answer`'s non-`done`
response shape (`PLAN-PHASE-DETAILING.md` §3a: "full" applies to frontend/backend API
shape changes), matching the reasoning `report-fidelity`'s P1 used for the same
trigger.

**Design decisions (shaping pass, user-confirmed 2026-08-17):**
- **Transcript layout: continuous page-flow, not a boxed chat window.** `#messages`
  loses its `max-height`/`overflow-y` scroll-crop entirely; the transcript grows with
  the page like a real pöytäkirja, and each new turn calls `scrollIntoView` to bring
  itself into view instead of the old container-local `scrollTop` jump. This directly
  fixes the visibility gap raised this session: previously the box auto-scrolled to
  the newest turn inside a small 60vh window, so only the latest question was visible
  without the user manually scrolling that inner box; now the full history is part of
  normal page scroll.
- **No separate area-progress widget.** D1 explicitly rejected the "Diagnostiikkalaite"
  direction (dashboard/status-grid aesthetic) in favor of the literal stamp language
  ("ALUE 02/07 — KOHDERYHMÄ" per `D1-ui-direction.md`). This phase renders that stamp
  as a label line prefixing each assistant (question) message, not as a persistent
  7-box status grid — the progression is legible by reading down the transcript, which
  is itself the "track." `area_index` (already sent on every response) is the only data
  needed; no new backend field for this part.
- **Verdict stamp: tilted, inline in the flow, not absolutely positioned.** Appended as
  a small tilted (`rotate(-4deg)`) badge directly after the user's answer text, inside
  the same `.message.user` element — not an absolute-positioned overlay, so it cannot
  misalign on narrow viewports without a live browser to verify against.
- **Verdict color split matches the existing (pre-D1) `.verdict-pill` precedent:**
  `kestava` → `var(--ink-green)`; the other four verdicts (`pinnallinen`,
  `ristiriitainen`, `puuttuva_nakokulma`, `yksiulotteinen`) → `var(--ink-rust)`. Same
  two-way split the current `.verdict-pill`/`.verdict-pill.verdict-kestava` rules in
  `frontend/style.css` already use, now expressed with P0's frozen tokens instead of
  `light-dark()` literals, and under a new `.verdict-stamp` class distinct from
  `.verdict-pill` (which stays `#report`-scoped, P3's territory — do not rename or
  reuse it here).
- **`#answer-form` reuses P1's exact `#idea-form` textarea/button pattern**
  (user-confirmed), scoped to `#answer-form`'s own ids so `#idea-form`'s rules are
  untouched. `#answer-form` has no `<label>` element, so only the textarea/button
  rules are reused, not the label rule.

**Current state (verified):**
- `frontend/index.html` lines 21-27 (full `#chat` section, unchanged since P0):
  ```html
  <section id="chat" hidden>
    <div id="messages"></div>
    <form id="answer-form">
      <textarea id="answer" rows="3" placeholder="Vastauksesi..."></textarea>
      <button type="submit">Lähetä</button>
    </form>
  </section>
  ```
  No markup change needed — every element this phase renders (`.area-label`,
  `.message-text`, `.verdict-stamp`) is created by `app.js` inside the existing
  `#messages`/`.message` structure.
- `frontend/app.js` (full file, 157 lines):
  - Lines 3-9: `VERDICT_LABELS` — `{pinnallinen, ristiriitainen, puuttuva_nakokulma,
    yksiulotteinen, kestava}` → Finnish display strings. Reused as-is for the stamp
    text.
  - Lines 19-25: element refs (`ideaForm`, `chat`, `messagesEl`, `answerForm`,
    `answerInput`, `reportEl`, `startBtn`). No new element refs needed — this phase
    adds no new top-level DOM nodes to look up.
  - Lines 27-48: `startBtn` click handler. Line 42:
    `addMessage("assistant", data.question);` — `data.area_index` is already on this
    response (`app/main.py` line 36) but currently unused.
  - Lines 50-80: `answerForm` submit handler. Line 55: `addMessage("user", answer);`
    (return value currently discarded). Line 68-74: branches on `data.done`; line 73:
    `addMessage("assistant", data.question);` on the non-`done` branch. `data.verdict`
    does not exist yet on this response — this phase's `app/` change adds it.
  - Lines 82-85: `setFormDisabled(disabled)` — unchanged, not touched by this phase.
  - Lines 87-93: `addMessage(role, text)` — full current body:
    ```js
    function addMessage(role, text) {
      const div = document.createElement("div");
      div.className = `message ${role}`;
      div.textContent = text;
      messagesEl.appendChild(div);
      messagesEl.scrollTop = messagesEl.scrollHeight;
    }
    ```
    Returns nothing; sets `div.textContent` directly (no child wrapper); scrolls the
    `#messages` container itself, not the page.
- `frontend/style.css` (230 lines, as P1 left it):
  - Lines 45-49: generic `textarea {}` — still applies as the base `#answer-form
    textarea` inherits before this phase's new `#answer-form`-scoped rule.
  - Lines 51-56: generic `button {}` — same, base for `#answer-form button`.
  - Lines 58-103: P1's `#idea-form`-scoped rules (frozen, `../done/P1-idea-intake-screen.md`)
    — the exact pattern this phase copies for `#answer-form`, selectors renamed only.
  - Lines 105-112: `#messages { display: flex; flex-direction: column; gap: 0.5rem;
    margin-bottom: 1rem; max-height: 60vh; overflow-y: auto; }` — the `max-height`/
    `overflow-y` pair this phase removes.
  - Lines 114-119: `.message { padding: 0.5rem 0.75rem; border-radius: 0.5rem;
    max-width: 85%; white-space: pre-wrap; }` — replaced (no more bubble sizing).
  - Lines 121-124: `.message.assistant { background: light-dark(#eee, #333);
    align-self: flex-start; }` — replaced.
  - Lines 126-129: `.message.user { background: light-dark(#d6e9ff, #234); align-self:
    flex-end; }` — replaced.
  - Lines 138-225: `.area-card`, `.verdict-pill` (+ variants), `.score-list`,
    `.weaknesses`, `.risk-group`, `.risk-item`, `.priority-*`, `.recommendation` — all
    `#report`-scoped rendering from `renderReport()`. Not touched by this phase (P3's
    scope); confirms `.verdict-pill` is a distinct, already-used class name this phase
    must not rename or repurpose for the new `.verdict-stamp`.
- `app/main.py` lines 39-49 (full route, current):
  ```python
  @app.post("/api/sessions/{session_id}/answer")
  def submit_answer(session_id: str, req: AnswerRequest):
      try:
          session = _store.load(session_id)
      except FileNotFoundError:
          raise HTTPException(status_code=404, detail="Sessiota ei löytynyt.")

      session, question, report = _engine.submit_answer(session, req.answer)
      if report is not None:
          return {"done": True, "report": report.model_dump()}
      return {"done": False, "question": question, "area_index": session.current_area_index}
  ```
- `app/core/engine.py` lines 1-17 (imports) and 40-81 (full `submit_answer` method,
  current):
  ```python
  from app.models import (
      AreaEvaluationSummary,
      AreaProgress,
      Evaluation,
      Message,
      Report,
      ReportNarrative,
      Session,
  )
  ...
  def submit_answer(
      self, session: Session, answer: str
  ) -> tuple[Session, str | None, Report | None]:
      if session.status == "done":
          raise ValueError("Sessio on jo päättynyt.")

      area = AREAS[session.current_area_index]
      progress = session.areas[session.current_area_index]

      session.history.append(Message(role="user", content=answer))
      progress.attempts += 1

      system, messages = build_evaluation_prompt(area, answer, session.history)
      evaluation = self._llm.complete_structured(system, messages, Evaluation)
      progress.evaluations.append(evaluation)

      for assumption in evaluation.identified_assumptions:
          if assumption not in session.assumptions:
              session.assumptions.append(assumption)
      for risk in evaluation.identified_risks:
          if risk not in session.risks:
              session.risks.append(risk)

      resolved = evaluation.verdict == "kestava" or progress.attempts >= MAX_ATTEMPTS_PER_AREA
      progress.resolved = resolved

      if not resolved:
          question = self._ask_next_question(session, evaluation)
          self._store.save(session)
          return session, question, None

      if session.current_area_index + 1 < len(AREAS):
          session.current_area_index += 1
          question = self._ask_next_question(session)
          self._store.save(session)
          return session, question, None

      report = self._generate_report(session)
      session.report = report
      session.status = "done"
      self._store.save(session)
      return session, None, report
  ```
  `evaluation` (line 53) is assigned before all three `return` statements (lines 69,
  75, 81) and is in scope at each — no restructuring needed to reach it from any
  return point. `Engine.submit_answer` has exactly one caller in the whole repo:
  `app/main.py` line 46 (confirmed by grep; no other file references
  `submit_answer`).
- `app/models.py` lines 7-13 (`Verdict` type) and lines 31-37 (`Evaluation` schema):
  ```python
  Verdict = Literal[
      "pinnallinen",
      "ristiriitainen",
      "puuttuva_nakokulma",
      "yksiulotteinen",
      "kestava",
  ]
  ...
  class Evaluation(BaseModel):
      verdict: Verdict
      scores: list[CriterionScore]
      identified_assumptions: list[str] = Field(default_factory=list)
      identified_risks: list[str] = Field(default_factory=list)
      contradiction_note: str | None = None
      rationale: str
  ```
  `Verdict`'s five literal values match `frontend/app.js`'s `VERDICT_LABELS` keys
  exactly (already verified — no drift to reconcile).
- `app/core/criteria.py` lines 12-20 (`AREAS`, full list, order is the interrogation
  sequence):
  ```python
  AREAS: list[Area] = [
      Area("ongelma", "Ongelman määrittely", "..."),
      Area("kohderyhma", "Kohderyhmä", "..."),
      Area("tarpeellisuus", "Tarpeellisuus", "..."),
      Area("vaihtoehdot", "Vaihtoehdot", "..."),
      Area("oletukset", "Oletukset", "..."),
      Area("kestavyys", "Kestävyys", "..."),
      Area("riskit", "Riskit", "..."),
  ]
  ```
  Exactly 7 entries, in this fixed order. `session.current_area_index` (0-based) always
  indexes into this same order (`app/core/engine.py` lines 46, 71-72, 86) — "index <
  current = resolved" holds with no extra backend data, confirmed by reading
  `submit_answer`'s control flow above.
- `README.md` line 45: `` `POST /api/sessions/{id}/answer` `{answer}` → `{done: false,
  question}` tai `{done: true, report}` `` — already stale before this phase (omits
  `area_index`, present since before this plan); this phase makes it stale again by
  adding `verdict`. Both gaps are fixed in the same edit (Build plan step 5).

**Read first (do not invent):**
- `frontend/index.html` - full file (33 lines) - confirms `#chat`'s exact current
  markup and that `#idea-form`/`#report`/the masthead are untouched by this phase.
- `frontend/app.js` - full file (157 lines) - every function this phase edits or calls
  (`addMessage`, the `startBtn` and `answerForm` handlers) plus `VERDICT_LABELS`,
  reused as-is.
- `frontend/style.css` - full file (229 lines) - so new rules don't duplicate or
  collide with `#idea-form`'s frozen rules, the generic `textarea`/`button` rules, or
  `#report`'s rules.
- `app/main.py` - full file (61 lines) - exact route signature and response shape for
  both branches of `POST /api/sessions/{session_id}/answer`, and to confirm
  `start_session` (`POST /api/sessions`, lines 33-36) is unaffected by D6 (D6 only
  changes the answer route).
- `app/core/engine.py` - full file (126 lines) - exact `submit_answer` control flow
  (three return points) and confirmation that `evaluation` is in scope at all three.
- `app/models.py` - full file (85 lines) - `Verdict` literal and `Evaluation` schema,
  so the new response field's type is exact.
- `app/core/criteria.py` - full file (32 lines) - exact `AREAS` order and labels, byte-
  matched into `frontend/app.js`'s new `AREA_LABELS` array (Build plan step 3).
- `../../done/P0-design-tokens-brand-shell.md` - frozen token names this phase reuses
  by name: `--ground`, `--surface`, `--line`, `--paper`, `--ink-gold`, `--ink-green`,
  `--ink-rust`, `--font-mono`, `--font-serif`.
- `../../done/P1-idea-intake-screen.md` - frozen `#idea-form` CSS contract; the exact
  pattern this phase copies (selector-renamed only) for `#answer-form`.
- `../../DECISIONS/D1-ui-direction.md` - binding visual direction: literal stamp
  language, not a status-grid/dashboard aesthetic.
- `../../DECISIONS/D6-verdict-stamp-api.md` - binding decision that exactly one field
  is added to `submit_answer`'s non-`done` response; this phase settles its exact name
  (`verdict`) and shape (the raw `Verdict` string, not the full `Evaluation` object).

**Build plan:**
1. `app/core/engine.py`:
   - Line 6-13 import block: add `Verdict` to the `from app.models import (...)` tuple
     (alphabetical, after `Session`... actually insert alphabetically: `AreaEvaluationSummary,
     AreaProgress, Evaluation, Message, Report, ReportNarrative, Session, Verdict,`).
   - Line 40-42 signature, before → after:
     ```python
     # before
     def submit_answer(
         self, session: Session, answer: str
     ) -> tuple[Session, str | None, Report | None]:
     # after
     def submit_answer(
         self, session: Session, answer: str
     ) -> tuple[Session, str | None, Report | None, Verdict]:
     ```
   - Line 69: `return session, question, None` → `return session, question, None, evaluation.verdict`
   - Line 75: `return session, question, None` → `return session, question, None, evaluation.verdict`
   - Line 81: `return session, None, report` → `return session, None, report, evaluation.verdict`
2. `app/main.py` lines 46-49, before → after:
   ```python
   # before
   session, question, report = _engine.submit_answer(session, req.answer)
   if report is not None:
       return {"done": True, "report": report.model_dump()}
   return {"done": False, "question": question, "area_index": session.current_area_index}
   # after
   session, question, report, verdict = _engine.submit_answer(session, req.answer)
   if report is not None:
       return {"done": True, "report": report.model_dump()}
   return {"done": False, "question": question, "area_index": session.current_area_index, "verdict": verdict}
   ```
3. `frontend/app.js`:
   - After the existing `RISK_KIND_LABELS` constant (line 17), add:
     ```js
     const AREA_LABELS = [
       "Ongelman määrittely",
       "Kohderyhmä",
       "Tarpeellisuus",
       "Vaihtoehdot",
       "Oletukset",
       "Kestävyys",
       "Riskit",
     ];
     ```
     (byte-matches `app/core/criteria.py::AREAS[i].label`, in the same order — do not
     reorder or reword).
   - Replace `addMessage` (lines 87-93) with:
     ```js
     function addMessage(role, text, areaIndex) {
       const div = document.createElement("div");
       div.className = `message ${role}`;
       if (role === "assistant" && areaIndex !== undefined) {
         const label = document.createElement("div");
         label.className = "area-label";
         label.textContent = formatAreaLabel(areaIndex);
         div.appendChild(label);
       }
       const body = document.createElement("div");
       body.className = "message-text";
       body.textContent = text;
       div.appendChild(body);
       messagesEl.appendChild(div);
       div.scrollIntoView({ behavior: "smooth", block: "end" });
       return div;
     }

     function formatAreaLabel(areaIndex) {
       const n = String(areaIndex + 1).padStart(2, "0");
       return `ALUE ${n}/07 — ${AREA_LABELS[areaIndex].toUpperCase()}`;
     }

     function stampVerdict(messageEl, verdict) {
       const stamp = document.createElement("div");
       stamp.className = `verdict-stamp verdict-${verdict}`;
       stamp.textContent = VERDICT_LABELS[verdict] || verdict;
       messageEl.appendChild(stamp);
     }
     ```
   - Line 42 (`startBtn` handler): `addMessage("assistant", data.question);` →
     `addMessage("assistant", data.question, data.area_index);`
   - Line 55 (`answerForm` handler): `addMessage("user", answer);` →
     `const userMessageEl = addMessage("user", answer);` (declare in the handler's
     outer scope, above the `try`, so it is readable inside it).
   - Line 73 (`answerForm` handler, non-`done` branch), insert `stampVerdict` before
     the existing `addMessage` call, and pass `area_index`:
     ```js
     // before
     } else {
       addMessage("assistant", data.question);
     }
     // after
     } else {
       stampVerdict(userMessageEl, data.verdict);
       addMessage("assistant", data.question, data.area_index);
     }
     ```
   - Line 76 (error path) unchanged — `addMessage("assistant", \`[Virhe:
     ${err.message}]\`)` intentionally passes no `areaIndex`, so no stamp label is
     rendered on an error message.
4. `frontend/style.css`:
   - Replace lines 105-129 (`#messages`, `.message`, `.message.assistant`,
     `.message.user`) with:
     ```css
     #messages {
       display: flex;
       flex-direction: column;
       gap: 1.25rem;
       margin-bottom: 1.5rem;
     }

     .message {
       white-space: pre-wrap;
     }

     .area-label {
       font-family: var(--font-mono);
       font-size: 0.7rem;
       letter-spacing: 0.15em;
       text-transform: uppercase;
       color: var(--ink-gold);
       margin-bottom: 0.35rem;
     }

     .message.assistant {
       border-left: 2px solid var(--ink-gold);
       padding-left: 0.85rem;
     }

     .message.assistant .message-text {
       font-family: var(--font-mono);
       font-size: 0.95rem;
       color: var(--paper);
     }

     .message.user {
       border-left: 2px solid var(--line);
       padding-left: 0.85rem;
       margin-left: 1.5rem;
     }

     .message.user .message-text {
       font-family: var(--font-serif);
       font-size: 1rem;
       color: var(--paper);
     }

     .verdict-stamp {
       display: inline-block;
       margin-top: 0.5rem;
       padding: 0.15rem 0.6rem;
       border: 2px solid var(--ink-green);
       color: var(--ink-green);
       font-family: var(--font-mono);
       font-size: 0.75rem;
       letter-spacing: 0.15em;
       text-transform: uppercase;
       transform: rotate(-4deg);
     }

     .verdict-stamp.verdict-pinnallinen,
     .verdict-stamp.verdict-ristiriitainen,
     .verdict-stamp.verdict-puuttuva_nakokulma,
     .verdict-stamp.verdict-yksiulotteinen {
       border-color: var(--ink-rust);
       color: var(--ink-rust);
     }
     ```
   - Immediately after the block above (still before the blank line / `pre {}` rule
     that currently follows old line 129), add the `#answer-form` rules — the exact
     `#idea-form` pattern (lines 68-103) with only the id changed, minus the `label`
     rule (`#answer-form` has no `<label>`):
     ```css
     #answer-form textarea {
       background: var(--surface);
       border: 1px solid var(--line);
       border-radius: 0;
       color: var(--paper);
       font-family: var(--font-serif);
       font-size: 1rem;
       padding: 0.85rem 1rem;
     }

     #answer-form textarea:focus {
       outline: none;
       border-color: var(--ink-gold);
     }

     #answer-form button {
       background: transparent;
       border: 2px solid var(--ink-gold);
       border-radius: 0;
       color: var(--ink-gold);
       font-family: var(--font-mono);
       font-size: 0.85rem;
       letter-spacing: 0.2em;
       text-transform: uppercase;
       padding: 0.6rem 1.75rem;
     }

     #answer-form button:hover:not(:disabled) {
       background: var(--ink-gold);
       color: var(--ground);
     }

     #answer-form button:disabled {
       opacity: 0.5;
       cursor: default;
     }
     ```
   - Do not edit `#idea-form`'s rules, the generic `textarea {}`/`button {}` rules, or
     any `#report`-scoped rule (`.area-card`, `.verdict-pill` and its variants,
     `.score-list`, `.weaknesses`, `.risk-group`, `.risk-item`, `.priority-*`,
     `.recommendation`, `pre`).
5. `README.md` line 45, before → after:
   ```md
   <!-- before -->
   - `POST /api/sessions/{id}/answer` `{answer}` → `{done: false, question}` tai `{done: true, report}`
   <!-- after -->
   - `POST /api/sessions/{id}/answer` `{answer}` → `{done: false, question, area_index, verdict}` tai `{done: true, report}`
   ```
   (Also fixes the pre-existing omission of `area_index`, present on this response
   since before this plan — same line, same edit, not a separate change.)

**Callers / wiring to update:**
- `app/main.py` line 46 - the only caller of `Engine.submit_answer` (confirmed by
  grep) - must unpack the new 4-tuple and add `verdict` to the non-`done` response
  (Build plan step 2).
- `frontend/app.js` lines 42, 55, 73 - the only three call sites of `addMessage`
  besides the error-path call at line 76, which intentionally keeps the 2-arg form
  (Build plan step 3).
- No other caller of `submit_answer`, `addMessage`, or the `/answer` route exists in
  the repo (verified: `grep -rn "submit_answer"` returns only the definition and this
  one call site; no test suite calls either function).

**Config / schema / migrations:**
- None. `evaluation.verdict` is already computed and persisted inside
  `progress.evaluations` (`app/core/engine.py` line 54) on every session JSON file
  under `data/sessions/` - this phase only returns a value that already exists, both in
  memory and on disk, through one more return/response layer. No `Session`/
  `AreaProgress`/`Evaluation` field is added, so no old session file becomes
  incompatible.

**Rules / MUST NOT:**
- Must not touch `#idea-form`'s CSS (`../../done/P1-idea-intake-screen.md`'s frozen
  contract) or `#report`'s CSS/markup (`.area-card`, `.verdict-pill` and its variants,
  `.score-list`, `.weaknesses`, `.risk-group`, `.risk-item`, `.priority-*`,
  `.recommendation`, `renderReport`/`renderEvaluationProfile`/`renderRiskRegister` in
  `frontend/app.js`) — P3's scope.
- Must not rename, restyle, or repurpose `.verdict-pill` — it stays `#report`-only;
  the new per-turn stamp is the distinct `.verdict-stamp` class.
- Must not change `Engine`'s evaluation/resolution logic (`resolved = evaluation.verdict
  == "kestava" or progress.attempts >= MAX_ATTEMPTS_PER_AREA` and everything upstream of
  it in `submit_answer`) — only expose the already-computed `evaluation.verdict` one
  return-value earlier. `../../../PROJECT.md` §4 invariant 4 (LLM output trusted
  without human review) stays true: no new gate is added before the verdict reaches the
  session state or the user: it already drove state transitions before this phase, this
  phase only shows the already-trusted value sooner.
- Must not touch `app/core/criteria.py`, `app/llm/*`, `.env`, or `data/sessions/`
  directly — the only `app/` edits are `app/core/engine.py`'s return signature/values
  and `app/main.py`'s response dict (`../../../PROJECT.md` §4 invariants 1-3 all
  unaffected: no auth added, no key handling touched, no encryption added to session
  storage).
- Must not add a build step, bundler, or framework dependency — `frontend/` stays
  buildless (`../../../PROJECT.md` §2).
- Must not add a language selector or any D3/D4 surface — out of `ROADMAP.md` R1's
  scope (`full-plan.md` "Carry-overs / deferred").
- Must not introduce an automated E2E test harness as a side effect of this phase's
  `full` gate (`full-plan.md` "Carry-overs / deferred" explicitly places a test suite
  out of this plan's scope) — see Automated tests section below for the honest
  deferral instead.

**Tests:**
- N/A — no automated test suite exists in this repo (`../../../PROJECT.md` §3); this
  phase's backend change is a two-line return-tuple/response-dict change with no new
  branching logic to unit test in isolation from the LLM call it depends on.

**Automated tests (E2E):** N/A - deferred. Gate level is `full`, so
`PLAN-PHASE-DETAILING.md` §8b would normally require automated end-to-end coverage for
this UI-bearing phase, but this repo has no E2E harness (`../../../PROJECT.md` §3
states this is an open gap, "not filled in with an invented command"), and
`full-plan.md`'s own "Carry-overs / deferred" section already places standing up an
automated test suite out of this plan's scope, matching the rest of the repo. This
phase does not introduce one as a side effect of its `full` gate. The manual `User
test` below is this phase's only verification of its use cases; there is no automated
regression net backing it.

**User test (manual, run by the user to prove it works):**
- **Why:** automation can't reach it — visual appearance (stamp label, tilted verdict
  badge, transcript flow, focus/disabled states on `#answer-form`) and interaction feel
  (page scroll behavior across a multi-turn session) are exactly the category
  `VERIFICATION-COMMITS-DEPLOY.md` §3 reserves for human judgment, and this repo has no
  automated visual/E2E harness.
1. Start the app per `../../../PROJECT.md` §3. Submit an idea from `#idea-form` (still
   P1's styling, unchanged).
2. Confirm the first question appears in `#chat` with a small gold monospace label
   above it reading `ALUE 01/07 — ONGELMAN MÄÄRITTELY`, and the question text itself is
   in monospace.
3. Type a weak/short answer (e.g. one word) and submit. Confirm: your answer appears in
   serif text, indented under a thin left border; shortly after, a small tilted stamp
   badge appears attached to your answer reading one of the non-`kestava` verdict labels
   (e.g. "Pinnallinen") outlined in a rust/orange color; a follow-up question appears
   still labeled `ALUE 01/07 — ...` (same area, since a weak answer does not advance).
4. Type a thorough, well-reasoned answer for the same area and submit. Confirm the
   stamp this time is outlined in green and reads "Kestävä", and the next question's
   label advances to `ALUE 02/07 — KOHDERYHMÄ`.
5. Confirm the whole conversation so far (both questions, both answers, both stamps) is
   still visible above, without needing to scroll a small inner box — only the outer
   page scrolls, and it has auto-scrolled down to the newest question.
6. Confirm `#answer-form`'s textarea has the same dark case-field look as `#idea-form`'s
   textarea (gold border on focus), and its submit button is the same gold-outlined
   stamp-style box, dimming while a request is in flight.
7. Open the browser devtools console. Confirm there are no errors.
8. Narrow the browser window to a mobile width (~375px). Confirm messages, labels, and
   stamps stay legible and full-width without horizontal overflow, and the tilted stamp
   does not clip or overlap adjacent text.
9. (Optional, longer check) Continue answering through all 7 areas to reach the report
   screen. Confirm the session still completes and `#report` renders exactly as before
   (P3's styling is not yet applied, so it should look like it did before this phase).

**Completion checklist (gate):**
- [ ] Gate level (`full`) requirements from `PLAN-PHASE-DETAILING.md` §3a are
      satisfied: standard's requirements, plus explicit caller/wiring audit (done
      above — one caller each for `submit_answer` and `addMessage`), phase document
      re-read after implementation, invariant review before completion, user test
      confirmation.
- [ ] `Engine.submit_answer` returns `tuple[Session, str | None, Report | None,
      Verdict]`; all three return points include `evaluation.verdict`.
- [ ] `app/main.py`'s `/answer` route unpacks the 4-tuple and includes `"verdict":
      verdict` in the non-`done` response only; the `done` response is unchanged.
- [ ] `frontend/app.js` has `AREA_LABELS` (7 entries, byte-matching
      `app/core/criteria.py::AREAS` labels and order), `formatAreaLabel`,
      `stampVerdict`, and the rewritten `addMessage` returning the created element and
      calling `scrollIntoView` instead of setting `messagesEl.scrollTop`.
- [ ] `frontend/style.css` has no `max-height`/`overflow-y` on `#messages`; has
      `.area-label`, `.message.assistant .message-text`, `.message.user .message-text`,
      `.verdict-stamp` (+ the four-verdict rust variant); has `#answer-form textarea`
      (+`:focus`) and `#answer-form button` (+`:hover:not(:disabled)`, `:disabled`)
      matching P1's `#idea-form` pattern exactly, selector-renamed only.
- [ ] `.verdict-pill` and all `#report`-scoped rules are byte-identical to their P1
      end-state — confirm via diff that only the line ranges named in Build plan step 4
      changed.
- [ ] `#idea-form`'s markup and CSS are byte-identical to P1's end-state.
- [ ] `README.md` line 45 reflects the new response shape (`area_index`, `verdict`).
- [ ] A full session runs end to end through all 7 areas to the report screen with no
      error (User test step 9).
- [ ] `uvicorn app.main:app --reload` starts with no error.
- [ ] Test run left the tree clean - no leftover temp files.
- [ ] Safety commit made before handing off User test steps.
- [ ] User test steps (above) handed to the user and confirmed passing.
- [ ] On confirmation: compress this file into `../done/P2-interrogation-chat-screen.md`
      (frozen contract only) and flip `../full-plan.md`'s P2 row to `done`.

**Exit:** `#chat` matches the Kuulustelupöytäkirja direction (per-question area stamp,
monospace questions, serif answers, tilted per-turn verdict stamp, continuous
page-flowing transcript, restyled `#answer-form`); `submit_answer` returns the verdict
of the answer it just judged (D6); a full session still runs through all 7 areas to
completion exactly as before.
