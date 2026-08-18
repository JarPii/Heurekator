## Phase P0 - Mode selector screen

**Status:** active.
**Depends on:** `interrogation-ui` Phase P0 (`../../interrogation-ui/done/P0-design-tokens-brand-shell.md`) — design tokens only.
**Scope:** add `#mode-select`, a new section rendered first on page load, before
`#idea-form`. Two stamp-style choices: "Idea" (hides `#mode-select`, shows
`#idea-form`, existing flow unchanged) and "Ongelma" (visibly disabled, labeled not
yet available — no click handler, no navigation, no backend call).
**Gate level:** standard - purely additive frontend markup/JS/CSS; no API/schema
change, no invariant touched (D7, `../../../DECISIONS/D7-mode-selector.md`).

**Current state (verified):**
- `frontend/index.html` lines 9-30 (full body, current):
  ```html
  <main id="app">
    <header class="masthead">
      <h1><img class="lockup" src="/assets/heurekator-lockup.png" alt="Heurekator — the machine that forces eureka moments" width="1200" height="345" /></h1>
    </header>

    <section id="idea-form">
      <label for="idea">Kuvaa ideasi</label>
      <textarea id="idea" rows="4" placeholder="Mikä on ideasi?"></textarea>
      <button id="start-btn">Aloita</button>
    </section>

    <section id="chat" hidden>
      ...
    </section>

    <section id="report" hidden></section>
  </main>
  ```
  `#idea-form` has no `hidden` attribute today — it is the first visible section.
  `#chat` and `#report` both use the `hidden` attribute/property pattern this phase
  reuses for `#mode-select`/`#idea-form`.
- `frontend/app.js` lines 1, 28-34 (current):
  ```js
  const state = { sessionId: null };
  ...
  const ideaForm = document.getElementById("idea-form");
  const chat = document.getElementById("chat");
  const messagesEl = document.getElementById("messages");
  const answerForm = document.getElementById("answer-form");
  const answerInput = document.getElementById("answer");
  const reportEl = document.getElementById("report");
  const startBtn = document.getElementById("start-btn");
  ```
  No mode-selection state or element refs exist. `ideaForm.hidden = true` /
  `chat.hidden = false` (in the existing `startBtn` handler) is the exact pattern this
  phase reuses to toggle `#mode-select`/`#idea-form`.
- `frontend/style.css` lines 1-15 (`:root` tokens, frozen by `interrogation-ui` P0):
  `--ground`, `--surface`, `--line`, `--paper`, `--paper-dim`, `--ink-gold`,
  `--font-mono`, `--font-serif`. Lines 26-43: `.masthead`/`.lockup` pattern (reused
  as-is, not touched). Lines 58-103: `#idea-form`'s frozen button/textarea pattern
  (`interrogation-ui` `done/P1-idea-intake-screen.md`) — this phase's two choice
  buttons reuse the same gold-outlined stamp-button visual language, not the exact
  same CSS rule (different selector, `#mode-select button` not `#idea-form button`).

**Read first (do not invent):**
- `frontend/index.html` - full file (33 lines) - exact current markup, so the new
  section is inserted in the right place without disturbing `#idea-form`/`#chat`/`#report`.
- `frontend/app.js` - full file (163 lines) - exact `startBtn` handler and element-ref
  pattern this phase's new handler copies.
- `frontend/style.css` - full file (~300 lines) - exact token names and `#idea-form`
  button pattern this phase's new rules visually match without duplicating selectors.
- `../../../DECISIONS/D1-ui-direction.md` - binding visual direction (stamp language).
- `../../../DECISIONS/D7-mode-selector.md` - binding decision: "Ongelma" must be
  honestly non-functional, not a fake flow.

**Build plan:**
1. `frontend/index.html`:
   - Insert a new section immediately after `</header>` and before `<section id="idea-form">`:
     ```html
     <section id="mode-select">
       <p class="mode-select-label">Mitä haluat käsitellä?</p>
       <div class="mode-choices">
         <button id="mode-idea-btn" class="mode-choice">Idea</button>
         <button id="mode-ongelma-btn" class="mode-choice" disabled title="Ei vielä toteutettu">Ongelma <span class="mode-choice-note">(tulossa)</span></button>
       </div>
     </section>
     ```
   - Add `hidden` to `<section id="idea-form">`'s opening tag (it is no longer the
     first visible screen):
     ```html
     <!-- before -->
     <section id="idea-form">
     <!-- after -->
     <section id="idea-form" hidden>
     ```
   - No change to `#chat` or `#report`.
2. `frontend/app.js`:
   - After the existing element-ref block (after `const startBtn = ...`), add:
     ```js
     const modeSelect = document.getElementById("mode-select");
     const modeIdeaBtn = document.getElementById("mode-idea-btn");
     ```
     (`mode-ongelma-btn` needs no ref — it has no handler, `disabled` is set in markup.)
   - Immediately after that, add the mode-selection handler:
     ```js
     modeIdeaBtn.addEventListener("click", () => {
       modeSelect.hidden = true;
       ideaForm.hidden = false;
     });
     ```
   - No other function in `app.js` changes — `startBtn`'s handler, `addMessage`,
     `renderReport`, etc. are all untouched.
3. `frontend/style.css`:
   - Add, after the `.lockup` rule block (before `textarea {}`):
     ```css
     #mode-select {
       text-align: center;
     }

     .mode-select-label {
       font-family: var(--font-mono);
       font-size: 0.75rem;
       letter-spacing: 0.15em;
       text-transform: uppercase;
       color: var(--paper-dim);
       margin-bottom: 1rem;
     }

     .mode-choices {
       display: flex;
       gap: 1rem;
       justify-content: center;
       flex-wrap: wrap;
     }

     .mode-choice {
       background: transparent;
       border: 2px solid var(--ink-gold);
       border-radius: 0;
       color: var(--ink-gold);
       font-family: var(--font-mono);
       font-size: 0.85rem;
       letter-spacing: 0.2em;
       text-transform: uppercase;
       padding: 0.6rem 1.75rem;
       margin-top: 0;
       cursor: pointer;
     }

     .mode-choice:hover:not(:disabled) {
       background: var(--ink-gold);
       color: var(--ground);
     }

     .mode-choice:disabled {
       opacity: 0.4;
       cursor: not-allowed;
       border-color: var(--paper-dim);
       color: var(--paper-dim);
     }

     .mode-choice-note {
       display: block;
       font-size: 0.65rem;
       letter-spacing: 0.1em;
       margin-top: 0.2rem;
     }
     ```
   - `button { margin-top: 0.5rem; ... }` (the generic rule) still applies as a base to
     `.mode-choice` before this new rule overrides `margin-top`; explicitly set
     `margin-top: 0` above so the two buttons align without an unwanted top gap in the
     flex row. Do not edit the generic `button {}` rule itself.

**Callers / wiring to update:**
- None outside the three files above — `#mode-select` is a new, self-contained screen;
  nothing else in the repo references `#idea-form`'s visibility or the app's initial
  screen (confirmed: `frontend/app.js` is the only script, no other JS file exists).

**Config / schema / migrations:**
- None. No backend touched.

**Rules / MUST NOT:**
- Must not add any click handler, `fetch` call, or navigation for
  `#mode-ongelma-btn` — it must do nothing when interacted with, matching its
  `disabled` state honestly (`REPO-RULES.md` §2: a degraded path must be "explicitly
  chosen, clearly labelled... and does not pretend to be the full result").
- Must not change `#idea-form`, `#chat`, `#report`'s existing markup, CSS rules, or JS
  functions — only `#idea-form`'s opening tag gains a `hidden` attribute (Build plan
  step 1); nothing inside it changes.
- Must not touch `app/` — no backend file in this phase.
- Must not add a build step, bundler, or framework dependency.

**Tests:**
- N/A — no automated test suite exists in this repo (`../../../PROJECT.md` §3); this
  phase is a static markup/CSS addition plus one two-line click handler with no branching
  logic to unit test.

**Automated tests (E2E):** N/A - deferred, same reasoning as `interrogation-ui` P2: gate
level is `standard` (not `full`/`security`), so `PLAN-PHASE-DETAILING.md` §8b's
automated-E2E requirement does not apply, and this repo has no E2E harness to add one
into regardless.

**User test (manual, run by the user to prove it works):**
- **Why:** automation can't reach it — visual appearance (button layout, disabled-state
  styling) and interaction feel are exactly the category `VERIFICATION-COMMITS-DEPLOY.md`
  §3 reserves for human judgment, and this repo has no automated visual/E2E harness.
1. Start the app per `../../../PROJECT.md` §3, load the page fresh.
2. Confirm `#mode-select` is the first thing visible below the masthead — two buttons,
   "Idea" and "Ongelma (tulossa)" — and `#idea-form` is not visible yet.
3. Confirm "Ongelma" looks visibly dimmed/disabled, cannot be clicked or focused via
   keyboard tab, and hovering shows a tooltip/cursor indicating it is unavailable.
4. Click "Idea". Confirm `#mode-select` disappears and `#idea-form` appears exactly as
   it did before this phase (same textarea, same "Aloita" button, same styling).
5. Complete a full idea-submission flow (idea → first question in `#chat`) to confirm
   nothing in the existing flow regressed.
6. Open devtools console. Confirm no errors, on both the mode-select screen and after
   choosing "Idea".
7. Narrow the browser window to ~375px. Confirm the two mode buttons stay legible,
   don't overflow horizontally, and wrap sensibly if needed.

**Completion checklist (gate):**
- [ ] `frontend/index.html` has `#mode-select` (two buttons, `#mode-ongelma-btn`
      carrying `disabled`) inserted before `#idea-form`; `#idea-form`'s opening tag now
      carries `hidden`; `#chat`/`#report` unchanged.
- [ ] `frontend/app.js` has `modeSelect`/`modeIdeaBtn` refs and the one click handler;
      no handler exists for `mode-ongelma-btn`; no other function changed.
- [ ] `frontend/style.css` has `#mode-select`, `.mode-select-label`, `.mode-choices`,
      `.mode-choice` (+ `:hover:not(:disabled)`, `:disabled`), `.mode-choice-note`;
      `#idea-form`/`#chat`/`#report`-scoped rules are byte-identical to their
      `interrogation-ui` P2 end-state.
- [ ] A full session (mode-select → Idea → idea submit → first question) runs with no
      console error (User test steps 4-6).
- [ ] `uvicorn app.main:app --reload` starts with no error (no backend touched, but
      confirms nothing broke the app import).
- [ ] Test run left the tree clean - no leftover temp files.
- [ ] Safety commit made before handing off User test steps.
- [ ] User test steps handed to the user and confirmed passing.
- [ ] On confirmation: compress this file into `../done/P0-mode-selector.md` and flip
      `../full-plan.md`'s P0 row to `done`.

**Exit:** `#mode-select` is the app's first screen, showing "Idea" (functional, routes
to the unchanged §3 flow) and "Ongelma" (honestly disabled, not yet available).
