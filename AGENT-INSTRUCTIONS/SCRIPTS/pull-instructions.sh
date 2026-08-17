#!/usr/bin/env bash
# Vendors the portable AGENT-INSTRUCTIONS engine into another repo, and — on first run
# only — seeds the project-owned files that engine expects to exist. Re-running this
# script is how a downstream repo picks up upstream changes: portable files are
# overwritten every time, project-owned files are created once and never touched again.
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: pull-instructions.sh <source> [target-repo-root]

<source>            Path to a local AGENT-INSTRUCTIONS checkout, or a git URL (cloned to
                    a temp dir with --depth 1).
[target-repo-root]  The repo to install into. Defaults to the current directory. The
                    package is placed in <target-repo-root>/AGENT-INSTRUCTIONS/ — every
                    cross-reference in the docs is written relative to that path, so it
                    is not optional. Passing the AGENT-INSTRUCTIONS directory itself
                    also works and will not create a nested copy.

Every run overwrites the portable engine:
  BUILDING/ PLANNING/ SUBAGENTS/ PROJECT.template.md SCRIPTS/*.sh
  DECISIONS/README.md DOMAIN/README.md WORKFLOWS/README.md PLANS/README.md

Only created if missing in the target (never overwritten again — these become
project-owned the moment they exist):
  PROJECT.md (seeded from PROJECT.template.md)
  DECISIONS/LOG.md DOMAIN/CONCEPTS.md WORKFLOWS/MAP.md
  SCRIPTS/portability-allowlist.txt
  <repo-root>/AGENTS.md and <repo-root>/CLAUDE.md — the entrypoint the harnesses
  read on their own, pointing at this package. Skipped when the repo already has
  one; add the pointer there by hand in that case.

Nothing else in the target is touched or deleted. If an upstream file was
intentionally removed, this script won't remove your copy — check the sync output
against upstream's own history and delete stale files by hand if needed.
EOF
  exit 1
}

[[ $# -ge 1 ]] || usage
SRC_ARG="$1"
REPO_ARG="${2:-$(pwd)}"

if [[ ! -d "$REPO_ARG" ]]; then
  echo "pull-instructions: target '$REPO_ARG' is not a directory." >&2
  exit 2
fi
REPO_ROOT="$(cd "$REPO_ARG" && pwd)"

# The package always lives in <repo-root>/AGENT-INSTRUCTIONS/. Installing it flat into
# the repo root would collide with the project's own SCRIPTS/ and break every
# `AGENT-INSTRUCTIONS/...` path the docs reference. Accept the package directory itself
# too, so pointing at an existing install updates it instead of nesting a second copy.
if [[ "$(basename "$REPO_ROOT")" == "AGENT-INSTRUCTIONS" || -f "$REPO_ROOT/PROJECT.template.md" ]]; then
  TARGET="$REPO_ROOT"
else
  TARGET="$REPO_ROOT/AGENT-INSTRUCTIONS"
fi

# Where the repo's own agent entrypoint (CLAUDE.md / AGENTS.md) belongs: the directory
# ABOVE the package, because that is the only place the harnesses look. Empty means
# "do not seed one" — that is the standalone checkout of this package itself, which is
# not vendored into any repo and therefore has no consumer entrypoint to seed.
if [[ "$TARGET" != "$REPO_ROOT" ]]; then
  REPO_TOP="$REPO_ROOT"                                   # normal install
elif [[ "$(basename "$TARGET")" == "AGENT-INSTRUCTIONS" ]]; then
  REPO_TOP="$(dirname "$TARGET")"                         # pointed straight at an install
else
  REPO_TOP=""                                             # standalone checkout
fi

TMP_CLONE=""
cleanup() { [[ -n "$TMP_CLONE" ]] && rm -rf "$TMP_CLONE"; return 0; }
trap cleanup EXIT

if [[ "$SRC_ARG" =~ ^(https?://|git@|ssh://) ]]; then
  TMP_CLONE="$(mktemp -d)"
  git clone --depth 1 --quiet "$SRC_ARG" "$TMP_CLONE"
  SRC="$TMP_CLONE"
else
  SRC="$(cd "$SRC_ARG" && pwd)"
fi

if [[ ! -f "$SRC/PROJECT.template.md" ]]; then
  echo "pull-instructions: $SRC doesn't look like an AGENT-INSTRUCTIONS checkout (no PROJECT.template.md)" >&2
  exit 2
fi

mkdir -p "$TARGET"
echo "Installing into: $TARGET"

# Replace a file without ever writing into the inode that is already there.
#
# `cp` opens the destination with O_TRUNC and writes in place, so it mutates the SAME
# inode. When the destination is a script this very process is executing — and it is:
# adopt.sh and this script both live in SCRIPTS/ and get synced — bash, which reads its
# input lazily, keeps its old byte offset into content that has just changed underneath
# it. It lands mid-token and dies with a syntax error partway through, so everything
# after the sync step silently never runs.
#
# Writing a temp file and renaming it gives the new content a new inode. The running
# process keeps reading the old one to the end, while the name points at the new file
# for everyone else. rename(2) is also atomic, so an interrupted sync can never leave a
# half-written script behind.
install_file() {
  local src="$1" dst="$2"
  local tmp="${dst}.tmp.$$"
  cp "$src" "$tmp"
  mv -f "$tmp" "$dst"
}

sync_always() {
  local rel="$1"
  local src="$SRC/$rel"
  local dst="$TARGET/$rel"
  [[ -e "$src" ]] || return 0
  mkdir -p "$(dirname "$dst")"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    local f rp
    while IFS= read -r -d '' f; do
      rp="${f#"$src/"}"
      mkdir -p "$(dirname "$dst/$rp")"
      install_file "$f" "$dst/$rp"
    done < <(find "$src" -type f -print0)
  else
    install_file "$src" "$dst"
  fi
  echo "synced   $rel"
}

seed_once() {
  local rel="$1"
  local seed_src="${2:-$SRC/$rel}"
  local dst="$TARGET/$rel"
  if [[ -e "$dst" ]]; then
    echo "kept     $rel (already exists, not overwritten)"
    return 0
  fi
  [[ -e "$seed_src" ]] || return 0
  mkdir -p "$(dirname "$dst")"
  install_file "$seed_src" "$dst"
  echo "seeded   $rel"
}

for rel in BUILDING PLANNING SUBAGENTS \
           PROJECT.template.md \
           DECISIONS/README.md DOMAIN/README.md WORKFLOWS/README.md PLANS/README.md; do
  sync_always "$rel"
done

# Maintainer-only tools operate ON a fleet of consumers from the upstream checkout.
# Shipping them into every consumer would be confusing noise, so they never sync.
maintainer_only=" sync-all.sh "

mkdir -p "$TARGET/SCRIPTS"
for f in "$SRC"/SCRIPTS/*.sh "$SRC"/SCRIPTS/*.py "$SRC"/SCRIPTS/pre-commit; do
  [[ -e "$f" ]] || continue
  base="$(basename "$f")"
  [[ "$maintainer_only" == *" $base "* ]] && continue
  # This loop replaces adopt.sh and this script itself — see install_file.
  install_file "$f" "$TARGET/SCRIPTS/$base"
  echo "synced   SCRIPTS/$base"
done

seed_once "PROJECT.md" "$SRC/PROJECT.template.md"
seed_once "DECISIONS/LOG.md"
seed_once "DOMAIN/CONCEPTS.md"
seed_once "WORKFLOWS/MAP.md"
seed_once "SCRIPTS/portability-allowlist.txt"

# The entrypoint the harnesses read on their own. Without it nothing points an agent at
# this package, so it only gets read when a human remembers to say so every session —
# which is the one thing the package exists to stop being necessary. Seeded at the repo
# root, never overwritten: a repo that already has its own CLAUDE.md/AGENTS.md keeps it,
# and adding the pointer by hand there is a one-line edit.
seed_root() {
  local rel="$1" seed_src="$2"
  [[ -n "$REPO_TOP" ]] || return 0
  local dst="$REPO_TOP/$rel"
  if [[ -e "$dst" ]]; then
    echo "kept     $rel (already exists — if it does not point at AGENT-INSTRUCTIONS/, add that by hand)"
    return 0
  fi
  [[ -e "$seed_src" ]] || return 0
  install_file "$seed_src" "$dst"
  echo "seeded   $rel (repo root)"
}

seed_root "AGENTS.md" "$SRC/AGENTS.template.md"
seed_root "CLAUDE.md" "$SRC/CLAUDE.template.md"

# Records which upstream commit this install came from. Without it the only way to
# answer "which version is this repo on?" is to diff file contents against upstream's
# history one commit at a time, and nothing can report that a consumer has fallen
# behind. check-engine-drift.sh reads this file; sync-all.sh reports on it.
sha="$(git -C "$SRC" rev-parse HEAD 2>/dev/null || echo "")"
if [[ -n "$sha" ]]; then
  tag="$(git -C "$SRC" describe --tags --exact-match HEAD 2>/dev/null \
       || git -C "$SRC" describe --tags --abbrev=0 HEAD 2>/dev/null \
       || echo '-')"
else
  sha="unknown"
  tag="-"
fi
# Record where the engine came from by its canonical remote, not by the path we happened
# to read it through. adopt.sh clones into a fresh mktemp directory every run, so using
# the local path wrote a different `source:` line each time and produced a diff on every
# sync even when the commit was identical.
src_id="$(git -C "$SRC" remote get-url origin 2>/dev/null || true)"
[[ -n "$src_id" ]] || src_id="$SRC_ARG"

cat > "$TARGET/.engine-version" <<EOF
# Generated by pull-instructions.sh — do not edit by hand.
# Identifies the upstream AGENT-INSTRUCTIONS commit this install was synced from.
# Commit this file: drift is only visible if it is in the repo's history.
commit: $sha
tag:    $tag
source: $src_id
synced: $(date -u +%Y-%m-%d)
EOF
echo "stamped  .engine-version ($tag @ ${sha:0:8})"

echo
echo "Done. Review the diff, then run these before committing:"
echo "  python3 $TARGET/SCRIPTS/gen_agents.py     # generates .claude/ and .opencode/ agents"
echo "  bash    $TARGET/SCRIPTS/check-portability.sh"
echo "Tip: SCRIPTS/adopt.sh automates scenario detection and next-step guidance."
