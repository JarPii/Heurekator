#!/usr/bin/env bash
# Enforces the mechanically-checkable invariants from WORKFLOWS/README.md's Enforced-by
# list (items 1-2): every workflow entry's spec file exists, and its case name is found
# as text inside that file. Items 3-4 (is the sequence actually right, does an entry
# stay a reference instead of a second description) are judgment calls no script can
# make — see the README for why — and stay review-only.
#
# Spec file paths in MAP.md are relative to the project root, i.e. the parent of this
# AGENT-INSTRUCTIONS/ package (see PROJECT.md §2's layout) — not relative to this file.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(dirname "$ROOT")"
FILE="$ROOT/WORKFLOWS/MAP.md"

if [[ ! -f "$FILE" ]]; then
  echo "check-workflow-map: missing $FILE" >&2
  exit 2
fi

output="$(awk '
  BEGIN { in_map = 0; incomment = 0; current = ""; n = 0; itemidx = 0 }
  {
    line = $0
    if (!in_map) {
      if (line ~ /^## Workflows/) in_map = 1
      next
    }
    if (incomment) {
      if (line ~ /-->/) incomment = 0
      next
    }
    if (line ~ /<!--/) { incomment = 1; next }
    if (line ~ /^### /) {
      wf = line
      sub(/^### /, "", wf)
      gsub(/^[ \t]+|[ \t]+$/, "", wf)
      order[++n] = wf
      count[wf]++
      current = wf
      next
    }
    if (line ~ /^[ \t]*[0-9]+\./) {
      rest = line
      fieldn = 0
      spec = ""; casename = ""
      while (match(rest, /`[^`]*`/)) {
        val = substr(rest, RSTART + 1, RLENGTH - 2)
        fieldn++
        if (fieldn == 1) spec = val
        else if (fieldn == 2) casename = val
        rest = substr(rest, RSTART + RLENGTH)
      }
      itemidx++
      if (fieldn < 2) {
        print "ERR:MALFORMED:" NR ":" current
      } else {
        item_wf[itemidx] = current
        item_spec[itemidx] = spec
        item_case[itemidx] = casename
        item_ok[itemidx] = 1
      }
    }
  }
  END {
    for (i = 1; i <= n; i++) {
      t = order[i]
      if (count[t] > 1 && !reported[t]) {
        print "ERR:DUP:" t
        reported[t] = 1
      }
    }
    for (i = 1; i <= itemidx; i++) {
      if (item_ok[i] == 1) {
        print "ITEM:" item_wf[i] ":" item_spec[i] ":" item_case[i]
      }
    }
    print "SUMMARY:" n ":" itemidx
  }
' "$FILE" || true)"

fail=0
total_workflows=0
total_items=0

while IFS= read -r line; do
  case "$line" in
    ERR:DUP:*)
      wf="${line#ERR:DUP:}"
      echo "FAIL: workflow '$wf' is defined more than once (### heading repeated)."
      fail=1
      ;;
    ERR:MALFORMED:*)
      rest="${line#ERR:MALFORMED:}"
      lineno="${rest%%:*}"
      wf="${rest#*:}"
      echo "FAIL: line $lineno under workflow '$wf' is not \`spec\` — \`case\` (need two backtick-quoted fields)."
      fail=1
      ;;
    ITEM:*)
      rest="${line#ITEM:}"
      wf="${rest%%:*}"; rest="${rest#*:}"
      spec="${rest%%:*}"; casename="${rest#*:}"
      if [[ ! -f "$PROJECT_ROOT/$spec" ]]; then
        echo "FAIL: workflow '$wf' references spec file '$spec', which does not exist at '$PROJECT_ROOT/$spec'."
        fail=1
      elif ! grep -qF -- "$casename" "$PROJECT_ROOT/$spec"; then
        echo "FAIL: workflow '$wf' references case '$casename' in '$spec', but that text was not found in the file."
        fail=1
      fi
      ;;
    SUMMARY:*)
      IFS=':' read -r _ total_workflows total_items <<< "$line"
      ;;
  esac
done <<< "$output"

if [[ "$fail" -eq 1 ]]; then
  echo
  echo "FAIL: WORKFLOWS/MAP.md has broken references or duplicate workflows."
  exit 1
fi

echo "PASS: WORKFLOWS/MAP.md checked ($total_workflows workflows, $total_items use-case references)."
