#!/usr/bin/env bash
# Reports how far this repo's vendored AGENT-INSTRUCTIONS engine has drifted from
# upstream. Drift is silent by construction: pull-instructions.sh only runs when
# someone remembers to run it, and a consumer left on an old engine behaves by old
# rules with nothing anywhere saying so. This turns that into a visible number.
#
# Two modes, deliberately split by cost:
#
#   offline (default)  Reads .engine-version and reports its age. No network, no
#                      upstream checkout — cheap enough to call from a git hook.
#                      Age is a proxy: it cannot know whether upstream actually moved.
#   --upstream SRC     Resolves upstream's real HEAD and reports the exact commit
#                      count and which portable files changed. Needs a checkout or
#                      network.
#
# Exit codes: 0 in sync (or within --max-age), 1 drifted, 2 cannot tell.
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG="$(dirname "$SELF_DIR")"
STAMP="$PKG/.engine-version"

UPSTREAM=""
MAX_AGE=30
QUIET=0

usage() {
  cat >&2 <<'EOF'
Usage: check-engine-drift.sh [--upstream SRC] [--max-age DAYS] [--quiet]

  --upstream SRC   Compare against a real upstream: a local AGENT-INSTRUCTIONS
                   checkout or a git URL. Reports exact commits behind and the
                   portable files that changed.
  --max-age DAYS   Offline mode only: fail if the stamp is older than this.
                   Default 30. Use 0 to disable the age check.
  --quiet          Print only on drift.

Exit: 0 in sync, 1 drifted, 2 undetermined (no stamp / upstream unreachable).
EOF
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --upstream) UPSTREAM="${2:-}"; shift 2 ;;
    --max-age)  MAX_AGE="${2:-}"; shift 2 ;;
    --quiet)    QUIET=1; shift ;;
    -h|--help)  usage ;;
    *) echo "check-engine-drift: unknown argument '$1'" >&2; usage ;;
  esac
done

say() { [[ "$QUIET" -eq 1 ]] || echo "$@"; }

if [[ ! -f "$STAMP" ]]; then
  echo "check-engine-drift: no $STAMP — this install predates version stamping." >&2
  echo "  Re-run pull-instructions.sh (or adopt.sh) once to stamp it." >&2
  exit 2
fi

field() { sed -n "s/^$1:[[:space:]]*//p" "$STAMP" | head -1; }
local_sha="$(field commit)"
local_tag="$(field tag)"
synced="$(field synced)"

# ── Offline mode: age only ───────────────────────────────────────────────────
if [[ -z "$UPSTREAM" ]]; then
  say "engine:  ${local_tag} @ ${local_sha:0:8}   (synced $synced)"
  [[ "$MAX_AGE" -eq 0 ]] && exit 0
  if ! synced_epoch="$(date -d "$synced" +%s 2>/dev/null)"; then
    echo "check-engine-drift: unparseable 'synced' date '$synced'." >&2
    exit 2
  fi
  age_days=$(( ( $(date -u +%s) - synced_epoch ) / 86400 ))
  if [[ "$age_days" -gt "$MAX_AGE" ]]; then
    echo "DRIFT: engine last synced ${age_days} days ago (limit ${MAX_AGE})."
    echo "  This is an age check, not a real comparison — upstream may or may not have moved."
    echo "  Check for real:  $0 --upstream <path-or-url>"
    exit 1
  fi
  say "OK: synced ${age_days} day(s) ago."
  exit 0
fi

# ── Upstream mode: exact comparison ──────────────────────────────────────────
TMP_CLONE=""
cleanup() { [[ -n "$TMP_CLONE" ]] && rm -rf "$TMP_CLONE"; return 0; }
trap cleanup EXIT

if [[ "$UPSTREAM" =~ ^(https?://|git@|ssh://) ]]; then
  TMP_CLONE="$(mktemp -d)"
  if ! git clone --quiet "$UPSTREAM" "$TMP_CLONE" 2>/dev/null; then
    echo "check-engine-drift: cannot reach $UPSTREAM." >&2
    exit 2
  fi
  SRC="$TMP_CLONE"
else
  [[ -d "$UPSTREAM" ]] || { echo "check-engine-drift: '$UPSTREAM' is not a directory." >&2; exit 2; }
  SRC="$(cd "$UPSTREAM" && pwd)"
fi

if ! up_sha="$(git -C "$SRC" rev-parse HEAD 2>/dev/null)"; then
  echo "check-engine-drift: '$UPSTREAM' is not a git checkout." >&2
  exit 2
fi

if [[ "$up_sha" == "$local_sha" ]]; then
  say "OK: engine is current (${local_sha:0:8}, synced $synced)."
  exit 0
fi

# A stamp from a shallow clone, a rewritten history, or a hand-edited install can
# name a commit upstream does not have. Say so rather than printing a bogus count.
if ! git -C "$SRC" cat-file -e "${local_sha}^{commit}" 2>/dev/null; then
  echo "DRIFT: local engine commit ${local_sha:0:8} does not exist upstream."
  echo "  The install is hand-modified, or came from a different/rewritten history."
  echo "  Re-sync to adopt upstream cleanly:  pull-instructions.sh $UPSTREAM <repo-root>"
  exit 1
fi

behind="$(git -C "$SRC" rev-list --count "${local_sha}..${up_sha}")"
ahead="$(git -C "$SRC" rev-list --count "${up_sha}..${local_sha}")"

echo "DRIFT: ${behind} commit(s) behind upstream (local ${local_sha:0:8}, upstream ${up_sha:0:8})."
[[ "$ahead" -gt 0 ]] && echo "  Also ${ahead} commit(s) ahead — this install is on a diverged branch."

changed="$(git -C "$SRC" diff --name-only "${local_sha}..${up_sha}" -- \
             BUILDING PLANNING SUBAGENTS SCRIPTS PROJECT.template.md \
             DECISIONS/README.md DOMAIN/README.md WORKFLOWS/README.md PLANS/README.md 2>/dev/null || true)"
if [[ -n "$changed" ]]; then
  echo "  Portable files changed upstream:"
  printf '%s\n' "$changed" | sed 's/^/    /'
else
  echo "  No portable files changed — the gap is in upstream-only files."
fi

echo "  Update with:  pull-instructions.sh $UPSTREAM <repo-root>"
exit 1
