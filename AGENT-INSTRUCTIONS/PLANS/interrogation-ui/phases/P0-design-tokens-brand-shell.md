## Phase P0 - Design tokens + brand shell

**Status:** active.
**Depends on:** none.
**Scope:** replace `frontend/style.css`'s generic `light-dark()` styling foundation with
the Kuulustelupöytäkirja design tokens (D1) and add a logo masthead to
`frontend/index.html`. Does not restyle `#idea-form`, `#chat`, or `#report`'s own
markup — that is Phases P1-P3.
**Gate level:** standard - bounded, visual-only change; no backend, no auth/data/LLM
surface touched (`../../../PROJECT.md` §4 invariants all unaffected).

**Current state (verified):**
- `frontend/index.html` (32 lines) - line 11: `<h1>Heurekator</h1>`; line 12:
  `<p class="tagline">The machine that forces eureka moments.</p>`. Both are removed by
  this phase and replaced by the logo image (see Build plan).
- `frontend/style.css` (156 lines) - lines 1-4:
  ```css
  :root {
    color-scheme: light dark;
    font-family: system-ui, -apple-system, sans-serif;
  }
  ```
  lines 6-11:
  ```css
  body {
    max-width: 640px;
    margin: 2rem auto;
    padding: 0 1rem;
    line-height: 1.5;
  }
  ```
  lines 13-17:
  ```css
  .tagline {
    opacity: 0.7;
    font-style: italic;
    margin-top: -0.5rem;
  }
  ```
- `frontend/style.css` lines 49, 54, 60, 66, 78, 82, 89, 128, 143, 147, 151 use
  `light-dark(<light>, <dark>)` for `.message`, `pre`, `.area-card`, `.verdict-pill`,
  `.risk-item`, etc. — these belong to P1-P3 and are **not edited** by this phase, but
  setting `color-scheme: dark` (this phase) makes every one of them already resolve to
  its dark-branch value instead of following the OS theme, which is the correct
  behavior per D1's single-dark-world commitment (`D1-ui-direction.md`) even before
  P1-P3 restyle their selectors properly.
- `frontend/assets/heurekator-lockup.png` - **already created and committed by this
  phase's prep** (not a build step the implementer runs): 1200×345 PNG, cropped from
  the repo-root `Heurekator_logo_text.png` to its content bounding box and resized,
  solid navy background at `rgb(6,22,40)` (~`#051527`, matches the `--ground` token
  below to the pixel). Do not regenerate, crop, or re-export this file — treat it as a
  fixed input.
- `grep -rn "tagline\|color-scheme\|font-family\|light-dark" frontend/` confirms
  `.tagline` and the `<p class="tagline">` are the only two references to that class in
  the whole `frontend/` tree — safe to remove both together, nothing else depends on
  it.
- `app/main.py` line 61: `app.mount("/", StaticFiles(directory=FRONTEND_DIR, ...))` —
  confirms `frontend/assets/heurekator-lockup.png` is served at
  `/assets/heurekator-lockup.png` with no backend change needed.

**Read first (do not invent):**
- `frontend/index.html` - full file (32 lines) - the three sections
  (`#idea-form`/`#chat`/`#report`) and their exact current markup, so nothing outside
  lines 10-12 is touched.
- `frontend/style.css` - full file (156 lines) - so the new `:root` tokens don't
  collide with or duplicate any existing rule below line 17.
- `../../DECISIONS/D1-ui-direction.md` - the binding visual direction this phase
  operationalizes into concrete token values.
- `../../PLANS/interrogation-ui/full-plan.md` - Design rules §5-§7 (tokens defined once
  in P0; brand assets live inside `frontend/`; no light theme).

**Build plan:**

1. `frontend/style.css`, lines 1-4 (`:root` block) - replace with:
   ```css
   :root {
     color-scheme: dark;
     --ground: #051527;
     --surface: #10233b;
     --surface-2: #17304d;
     --line: #24405e;
     --paper: #f4f1e8;
     --paper-dim: #a9b8cb;
     --ink-gold: #eab637;
     --ink-green: #4f8f63;
     --ink-rust: #ae402e;
     --font-mono: ui-monospace, "SF Mono", "Cascadia Mono", "Roboto Mono", Consolas, "Liberation Mono", monospace;
     --font-serif: Georgia, "Iowan Old Style", "Times New Roman", serif;
     font-family: var(--font-serif);
   }
   ```
2. `frontend/style.css`, lines 6-11 (`body` block) - add `background: var(--ground);`
   and `color: var(--paper);` to the existing declarations (keep `max-width`, `margin`,
   `padding`, `line-height` unchanged — layout width is a P1-P3 per-screen decision,
   not this phase's scope):
   ```css
   body {
     max-width: 640px;
     margin: 2rem auto;
     padding: 0 1rem;
     line-height: 1.5;
     background: var(--ground);
     color: var(--paper);
   }
   ```
3. `frontend/style.css`, lines 13-17 (`.tagline` block) - delete entirely (the tagline
   text is now baked into the logo image; step 5 removes its only caller in HTML).
4. `frontend/style.css` - insert immediately after the `body` block (i.e. where
   `.tagline` used to be, so it stays near the other top-of-file shell rules):
   ```css
   .masthead {
     text-align: center;
     padding-bottom: 1.5rem;
     margin-bottom: 1.5rem;
     border-bottom: 1px solid var(--line);
   }

   .masthead h1 {
     margin: 0;
   }

   .lockup {
     display: block;
     width: 100%;
     max-width: 24rem;
     height: auto;
     margin: 0 auto;
   }
   ```
5. `frontend/index.html`, lines 10-12 (inside `<main id="app">`, before
   `<section id="idea-form">`) - replace:
   ```html
   <h1>Heurekator</h1>
   <p class="tagline">The machine that forces eureka moments.</p>
   ```
   with:
   ```html
   <header class="masthead">
     <h1><img class="lockup" src="/assets/heurekator-lockup.png" alt="Heurekator — the machine that forces eureka moments" width="1200" height="345" /></h1>
   </header>
   ```
   Keep the blank line that currently separates it from `<section id="idea-form">`
   (line 13) as-is.

**Callers / wiring to update:**
- None. `.tagline` and the literal `<h1>Heurekator</h1>` text have no other callers in
  `frontend/` (verified by grep above) or in `app/` (server-rendered nothing — the
  frontend is static files only).

**Config / schema / migrations:**
- None.

**Rules / MUST NOT:**
- Must not touch `frontend/app.js` — this phase changes no behavior, only shared
  shell/tokens.
- Must not touch anything under `app/` (backend) — the D6 verdict-field addition
  belongs to Phase P2, not P0.
- Must not restyle `#idea-form`, `#chat`, or `#report`'s own selectors (`.message`,
  `.area-card`, `.verdict-pill`, `.risk-item`, `.score-list`, etc.) — those are P1-P3.
  Leaving them on their current `light-dark()` rules (now resolving to their dark
  branch, per Current state above) is the correct, expected P0 end-state.
- Must not regenerate, crop, resize, or otherwise modify
  `frontend/assets/heurekator-lockup.png` — it is a fixed input for this phase.
- Must not change `body`'s `max-width`/layout — that is a P1-P3 per-screen decision
  (`full-plan.md` design rules).
- Must not add a build step, bundler, or framework dependency — `frontend/` stays
  buildless (`../../PROJECT.md` §2).
- `../../PROJECT.md` §4 hard invariants: none of the four apply to this phase (no auth,
  API key handling, session storage, or LLM-trust surface is touched by an HTML/CSS/
  static-asset change) — confirm no edit in this phase touches `app/`, `.env`,
  `data/sessions/`, or any `app/llm/*` file.

**Tests:**
- N/A — no automated test suite exists in this repo (`../../PROJECT.md` §3); this
  phase is a static HTML/CSS/asset change with no backend logic to unit test.

**Automated tests (E2E):** N/A — gate level is `standard`, not `full`/`security`, so
`PLAN-PHASE-DETAILING.md` §8b's automated-E2E requirement does not apply; additionally
no E2E harness exists in this repo (`../../PROJECT.md` §3).

**User test (manual, run by the user to prove it works):**
- **Why:** automation can't reach it — visual appearance (seamless logo/background
  match, legibility, responsive scaling) is exactly the category
  `VERIFICATION-COMMITS-DEPLOY.md` §3 reserves for human judgment, and this repo has no
  automated visual/E2E harness to check it otherwise.
1. Start the app per `../../PROJECT.md` §3 (`uvicorn app.main:app --reload`; add
   `--port 8001` if 8000 is already taken, per `README.md`).
2. Open the app in a browser. Confirm: the page background is dark navy, and the
   Heurekator logo (question mark + gold star + "Heurekator" wordmark + tagline)
   appears centered at the top with **no visible seam or box edge** around the image —
   it should look like it's printed directly on the page background.
3. Open the browser devtools console. Confirm there are no errors (e.g. no 404 for
   `/assets/heurekator-lockup.png`).
4. Type any text into the idea textarea and click "Aloita". Confirm a question appears
   below — the existing submit flow must work exactly as before this phase.
5. Narrow the browser window to a mobile width (~375px). Confirm the logo scales down
   proportionally, stays centered, and does not overflow or cause horizontal
   scrolling.

**Completion checklist (gate):**
- [ ] Gate level (`standard`) requirements from `PLAN-PHASE-DETAILING.md` §3a are
      satisfied: no targeted/backend tests needed (no backend touched); permanent docs
      updated — none needed (no behavior/API/doc-relevant change); safety commit made
      before handoff.
- [ ] All 12 tokens (`--ground`, `--surface`, `--surface-2`, `--line`, `--paper`,
      `--paper-dim`, `--ink-gold`, `--ink-green`, `--ink-rust`, `--font-mono`,
      `--font-serif`, plus `color-scheme: dark`) are defined exactly once in `:root`
      and nowhere else.
- [ ] `frontend/assets/heurekator-lockup.png` loads with no 404 and shows no visible
      seam against the page background.
- [ ] `#idea-form`, `#chat`, `#report` remain present and functionally unchanged — a
      full idea-submission flow still works end to end (idea → question → ... →
      report), per User test step 4 (smoke test only; full end-to-end is P1-P3's
      concern).
- [ ] No file outside `frontend/index.html`, `frontend/style.css`, and the
      already-added `frontend/assets/heurekator-lockup.png` changed.
- [ ] `uvicorn app.main:app --reload` starts with no error (closest thing to a
      baseline command this repo has, per `../../PROJECT.md` §3).
- [ ] Test run left the tree clean — no leftover temp files.
- [ ] Safety commit made.
- [ ] User test steps (above) handed to the user and confirmed passing.
- [ ] On confirmation: compress this file into
      `done/P0-design-tokens-brand-shell.md` (frozen contract only) and flip
      `full-plan.md`'s P0 row to `done`.

**Exit:** shared design tokens and the logo masthead exist and are visually correct;
`#idea-form`, `#chat`, and `#report` still function exactly as before (still visually
generic below the masthead, matching P1-P3's `Current state` expectations).
