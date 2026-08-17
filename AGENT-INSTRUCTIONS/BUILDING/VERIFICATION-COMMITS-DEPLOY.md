# VERIFICATION-COMMITS-DEPLOY.md - Verification, Commits, Deploy, Handoff

---

## 1. Verification: run before claiming done

The canonical backend baseline, frontend build, and any E2E commands for this repo are
listed in `../PROJECT.md` §3. Other docs (planning, phase gates) reference that section
instead of repeating the commands - keep the commands there as the single copy, and
update `PROJECT.md` (not this file) if the toolchain changes.

Also run any tests for the module you touched.

Rules:

- All baseline tests must pass at every phase boundary.
- Do not edit or delete a test to make it pass. If a test fails, either the code is wrong or the test's intent changed; reconcile it deliberately and explain.
- A passing build is necessary but not sufficient. If you changed runtime behavior, say whether you actually ran it. If you did not, say so plainly.
- Tests must not require real provider keys or network.
- **Tests clean up after themselves.** Anything a run creates - temp files and
  directories, seeded rows, generated fixtures, scratch projects, artifact dirs - is
  removed by the same run, on failure as well as on success. A baseline is only
  meaningful from a clean tree: a leftover from an earlier run can make a broken run
  look like it passed, which is the same misleading success `REPO-RULES.md` §2 forbids
  in product code. This covers one-off verification you run by hand, not just the
  repo's own suite. If an artifact must survive (a coverage report, a build output), it
  is named and gitignored deliberately, never left behind by accident.

### Why cleanup can fail — and how to add a hard gate

Like `REPO-RULES.md` §0, this is a **review-only rule**: it holds only when whoever
just ran the tests remembers to check afterward. Under pressure to report a passing
run, that check is easy to skip — the run passed, so the instinct is to say so and move
on, not to go back and inspect the tree for what it left behind.

An opt-in script closes that gap by moving the check out of memory and into the shell:

- **`SCRIPTS/check-clean-tree.sh`** — blocks when `git status` shows untracked files
  or directories. Wire it into a git pre-commit hook (alongside `SCRIPTS/pre-commit`
  if that is already installed for §0) or into CI as a `check-*.sh` step; see the
  script header for both.

Be clear about what it buys: it catches leftovers still sitting in the working tree
at the moment it runs. It cannot see seeded database rows or state in an external
service, so those still rely on the rule being followed by hand.

---

## 2. Deployment caveats

The actual deploy target(s), commands, and any fallback paths that must not be removed
are in `../PROJECT.md` §5 — read it before deploying anything. General rules that apply
regardless of target:

- Deploy is a careful, separate step. Do not deploy unless asked.
- Building/pushing a deploy image or bundle is only for explicit deploy requests, never
  a side effect of finishing a feature.

---

## 3. Stopping for frontend confirmation

When working from a plan, this is the same ritual as the phase file's `User test`
section: hand the user concrete steps and wait for confirmation before continuing. The
rules below apply to any task, planned or not.

You cannot see the rendered UI. Whenever finishing a task correctly depends on how
something looks or behaves in the browser - layout, styling, visual regression,
"does this screen still work," interaction/UX feel, or any change whose only real
check is the user looking at it - stop and ask the user to confirm before continuing.

Automated tests (Playwright or equivalent) can prove *that* a workflow functions; they
cannot judge *how it looks or feels*, unless this repo also has visual regression /
screenshot-diff tooling (`../PROJECT.md` §3 would name it). So run the automated
coverage first and let it settle every functional question it can — what's left for the
human is narrower than "test the feature," usually just "does this look/feel right."
Ask for exactly that gap, not a repeat of what the automated specs already proved.

Give step-by-step guides for how to verify each element that needs verifying. Do not
guess that the frontend is fine, and do not press on to the next step that assumes it.
Backend logic and build/test passing are not a substitute for a human looking at the
screen.

State plainly what you changed, what you could not verify yourself, and exactly what
to look at: route, screen, and action. Then wait.

---

## 4. Commits and safety checkpoints

Commit freely; commits are cheap and are your safety net. They do not need the user's
verification or approval.

- **Make periodic safety commits** whenever you reach a good, safe stopping point: a coherent unit of work where the tree is consistent and the baseline passes. Do not wait for a whole phase if a mid-phase checkpoint is sensibly self-contained.
- **Always commit a working state before the user tests it.** Whenever you hand off something that works from the user's end, such as asking them to confirm the frontend, there must be a commit capturing exactly that state first, unless an identical commit of that same state was already made. The user should never be testing uncommitted work that has no restore point.
- Keep commits coherent: one logical change each, with a clear message. Follow the plan's one phase per commit where a plan applies, plus smaller safety checkpoints within a phase as needed.
- Never commit secrets, keys, or `.env` files.
- Commit on the working branch, not the default branch, unless told otherwise. If
  `PROJECT.md` §1 states a single-developer, single-branch model, commit there directly
  unless the user asks for a branch.
- **Check for repo automation before assuming there is none.** A pre-commit hook, a
  docs gate, seam/config indexes to regenerate, or a post-commit hook that fires on
  commit may or may not exist in this repo — look (`.git/hooks/`, `githooks/`,
  `.github/workflows/`, `SCRIPTS/`) rather than assuming either way. If `PROJECT.md` §2
  says no such tooling exists here, trust that instead of re-deriving it every session.

---

## 5. Completion summary format

End every task with:

```text
## Summary
- what changed and why

## Files Changed
- path - one line each

## Verification
- exact commands run and their result, or "not run" stated plainly

## Notes / Risks
- anything uncertain, deferred, or worth a human's attention
```
