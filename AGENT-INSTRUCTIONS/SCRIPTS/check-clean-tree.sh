#!/usr/bin/env bash
# check-clean-tree.sh — enforces VERIFICATION-COMMITS-DEPLOY.md §1
# ("tests clean up after themselves").
#
# Blocks when the working tree has untracked files or directories. Verification
# (a test run, a one-off manual check) is supposed to happen before commit, so
# anything it created should already be gone by the time you get here. An untracked
# leftover at this point is exactly the failure §1 describes — a scratch project,
# seeded fixture, or temp dir nobody meant to keep. A leftover from an earlier run can
# make a broken run look like it passed, which is the same misleading success
# REPO-RULES.md §2 forbids in product code — so this belongs in a gate, not in
# nobody's head.
#
# Usage: run from anywhere inside the repo; it resolves the root via git itself.
#
#   bash AGENT-INSTRUCTIONS/SCRIPTS/check-clean-tree.sh
#
# Wire it into whichever gate already runs for this repo:
#
#   - As a git hook: call it from .git/hooks/pre-commit (or from
#     SCRIPTS/pre-commit if that is already installed there for REPO-RULES.md §0 —
#     append a line, do not replace the file, since only one script can occupy that
#     hook path):
#       bash AGENT-INSTRUCTIONS/SCRIPTS/check-clean-tree.sh || exit 1
#   - As a CI step, alongside the other SCRIPTS/check-*.sh checks in README.md
#     "Running the checkers in CI":
#       - run: bash AGENT-INSTRUCTIONS/SCRIPTS/check-clean-tree.sh
#
# What this actually catches: untracked files/dirs left in the working tree at the
# moment it runs. It is not a full implementation of §1 — seeded database rows,
# external service state, or anything outside this working tree are invisible to it
# and still rely on the rule being followed by hand.
#
# A deliberate artifact (coverage report, build output) is not an exception to fight
# past this gate. §1 already says such a thing must be named and gitignored, which
# makes it invisible to `git status` rather than untracked.

set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
UNTRACKED="$(git -C "$REPO_ROOT" status --porcelain | grep '^??' || true)"

if [[ -n "$UNTRACKED" ]]; then
  printf '\n  ✗  BLOCKED — untracked files in the working tree.\n\n' >&2
  printf '     VERIFICATION-COMMITS-DEPLOY.md §1 requires test and verification runs\n' >&2
  printf '     to clean up after themselves. These are untracked right now:\n\n' >&2
  echo "$UNTRACKED" | sed 's/^/       /' >&2
  printf '\n     Delete them if they are leftovers, `git add` them if they belong in\n' >&2
  printf '     this change, or add them to .gitignore if they are a deliberate, named\n' >&2
  printf '     artifact (a coverage report, a build output).\n\n' >&2
  exit 1
fi
