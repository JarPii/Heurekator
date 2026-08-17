#!/usr/bin/env bash
# adopt.sh — Unified adoption entry point for AGENT-INSTRUCTIONS.
#
# Always fetches a fresh copy of the engine from GitHub (no local source
# required), detects which of three scenarios applies to the target repo,
# runs the right setup, and prints concrete next steps.
#
# Usage:
#   bash adopt.sh [target-root]
#
# target-root defaults to the current directory.
#
# Can also be run directly from GitHub without a local checkout:
#   Public repo:
#     bash <(curl -sSL https://raw.githubusercontent.com/JarPii/AGENT-INSTRUCTIONS/main/SCRIPTS/adopt.sh)
#   Private repo (requires gh CLI):
#     gh api repos/JarPii/AGENT-INSTRUCTIONS/contents/SCRIPTS/adopt.sh \
#       --jq '.content' | base64 -d | bash
#
# Scenarios detected automatically:
#   1   — New / empty project: no code, no AGENT-INSTRUCTIONS yet.
#   2a  — Existing project:    has code but no AGENT-INSTRUCTIONS/ yet.
#   2b  — Sync:                AGENT-INSTRUCTIONS/ already present; update engine.

set -euo pipefail

# Override to install from a local checkout or a fork instead of the canonical remote —
# useful for testing a change before it is pushed, and for machines without network
# access to GitHub.
SRC_URL="${AGENT_INSTRUCTIONS_SRC:-https://github.com/JarPii/AGENT-INSTRUCTIONS.git}"

FORCE=0
FETCH=1
TARGET_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)    FORCE=1; shift ;;
    --no-fetch) FETCH=0; shift ;;
    -h|--help)
      sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \?//' >&2
      echo "  --force      Proceed despite the safety checks below." >&2
      echo "  --no-fetch   Skip 'git fetch'; the behind-remote check then uses" >&2
      echo "               possibly-stale refs." >&2
      exit 0 ;;
    -*) echo "adopt: unknown option '$1'" >&2; exit 2 ;;
    *)  TARGET_ARG="$1"; shift ;;
  esac
done
TARGET="$(cd "${TARGET_ARG:-$(pwd)}" && pwd)"

# The package is installed into <repo-root>/AGENT-INSTRUCTIONS/, never flat into the
# repo root: the docs' cross-references are all written relative to that path, and a
# flat install would merge into the project's own SCRIPTS/ directory.
PKG="$TARGET/AGENT-INSTRUCTIONS"

# ── Helpers ──────────────────────────────────────────────────────────────────

hr()  { printf '\n%s\n' "$(printf '═%.0s' {1..60})"; }
ok()  { printf '  ✓  %s\n' "$*"; }
tip() { printf '  →  %s\n' "$*"; }

# ── Step 1: Fetch fresh engine into a temp dir ────────────────────────────────

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "Fetching AGENT-INSTRUCTIONS from GitHub…"
git clone --depth 1 --quiet "$SRC_URL" "$TMP/src"
ok "Engine fetched to temp dir."

# ── Step 2: Detect scenario ───────────────────────────────────────────────────

detect_scenario() {
  # 2b — an engine is already installed. BUILDING/ is the test rather than
  # PROJECT.template.md, because an install predating the template still needs to be
  # treated as an upgrade. Testing only for the template made an old install look like
  # a fresh adopt, which then printed brownfield onboarding steps for a project whose
  # PROJECT.md, LOG.md and CONCEPTS.md were already filled in.
  if [[ -f "$PKG/PROJECT.template.md" || -d "$PKG/BUILDING" ]]; then
    echo "2b"; return
  fi

  # 2a — Code exists but no AGENT-INSTRUCTIONS
  if find "$TARGET" -maxdepth 4 \
       \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" \
       -o -name "*.rs" -o -name "*.java" -o -name "*.rb" -o -name "*.php" \
       -o -name "package.json" -o -name "go.mod" -o -name "Cargo.toml" \
       -o -name "Makefile" -o -name "*.gradle" -o -name "pom.xml" \) \
       -not -path "*/.git/*" -not -path "*/node_modules/*" \
       -not -path "*/AGENT-INSTRUCTIONS/*" \
       2>/dev/null | grep -q .; then
    echo "2a"; return
  fi

  # 1 — New / empty project
  echo "1"
}

SCENARIO="$(detect_scenario)"

case "$SCENARIO" in
  1)   LABEL="New project (no existing code or AGENT-INSTRUCTIONS)" ;;
  2a)  LABEL="Existing project — AGENT-INSTRUCTIONS not yet present" ;;
  2b)  LABEL="Existing AGENT-INSTRUCTIONS — syncing engine update" ;;
esac

echo "Scenario detected: $LABEL"

# ── Step 2b: Refuse to write into a tree where that would destroy work ───────
#
# Syncing rewrites portable files and seeds any project-owned file that is missing.
# On a checkout that is behind its own remote, both are dangerous: the engine may
# already have been updated on that remote from another machine, and files that exist
# there but not here get re-seeded BLANK, so the empty copies then collide with the
# real ones on the next merge. Warn-and-continue is not enough for that; it has to stop.

problems=()

# This guard protects deliberate local customizations. It must not fire on the sync's
# own output: every successful sync leaves modified portable files until they are
# committed, and a naive "any tracked change blocks" rule made the next run fail with
# exit 4 — so adopt.sh could never be run twice without committing in between, and a
# crashed run could not be retried at all.
#
# So a modified file only counts when it is something the sync would actually overwrite
# AND its content differs from what upstream is about to write. A file that already
# matches upstream is an applied sync, not a customization. Project-owned files are
# skipped outright because seed_once never overwrites them.

# Files pull-instructions.sh seeds once and never overwrites — see its seed_once calls.
project_owned=" PROJECT.md DECISIONS/LOG.md DOMAIN/CONCEPTS.md WORKFLOWS/MAP.md SCRIPTS/portability-allowlist.txt .engine-version "

real_edits=""
if git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    rel="${f#AGENT-INSTRUCTIONS/}"
    [[ "$project_owned" == *" $rel "* ]] && continue
    up="$TMP/src/$rel"
    # Not shipped by upstream, or already identical to it → the sync changes nothing here.
    [[ -f "$up" ]] || continue
    cmp -s "$TARGET/$f" "$up" && continue
    real_edits+="       $f"$'\n'
  done < <(
    { git -C "$TARGET" diff --name-only -- AGENT-INSTRUCTIONS 2>/dev/null
      git -C "$TARGET" diff --cached --name-only -- AGENT-INSTRUCTIONS 2>/dev/null
    } | sort -u
  )

  if [[ -n "$real_edits" ]]; then
    problems+=("Local edits under AGENT-INSTRUCTIONS/ differ from what upstream will
       write, and would be overwritten:
$real_edits       Commit or stash them first.")
  fi

  if git -C "$TARGET" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    [[ "$FETCH" -eq 1 ]] && git -C "$TARGET" fetch --quiet 2>/dev/null || true
    behind="$(git -C "$TARGET" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)"
    if [[ "$behind" -gt 0 ]]; then
      problems+=("This checkout is ${behind} commit(s) behind its remote, which may already
       carry a newer engine and project-owned files that are missing here.
       Pull first:  git -C \"$TARGET\" pull")
    fi
  fi
else
  # Legitimate for a brand-new project, so this warns rather than blocks — but the
  # adopter should know there is no diff to review and no way to undo.
  echo ""
  echo "  !!  $TARGET is not a git repository."
  echo "      Nothing here can be reviewed as a diff or undone after the fact."
  echo ""
fi

if [[ ${#problems[@]} -gt 0 ]]; then
  echo ""
  echo "  ✗  Not safe to write into $TARGET:"
  echo ""
  for p in "${problems[@]}"; do echo "     - $p"; echo ""; done
  if [[ "$FORCE" -eq 1 ]]; then
    echo "     --force given — continuing anyway."
    echo ""
  else
    echo "     Resolve the above and re-run, or pass --force to override."
    exit 4
  fi
fi

# ── Step 3: Run pull-instructions.sh ─────────────────────────────────────────

bash "$TMP/src/SCRIPTS/pull-instructions.sh" "$TMP/src" "$TARGET"

# ── Step 4: Generate subagents ───────────────────────────────────────────────
#
# A missing script means the install itself is broken, so fail rather than skip:
# silently skipping here is what leaves an adopted repo with no runnable subagents
# while the primers still tell the agent to delegate to them. A missing python3 is a
# real environment limit, so warn loudly and continue.

GEN="$PKG/SCRIPTS/gen_agents.py"
if [[ ! -f "$GEN" ]]; then
  echo "adopt: expected $GEN after sync — install is broken, not continuing." >&2
  exit 3
fi
if command -v python3 &>/dev/null; then
  python3 "$GEN"
  ok "Subagent files generated."
else
  echo ""
  echo "  !!  python3 not found — subagents were NOT generated."
  echo "      .claude/agents/ and .opencode/agents/ do not exist, so seam-scout,"
  echo "      invariant-reviewer, phase-spec-auditor and phase-implementation-reviewer"
  echo "      cannot be spawned. Install python3 and run:"
  echo "          python3 $GEN"
  echo ""
fi

# ── Step 5: Run portability check ────────────────────────────────────────────

CHECK="$PKG/SCRIPTS/check-portability.sh"
if [[ ! -f "$CHECK" ]]; then
  echo "adopt: expected $CHECK after sync — install is broken, not continuing." >&2
  exit 3
fi
bash "$CHECK" || true   # non-fatal: PROJECT.md is a blank template on first seed

# ── Step 6: Print scenario-specific next steps ───────────────────────────────

hr
echo ""
ok "Done.  Target: $TARGET"
echo ""

# A repo that already had its own AGENTS.md keeps it, so the package it just installed
# is invisible to every harness that reads that file. Only AGENTS.md is checked: the
# seeded CLAUDE.md names the package itself, so it always matches and would mask this.
if [[ -f "$TARGET/AGENTS.md" ]] && ! grep -qs "AGENT-INSTRUCTIONS" "$TARGET/AGENTS.md"; then
  echo "  !!  This repo's own AGENTS.md does not mention AGENT-INSTRUCTIONS, so it was"
  echo "      left untouched. Harnesses that read AGENTS.md will not find this package"
  echo "      until you add a line there, e.g.:"
  echo ""
  echo "          Read AGENT-INSTRUCTIONS/PROJECT.md and"
  echo "          AGENT-INSTRUCTIONS/BUILDING/REPO-RULES.md at the start of every session."
  echo ""
fi

case "$SCENARIO" in
  1)
    echo "  AGENT-INSTRUCTIONS seeded into a new project."
    echo ""
    echo "  Next steps:"
    tip "1. Fill in AGENT-INSTRUCTIONS/PROJECT.md"
    tip "   (sections: what this repo is, layout, test commands,"
    tip "    hard invariants, deploy)"
    tip "2. Start a vision discovery session:"
    tip "   Read  AGENT-INSTRUCTIONS/PLANNING/VISION-PRIMER.md"
    tip "   Send the copy-paste primer at the end of that file"
    tip "   to your AI agent to begin the structured interview."
    tip "3. Commit when PROJECT.md is filled and checks pass:"
    tip "   AGENT-INSTRUCTIONS/SCRIPTS/check-portability.sh"
    ;;

  2a)
    echo "  AGENT-INSTRUCTIONS seeded into an existing project."
    echo ""
    echo "  Your code is already there — the agent should read it, not guess."
    echo ""
    echo "  Next steps:"
    tip "1. Run the brownfield onboarding session:"
    tip "   Read  AGENT-INSTRUCTIONS/PLANNING/BROWNFIELD-PRIMER.md"
    tip "   Send the copy-paste primer at the end of that file"
    tip "   to your AI agent. It will read the codebase and fill in"
    tip "   PROJECT.md, DOMAIN/CONCEPTS.md, and WORKFLOWS/MAP.md."
    tip "2. Review what the agent produced, correct anything wrong."
    tip "3. Commit when checks pass:"
    tip "   AGENT-INSTRUCTIONS/SCRIPTS/check-portability.sh"
    ;;

  2b)
    echo "  Portable engine updated. Project-owned files untouched."
    echo ""
    echo "  Next steps:"
    tip "1. Review the diff:"
    tip "   git diff AGENT-INSTRUCTIONS/"
    tip "2. Run portability check:"
    tip "   AGENT-INSTRUCTIONS/SCRIPTS/check-portability.sh"
    tip "3. Commit if clean."
    ;;
esac

echo ""
hr
