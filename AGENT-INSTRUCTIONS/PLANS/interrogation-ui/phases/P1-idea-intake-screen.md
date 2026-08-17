## Phase P1 - Idea intake screen

**Status:** active.
**Depends on:** P0 (`../done/P0-design-tokens-brand-shell.md`).
**Scope:** restyle `#idea-form` — its label, textarea, and "Aloita" button — into the
Kuulustelupöytäkirja direction (D1), reusing P0's tokens only. No new markup elements,
no JS changes, no restyling of `#chat`, `#report`, or the masthead.
**Gate level:** standard - bounded, visual-only change scoped to one section; no
backend, no auth/data/LLM surface touched (`../../../PROJECT.md` §4 invariants all
unaffected), matching P0's precedent gate level.

**Design decisions (shaping pass):**
- Label: uppercase, letter-spaced, monospace (`var(--font-mono)`), colored
  `var(--paper-dim)` — echoes the "ALUE 02/07 — KOHDERYHMÄ" stamp-label language D1
  describes for the interrogation screen (P2), applied here to the one field this
  screen has.
- Textarea ("case-field"): `var(--surface)` background against the `var(--ground)` page
  behind it, `var(--line)` border, serif body text (`var(--font-serif)`, matches
  `body`'s existing font) since this is prose the user writes, not a stamped label.
  Gold border on `:focus` for a visible interrogation-room cue.
- Button ("stamp-style"): outlined box (`var(--ink-gold)` border and text, transparent
  fill), uppercase monospace, letter-spaced — an ink-stamp outline rather than a filled
  button. Deliberately **not tilted**: D1's literal rubber-stamp tilt is reserved for
  the per-turn verdict stamp (P2's `KESTÄVÄ`-style evaluation result) — this button is
  the page's primary action, and tilting a primary CTA reads as broken rather than
  thematic. Fills solid gold on hover as the "pressed" state; dims on `:disabled` to
  reflect `app.js`'s existing `startBtn.disabled` toggle during the fetch.

**Current state (verified):**
- `frontend/index.html` (33 lines) - lines 15-19:
  ```html
  <section id="idea-form">
    <label for="idea">Kuvaa ideasi</label>
    <textarea id="idea" rows="4" placeholder="Mikä on ideasi?"></textarea>
    <button id="start-btn">Aloita</button>
  </section>
  ```
  No markup change is needed for this phase's CSS-only scope.
- `frontend/style.css` (182 lines, as P0 left it) - lines 45-56:
  ```css
  textarea {
    width: 100%;
    box-sizing: border-box;
    font: inherit;
  }

  button {
    margin-top: 0.5rem;
    padding: 0.5rem 1rem;
    font: inherit;
    cursor: pointer;
  }
  ```
  These generic `textarea`/`button` rules are shared with `#chat`'s `#answer` textarea
  and submit button — this phase must add higher-specificity `#idea-form`-scoped rules
  alongside them, not edit the generic rules themselves, so `#chat` stays untouched
  (P1-P3 boundary, `full-plan.md` §"Design rules" and the P2/P3 scoped entries).
  No `label` selector exists anywhere in the file today (`grep -n "^label\|[^-]label {" frontend/style.css` returns nothing) — adding `#idea-form label` collides with nothing.
  Line 57 is blank, line 58 begins `#messages {` (the next rule, `#chat`'s message
  list) — the insertion point for this phase's new rules is between lines 56 and 58.
- `frontend/app.js` lines 19-48:
  ```js
  const ideaForm = document.getElementById("idea-form");
  ...
  const startBtn = document.getElementById("start-btn");

  startBtn.addEventListener("click", async () => {
    const idea = document.getElementById("idea").value.trim();
    if (!idea) return;
    startBtn.disabled = true;
    try {
      const res = await fetch("/api/sessions", { ... });
      ...
      ideaForm.hidden = true;
      chat.hidden = false;
      addMessage("assistant", data.question);
    } catch (err) {
      alert(`Virhe session aloituksessa: ${err.message}`);
    } finally {
      startBtn.disabled = false;
    }
  });
  ```
  Confirms the exact DOM ids this phase's CSS selectors must target
  (`#idea-form`, `#idea`, `#start-btn`) and that `startBtn.disabled` is toggled during
  the in-flight request — the only dynamic state this phase's CSS needs to style
  (`:disabled`). No JS change needed; this phase is CSS-only.
- `../../done/P0-design-tokens-brand-shell.md` - frozen token names this phase must
  reuse by name, not redefine: `--ground`, `--surface`, `--line`, `--paper`,
  `--paper-dim`, `--ink-gold`, `--font-mono`, `--font-serif`.

**Read first (do not invent):**
- `frontend/index.html` - full file (33 lines) - confirms `#idea-form`'s exact current
  markup (lines 15-19) and that `#chat`/`#report`/the masthead are untouched by this
  phase.
- `frontend/style.css` - full file (182 lines) - so new rules don't duplicate or
  collide with the generic `textarea`/`button`/`#messages` rules already there.
- `frontend/app.js` lines 1-48 - exact ids and the `startBtn.disabled` toggle this
  phase's `:disabled` styling must match.
- `../../DECISIONS/D1-ui-direction.md` - binding visual direction (dark, stark,
  monospace stamp language) this phase's label/button treatment operationalizes.
- `../../done/P0-design-tokens-brand-shell.md` - the frozen token contract.

**Build plan:**
1. `frontend/style.css`, insert immediately after the existing `button` block (after
   line 56, before the blank line 57 / `#messages` rule at line 58):
   ```css
   #idea-form label {
     display: block;
     font-family: var(--font-mono);
     font-size: 0.75rem;
     letter-spacing: 0.15em;
     text-transform: uppercase;
     color: var(--paper-dim);
     margin-bottom: 0.5rem;
   }

   #idea-form textarea {
     background: var(--surface);
     border: 1px solid var(--line);
     border-radius: 0;
     color: var(--paper);
     font-family: var(--font-serif);
     font-size: 1rem;
     padding: 0.85rem 1rem;
   }

   #idea-form textarea:focus {
     outline: none;
     border-color: var(--ink-gold);
   }

   #idea-form button {
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

   #idea-form button:hover:not(:disabled) {
     background: var(--ink-gold);
     color: var(--ground);
   }

   #idea-form button:disabled {
     opacity: 0.5;
     cursor: default;
   }
   ```
   No other file changes — `frontend/index.html` and `frontend/app.js` need no edits
   for this phase's scope.

**Callers / wiring to update:**
- None. No markup or JS changes; `#idea-form`, `#idea`, `#start-btn` ids are unchanged,
  so nothing in `app.js` needs to change.

**Config / schema / migrations:**
- None.

**Rules / MUST NOT:**
- Must not touch `frontend/app.js` — this phase changes no behavior or markup, only
  `#idea-form`'s CSS.
- Must not touch anything under `app/` — `../../../PROJECT.md` §4's four hard
  invariants (auth, API keys, session storage, LLM-trust surface) are all unaffected by
  a CSS-only change; confirm no edit touches `app/`, `.env`, `data/sessions/`, or any
  `app/llm/*` file.
- Must not restyle `#chat` or `#report` — only add `#idea-form`-scoped selectors;
  do not edit the shared generic `textarea`/`button`/`#messages` rules.
- Must not redefine any `:root` token from `../../done/P0-design-tokens-brand-shell.md`
  or introduce a new ad hoc color value — reuse the frozen names only
  (`full-plan.md` design rule 5).
- Must not add a language selector to `#idea-form` (deferred to `ROADMAP.md` R2 / D3).
- Must not change `body`'s `max-width` or overall page layout — untouched from P0.
- Must not add a build step, bundler, or framework dependency — `frontend/` stays
  buildless (`../../../PROJECT.md` §2).

**Tests:**
- N/A — no automated test suite exists in this repo (`../../../PROJECT.md` §3); this
  phase is a CSS-only change with no backend logic to unit test.

**Automated tests (E2E):** N/A — gate level is `standard`, not `full`/`security`, so
`PLAN-PHASE-DETAILING.md` §8b's automated-E2E requirement does not apply; additionally
no E2E harness exists in this repo (`../../../PROJECT.md` §3).

**User test (manual, run by the user to prove it works):**
- **Why:** automation can't reach it — visual appearance and interaction feel (label
  styling, textarea look, button "stamp" treatment, focus/disabled states) is exactly
  the category `VERIFICATION-COMMITS-DEPLOY.md` §3 reserves for human judgment, and
  this repo has no automated visual/E2E harness to check it otherwise.
1. Start the app per `../../../PROJECT.md` §3 (`uvicorn app.main:app --reload`; add
   `--port` if the default is taken, per `README.md`).
2. Open the app in a browser. Confirm: the "Kuvaa ideasi" label appears in small,
   uppercase, letter-spaced, muted blue-grey monospace text above the textarea; the textarea
   has a visibly distinct dark-blue surface and border against the page's darker navy
   background; the "Aloita" button appears as a gold-outlined box (not a plain filled
   button) with uppercase letter-spaced text.
3. Click into the textarea. Confirm its border highlights gold while focused.
4. Type any idea text and click "Aloita". Confirm: the button visibly dims while the
   request is in flight, then the idea-form section hides and the first question
   appears in the chat area below — the existing submit flow works exactly as before.
5. Open the browser devtools console. Confirm there are no errors.
6. Narrow the browser window to a mobile width (~375px). Confirm the textarea and
   button remain full-width, legible, and do not overflow or cause horizontal
   scrolling.

**Completion checklist (gate):**
- [ ] Gate level (`standard`) requirements from `PLAN-PHASE-DETAILING.md` §3a are
      satisfied: no targeted/backend tests needed (no backend touched); permanent docs
      updated — none needed (no behavior/API/doc-relevant change); safety commit made
      before handoff.
- [ ] `#idea-form label`, `#idea-form textarea` (+ `:focus`), and `#idea-form button`
      (+ `:hover:not(:disabled)`, `:disabled`) rules exist in `frontend/style.css`,
      using only tokens from `../../done/P0-design-tokens-brand-shell.md`'s frozen
      list — no new color literal introduced.
- [ ] `#chat` and `#report` sections' own selectors (`.message`, `.area-card`,
      `.verdict-pill`, `.risk-item`, etc.) are unchanged — still on their pre-P1
      `light-dark()` rules.
- [ ] `frontend/index.html` and `frontend/app.js` are byte-identical to their P0
      end-state (no diff) — this phase is `frontend/style.css`-only.
- [ ] A full idea-submission flow still works end to end (idea text → "Aloita" →
      question appears), per User test step 4.
- [ ] `uvicorn app.main:app --reload` starts with no error.
- [ ] Test run left the tree clean — no leftover temp files.
- [ ] Safety commit made.
- [ ] User test steps (above) handed to the user and confirmed passing.
- [ ] On confirmation: compress this file into `../done/P1-idea-intake-screen.md`
      (frozen contract only) and flip `../full-plan.md`'s P1 row to `done`.

**Exit:** `#idea-form` matches the Kuulustelupöytäkirja direction (monospace stamp
label, case-field textarea, outlined stamp-style button) using only P0's frozen
tokens; the idea-submission flow is functionally unchanged from P0.
