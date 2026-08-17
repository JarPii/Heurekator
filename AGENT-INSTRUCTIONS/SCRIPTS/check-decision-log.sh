#!/usr/bin/env bash
# Enforces the mechanically-checkable invariants from DECISIONS/README.md §4 (items
# 2-5): every row names what was rejected and why, IDs are unique and monotonic, a
# superseded-by reference points at a real row, and the log is append-only once a row
# is committed. Item 1 (whether a row belongs at all — vision/roadmap-level vs.
# task-level) and items 6-9 are honestly out of reach for a script — see the README for
# why — and stay review-only.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$ROOT/DECISIONS/LOG.md"

if [[ ! -f "$LOG" ]]; then
  echo "check-decision-log: missing $LOG" >&2
  exit 2
fi

strip_comments() {
  awk '
    /<!--/ { incomment=1 }
    incomment { if (/-->/) incomment=0; next }
    { print }
  ' "$1"
}

parse_rows() {
  # emits one tab-separated "ID<TAB>Date<TAB>Decision<TAB>Rejected<TAB>Why<TAB>Status<TAB>Narrative" per data row
  strip_comments "$1" \
    | grep -E '^\|' \
    | grep -vE '^\| *ID *\|' \
    | grep -vE '^\|[-:| ]+\|$' \
    | awk -F'|' '{
        n = NF
        out = ""
        for (i = 2; i < n; i++) {
          v = $i
          gsub(/^[ \t]+|[ \t]+$/, "", v)
          out = out (i > 2 ? "\t" : "") v
        }
        print out
      }'
}

fail=0
declare -A seen_ids
declare -A row_key   # id -> Date\tDecision\tRejected\tWhy  (the immutable fields)
prev_num=0
count=0

while IFS=$'\t' read -r id date decision rejected why status narrative; do
  [[ -z "$id" ]] && continue
  count=$((count + 1))

  if [[ ! "$id" =~ ^D([0-9]+)$ ]]; then
    echo "FAIL: row $count has malformed ID '$id' (expected D<n>)."
    fail=1
    continue
  fi
  num="${BASH_REMATCH[1]}"

  if [[ -n "${seen_ids[$id]:-}" ]]; then
    echo "FAIL: ID '$id' used more than once."
    fail=1
  fi
  seen_ids["$id"]=1

  if (( num <= prev_num )); then
    echo "FAIL: '$id' is not strictly increasing after D$prev_num (append new rows at the bottom, never renumber)."
    fail=1
  fi
  prev_num=$num

  if [[ -z "$rejected" || "$rejected" == "-" ]]; then
    echo "FAIL: '$id' has no Rejected alternative — a row without one isn't a decision worth logging (DECISIONS/README.md §2)."
    fail=1
  fi
  if [[ -z "$why" || "$why" == "-" ]]; then
    echo "FAIL: '$id' has no Why-rejected reason — a rejection without why is half a record (DECISIONS/README.md §4)."
    fail=1
  fi

  if [[ "$status" != "active" && ! "$status" =~ ^superseded\ by\ (D[0-9]+)$ ]]; then
    echo "FAIL: '$id' has invalid Status '$status' (expected 'active' or 'superseded by D<n>')."
    fail=1
  fi

  row_key["$id"]="$date"$'\t'"$decision"$'\t'"$rejected"$'\t'"$why"
done < <(parse_rows "$LOG")

# Second pass: superseded-by references must point at a real row.
while IFS=$'\t' read -r id _date _decision _rejected _why status _narrative; do
  [[ -z "$id" ]] && continue
  if [[ "$status" =~ ^superseded\ by\ (D[0-9]+)$ ]]; then
    target="${BASH_REMATCH[1]}"
    if [[ -z "${seen_ids[$target]:-}" ]]; then
      echo "FAIL: '$id' is marked 'superseded by $target', but $target does not exist in LOG.md."
      fail=1
    fi
  fi
done < <(parse_rows "$LOG")

# Append-only check against the last committed version, when one exists.
if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_root="$(git -C "$ROOT" rev-parse --show-toplevel)"
  rel_path="${LOG#"$git_root"/}"
  if old_content="$(git -C "$git_root" show "HEAD:$rel_path" 2>/dev/null)"; then
    while IFS=$'\t' read -r id date decision rejected why _status _narrative; do
      [[ -z "$id" ]] && continue
      old_key="$date"$'\t'"$decision"$'\t'"$rejected"$'\t'"$why"
      if [[ -n "${row_key[$id]:-}" && "${row_key[$id]}" != "$old_key" ]]; then
        echo "FAIL: '$id' changed a committed field (Date/Decision/Rejected/Why must never change — only Status/Narrative may). LOG.md must be append-only."
        fail=1
      fi
    done < <(echo "$old_content" | parse_rows /dev/stdin)
  else
    echo "NOTE: no committed version of $rel_path yet — skipping append-only check."
  fi
else
  echo "NOTE: not a git repo — skipping append-only check."
fi

if [[ "$fail" -eq 1 ]]; then
  echo
  echo "FAIL: DECISIONS/LOG.md violates one or more invariants (see DECISIONS/README.md §4)."
  exit 1
fi

echo "PASS: DECISIONS/LOG.md checked ($count rows)."
