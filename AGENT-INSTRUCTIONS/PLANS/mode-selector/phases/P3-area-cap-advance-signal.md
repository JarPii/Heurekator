## Phase P3 - Area-cap advance signal

**Status:** active.
**Depends on:** P2 (`../done/P2-mittakaava-aware-questions.md`) - reads the same
`data.verdict`/`data.area_index` fields P2's flow already returns; no new field
needed.
**Scope:** when `Engine.submit_answer` advances to the next area because
`MAX_ATTEMPTS_PER_AREA` (3) was hit rather than because the verdict was `kestävä`,
show the user a small, honest note explaining why the conversation moved on. Answers
the exact question raised live during P2's testing: *"kuinka pitkään Heureka kaivelee?
onko jokin portti, millä pääsee eteenpäin?"* - the gate already exists
(`app/core/criteria.py::MAX_ATTEMPTS_PER_AREA`), it just has no visible signal today.
**Gate level:** standard - purely additive frontend markup/JS/CSS; no API/schema
change (the signal is inferred client-side from data already returned), no invariant
touched.

**Current state (verified):**
- `app/core/engine.py` lines 64-65: `resolved = evaluation.verdict == "kestava" or
  progress.attempts >= MAX_ATTEMPTS_PER_AREA`. When `resolved` is true because of the
  attempt cap (not because of `kestävä`), the engine still advances
  `session.current_area_index` (line 72-73) exactly as it would for a genuine
  `kestävä` verdict - the two cases are indistinguishable in the API response today.
- `app/main.py` line 49: `POST /api/sessions/{id}/answer`'s non-`done` response is
  `{"done": False, "question": question, "area_index": session.current_area_index,
  "verdict": verdict}` - `verdict` is the verdict of the answer just judged (not
  necessarily `kestävä`), and `area_index` is the *new* current area. Both are already
  present; no backend change is needed to detect the cap case client-side (see
  "Detection logic" below).
- `frontend/app.js` line 1: `state = { sessionId: null, mittakaava: null }` - no
  tracking of the current area index exists yet.
- `frontend/app.js` lines 53-77 (`startBtn` handler): on session start,
  `data.area_index` (always `0` for a fresh session) is passed to `addMessage` but
  never stored on `state`.
- `frontend/app.js` lines 79-110 (`answerForm` submit handler): in the non-`done`
  branch (lines 101-104), `stampVerdict(userMessageEl, data.verdict)` runs, then
  `addMessage("assistant", data.question, data.area_index)` - this is where the new
  note must be inserted, between the verdict stamp and the next question.
- `frontend/app.js` lines 119-135 (`addMessage`): renders one message div; area label
  only added for `role === "assistant"`. The new note is a distinct, small element,
  not part of `addMessage`'s existing shape - do not overload `addMessage` with a new
  parameter for this.
- `frontend/style.css` lines 201-220: `.verdict-stamp` (+ per-verdict color rules) is
  the existing visual pattern for a small tilted inline note on `.message.user` - the
  new note is a *different*, non-tilted, informational element, not a verdict stamp
  variant (it's not a verdict, it's a process note).

**Detection logic (no backend change - reasoned from existing engine behavior):**
An area only advances (i.e. the area index the *next* question is labeled with
differs from the area index the *answer just submitted* was for) for one of two
reasons: `evaluation.verdict == "kestava"`, or the attempt cap was hit. Therefore:
`capForced = (newAreaIndex !== previousAreaIndex) && data.verdict !== "kestava"`.
Both operands are already in scope client-side once `state` tracks the previous area
index (added by this phase).

**Read first (do not invent):**
- `frontend/app.js` - full file (212 lines) - exact `state` shape, both fetch
  handlers, and `addMessage`'s exact signature this phase extends without changing.
- `app/core/engine.py` - full file (128 lines) - confirms the detection logic above
  against the real `resolved` condition; do not re-derive it from memory.
- `frontend/style.css` - full file (~380 lines post-P2) - exact token names
  (`--paper-dim`, `--font-mono`, `--line`) this phase's new rule reuses.

**Build plan:**
1. `frontend/app.js`:
   - Change `state` (line 1) from `{ sessionId: null, mittakaava: null }` to
     `{ sessionId: null, mittakaava: null, areaIndex: 0 }`.
   - In `startBtn`'s success path (after `state.sessionId = data.session_id;`, line
     66), add: `state.areaIndex = data.area_index;`
   - In `answerForm`'s non-`done` branch (lines 101-104), replace:
     ```js
     // before
     stampVerdict(userMessageEl, data.verdict);
     addMessage("assistant", data.question, data.area_index);
     // after
     stampVerdict(userMessageEl, data.verdict);
     const capForced = data.area_index !== state.areaIndex && data.verdict !== "kestava";
     if (capForced) addAreaCapNote();
     state.areaIndex = data.area_index;
     addMessage("assistant", data.question, data.area_index);
     ```
   - Add a new function, placed directly after `addMessage` (after line 135):
     ```js
     function addAreaCapNote() {
       const note = document.createElement("div");
       note.className = "area-cap-note";
       note.textContent = "Yritykset käytetty tälle alueelle — Heurekator siirtyy seuraavaan.";
       messagesEl.appendChild(note);
     }
     ```
2. `frontend/style.css`:
   - Add, directly after the `.verdict-stamp.verdict-pinnallinen, ...` rule block (the
     five-verdict color-override rule ending the `.verdict-stamp` group):
     ```css
     .area-cap-note {
       font-family: var(--font-mono);
       font-size: 0.7rem;
       letter-spacing: 0.1em;
       text-transform: uppercase;
       color: var(--paper-dim);
       border-left: 2px dashed var(--line);
       padding-left: 0.85rem;
       margin-left: 1.5rem;
     }
     ```
     (Reuses `.message.user`'s `margin-left: 1.5rem` value so the note visually lines
     up under the user's answer rather than the assistant's question; it is a
     sibling of `.message` elements in `#messages`, not one itself, so it does not
     use the `.message` class.)
3. `frontend/index.html`:
   - No change - `#messages` already accepts arbitrary appended children (P0/P1/P2
     never restricted it to only `.message` elements).

**Callers / wiring to update:**
- `answerForm`'s submit handler is the only place `data.area_index` and
  `data.verdict` are compared - no other caller exists (confirmed by reading the full
  file above).
- `addMessage` is unchanged - `addAreaCapNote` is a new, separate function, not a
  parameter added to `addMessage`.

**Config / schema / migrations:**
- None. No backend touched, no new request/response field - this phase only adds
  client-side inference over fields P2 already returns.

**Rules / MUST NOT:**
- Must not add a backend field (e.g. `area_advanced_by_cap`) for this - the value is
  fully derivable client-side from `area_index` + `verdict`, and inventing a
  duplicate server-side signal for already-derivable data would be an unrequested
  second source of truth (`REPO-RULES.md` §1).
- Must not change `app/core/engine.py`'s `resolved` logic or
  `MAX_ATTEMPTS_PER_AREA` - this phase only makes existing behavior visible, it does
  not change when an area actually advances.
- Must not show the note when the area advanced because of a genuine `kestävä`
  verdict, or on the session's first question (no previous area to compare against -
  `state.areaIndex` is only compared inside the answer-submit handler, never on
  session start).
- Must not reuse `.verdict-stamp` or its color tokens for this note - it is not a
  verdict, and giving it verdict styling would misrepresent it as one.

**Tests:**
- N/A - no automated test suite exists in this repo (`../../../PROJECT.md` §3); this
  phase is one boolean comparison and one new small DOM-append function, no branching
  complex enough to need one.

**Automated tests (E2E):** N/A - deferred, same reasoning as P0-P2: gate level is
`standard`, this repo has no E2E harness to add coverage into regardless
(`PROJECT.md` §3).

**User test (manual, run by the user to prove it works):**
- **Why:** automation can't reach it - confirming the note appears at the right
  moment (and only that moment) requires driving three real LLM round-trips per
  scenario, and this repo has no automated LLM-output harness.
1. Start a session and answer Area 1's question with a strong, concrete answer meant
   to earn `kestävä` on the first or second try. Confirm the area advances to
   "ALUE 02/07" with **no** area-cap note - only the verdict stamp.
2. Start a fresh session and answer Area 1's question three times with intentionally
   shallow, vague answers (aiming for a non-`kestävä` verdict each time). Confirm
   that after the 3rd answer, the area-cap note ("Yritykset käytetty tälle
   alueelle — Heurekator siirtyy seuraavaan.") appears between the verdict stamp and
   the "ALUE 02/07" question.
3. Check devtools console in both runs for errors.

**Completion checklist (gate):**
- [ ] `frontend/app.js` has `state.areaIndex` (initialized `0`, updated on session
      start and after every answered turn); the `capForced` check and
      `addAreaCapNote()` call in `answerForm`'s non-`done` branch; the new
      `addAreaCapNote` function.
- [ ] `frontend/style.css` has the one new `.area-cap-note` rule.
- [ ] User test step 1 (genuine `kestävä` advance) shows no note.
- [ ] User test step 2 (cap-forced advance) shows the note exactly once, in the right
      position.
- [ ] `uvicorn app.main:app --reload` starts with no error (no backend touched,
      confirms nothing broke the app import).
- [ ] Test run left the tree clean - no leftover temp files.
- [ ] Safety commit made before handing off User test steps.
- [ ] User test steps handed to the user and confirmed passing.
- [ ] On confirmation: compress this file into
      `../done/P3-area-cap-advance-signal.md` and flip `../full-plan.md`'s P3 row to
      `done`.

**Exit:** the user can always tell whether an area advanced because their answer was
judged `kestävä` or because the 3-attempt cap was hit - the previously invisible gate
now has a visible signal.
