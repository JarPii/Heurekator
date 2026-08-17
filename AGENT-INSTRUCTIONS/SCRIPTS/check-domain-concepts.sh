#!/usr/bin/env bash
# Enforces the mechanically-checkable invariants from DOMAIN/README.md's Enforced-by
# list (items 1-2): every [[Term]] reference resolves to a real heading, and no term is
# defined twice. Items 3-4 (is the derived definition actually precise, does a term
# choice need a DECISIONS/LOG.md row) are judgment calls no script can make — see the
# README for why — and stay review-only.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$ROOT/DOMAIN/CONCEPTS.md"

if [[ ! -f "$FILE" ]]; then
  echo "check-domain-concepts: missing $FILE" >&2
  exit 2
fi

output="$(awk '
  BEGIN { in_terms = 0; incomment = 0; current = ""; n = 0; pairidx = 0 }
  {
    line = $0
    if (!in_terms) {
      if (line ~ /^## Terms/) in_terms = 1
      next
    }
    if (incomment) {
      if (line ~ /-->/) incomment = 0
      next
    }
    if (line ~ /<!--/) { incomment = 1; next }
    if (line ~ /^### /) {
      term = line
      sub(/^### /, "", term)
      gsub(/^[ \t]+|[ \t]+$/, "", term)
      order[++n] = term
      count[term]++
      current = term
      next
    }
    rest = line
    while (match(rest, /\[\[[^]]+\]\]/)) {
      ref = substr(rest, RSTART + 2, RLENGTH - 4)
      if (current != "") {
        refcount[current]++
        pairidx++
        pair_owner[pairidx] = current
        pair_ref[pairidx] = ref
      }
      rest = substr(rest, RSTART + RLENGTH)
    }
  }
  END {
    fail = 0
    for (i = 1; i <= n; i++) {
      t = order[i]
      if (count[t] > 1 && !reported[t]) {
        print "ERR:DUP:" t
        reported[t] = 1
        fail = 1
      }
    }
    for (i = 1; i <= pairidx; i++) {
      ref = pair_ref[i]
      if (!(ref in count)) {
        print "ERR:DANGLING:" pair_owner[i] ":" ref
        fail = 1
      }
    }
    base = 0; derived = 0
    for (i = 1; i <= n; i++) {
      t = order[i]
      if (classified[t]) continue
      classified[t] = 1
      if (refcount[t] + 0 > 0) derived++
      else base++
    }
    print "SUMMARY:" n ":" base ":" derived
    exit fail
  }
' "$FILE" || true)"

fail=0
summary="0 terms (0 base, 0 derived)"
while IFS= read -r line; do
  case "$line" in
    ERR:DUP:*)
      term="${line#ERR:DUP:}"
      echo "FAIL: term '$term' is defined more than once (### heading repeated) — DOMAIN/README.md item 2."
      fail=1
      ;;
    ERR:DANGLING:*)
      rest="${line#ERR:DANGLING:}"
      owner="${rest%%:*}"
      ref="${rest#*:}"
      echo "FAIL: '$owner' references [[$ref]], but '$ref' has no ### heading in DOMAIN/CONCEPTS.md — DOMAIN/README.md item 1."
      fail=1
      ;;
    SUMMARY:*)
      IFS=':' read -r _ total base derived <<< "$line"
      summary="$total terms ($base base, $derived derived)"
      ;;
  esac
done <<< "$output"

if [[ "$fail" -eq 1 ]]; then
  echo
  echo "FAIL: DOMAIN/CONCEPTS.md has broken references or duplicate terms."
  exit 1
fi

echo "PASS: DOMAIN/CONCEPTS.md checked ($summary)."
