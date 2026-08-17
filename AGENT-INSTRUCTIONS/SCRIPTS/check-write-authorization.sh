#!/usr/bin/env bash
# check-write-authorization.sh — PreToolUse hook for Claude CLI.
#
# Blocks Edit / Write / MultiEdit tool calls until the user explicitly
# authorizes the current work session.  Wire up in .claude/settings.json:
#
#   {
#     "hooks": {
#       "PreToolUse": [
#         {
#           "matcher": "Edit|Write|MultiEdit",
#           "hooks": [
#             {
#               "type": "command",
#               "command": "bash AGENT-INSTRUCTIONS/SCRIPTS/check-write-authorization.sh"
#             }
#           ]
#         }
#       ]
#     }
#   }
#
# (If AGENT-INSTRUCTIONS is not a subdirectory, adjust the path accordingly.)
#
# To authorize a work session:  touch .session-authorized
# To pause / revoke:            rm .session-authorized
#
# Keep .session-authorized in .gitignore — it is a local runtime flag,
# not a repo artifact.
#
# Why this exists:
#   §0 of REPO-RULES.md requires an explicit decision to act before any edits.
#   A review-only rule holds only when the agent decides to follow it.
#   This hook moves the gate from the agent's judgment to the shell —
#   a misread signal produces a blocked tool call, not six changed files.
#
# What it does NOT do:
#   The matcher covers Edit / Write / MultiEdit only. An agent holding a shell tool
#   can still write files through it, and can run 'touch .session-authorized' itself.
#   This is a guard against an agent talking itself into acting on an ambiguous
#   signal — not a sandbox, and not a defense against one that intends to bypass it.
#   For that, restrict the tools themselves rather than relying on this hook.

set -euo pipefail

# Resolve the repo root: prefer git, fall back to the grandparent of this script.
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  :
else
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

AUTH_FILE="$REPO_ROOT/.session-authorized"

if [[ ! -f "$AUTH_FILE" ]]; then
  printf '\n  ✗  BLOCKED — no active work session.\n\n' >&2
  printf '     §0 of REPO-RULES.md requires an explicit decision to act before\n' >&2
  printf '     any edits.  State the intent, wait for acknowledgment, then run:\n\n' >&2
  printf '       touch .session-authorized\n\n' >&2
  printf '     to open the gate.  Remove the file to pause again.\n\n' >&2
  exit 1
fi
