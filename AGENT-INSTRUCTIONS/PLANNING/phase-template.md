# Detailed phase template

Copy the skeleton below into `AGENT-INSTRUCTIONS/PLANS/<slug>/phases/<id>-<title>.md`
and fill every placeholder from current code. The authoring rules, detail bar, and
no-invention protocol live in `PLAN-PHASE-DETAILING.md` — this file is only the shape,
so the detailing model can load it without re-reading the whole guide each phase.

```markdown
## Phase <id> - <short title>

**Status:** planned.
**Depends on:** <real completed phase/contract or none>.
**Scope:** <exact boundary of this phase>.
**Gate level:** <minimal | standard | full | security> - <why this level fits the risk>.

**Current state (verified):**
- `<path>` - <real symbol/signature/behavior>
- `<path>` - <real symbol/signature/behavior>

**Read first (do not invent):**
- `<path>` - `<exact signature or table/config shape>` and why it matters.
- `<path>` - `<exact signature or table/config shape>` and why it matters.

**Build plan:**
1. `<path>`, `<symbol>` - exact edit, including before -> after signature if changed.
2. `<path>`, caller/wiring/import - exact ripple from step 1.
3. `<path>`, tests - exact test edits/additions.

**Callers / wiring to update:**
- `<path:line or symbol>` - <required update>

**Config / schema / migrations:**
- <exact config keys or migration filenames, or "none">

**Rules / MUST NOT:**
- <permissions, no duplicate path, no fake fallback, no scope creep>

**Tests:**
- `<test file>` - `<test_name>`: <assertion>

**Automated tests (E2E)** — required when `PLAN-PHASE-DETAILING.md` §8b applies (UI-bearing / workflow-visible `full` or `security` phase); otherwise write "N/A — <why>":
- Use-case coverage table — one row per derived use case (`actor + intent | described | manual User test | automated E2E`), each row closed or deferred with a reason.
- `<repo E2E spec — location/naming per PROJECT.md §2-§3>` - `<use case>`: happy path.
- `<repo E2E spec>` - `<use case>`: denied / least-privilege path (mandatory for `security`).
- Cases the current harness cannot reach: list here as deferred with the reason (never claim coverage you did not write).

**User test (manual, run by the user to prove it works):**
- **State why this is needed, in one line, before any steps** — automate first (§8b),
  then name the gap: `automation can't reach it` (visual/UX — the only kind
  `VERIFICATION-COMMITS-DEPLOY.md` §3 actually requires a human for), `redundant
  confirmation` (functionality is already proven by the automated specs above; keep the
  ask to a fast look, not a re-test), or `N/A` (no UI surface changed and
  automated/baseline tests already prove it — the only reason to have no steps at all).
- <numbered, concrete steps the user performs and the exact result they should see>
- For UI: which page, what to click/type, expected on-screen result.
- For backend-only: exact command or request, expected output/response.
- Keep it short and unambiguous; this is the gate that catches breakage before the next phase.

**Completion checklist (gate):**
- [ ] Gate level requirements from `PLAN-PHASE-DETAILING.md` §3a are satisfied.
- [ ] <verifiable item>
- [ ] Named tests pass.
- [ ] If `PLAN-PHASE-DETAILING.md` §8b applies: use-case coverage table complete, and the required automated E2E specs pass via the repo E2E command in `AGENT-INSTRUCTIONS/PROJECT.md` §3 (or deferrals justified).
- [ ] Backend baseline passes (canonical list: `AGENT-INSTRUCTIONS/PROJECT.md` §3, referenced from `AGENT-INSTRUCTIONS/BUILDING/VERIFICATION-COMMITS-DEPLOY.md` §1), plus touched-module tests; if frontend changed, the frontend build command from the same section.
- [ ] Test run left the tree clean - no leftover artifacts, temp dirs, or seeded data (`AGENT-INSTRUCTIONS/BUILDING/VERIFICATION-COMMITS-DEPLOY.md` §1).
- [ ] Relevant permanent docs updated with no plan references.
- [ ] Safety commit.
- [ ] User test steps handed to the user and confirmed passing.
- [ ] On confirmation: compress this file into `done/<id>-<title>.md` (frozen contract only) and flip the `full-plan.md` status row to `done`.

**Exit:** <observable end state>.
```
