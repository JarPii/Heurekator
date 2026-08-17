#!/usr/bin/env bash
# Enforces the one boundary this package promises: everything outside PROJECT.md is
# copy-paste portable across projects. PROJECT.template.md is the frozen blank
# reference; PROJECT.md is the filled-in instance. Any proper-noun-like word that is
# new in PROJECT.md and also shows up in a generic doc means a project fact leaked
# into a file that's supposed to travel unchanged. That leak is exactly what this
# script exists to catch instead of relying on someone noticing it in review.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT/PROJECT.template.md"
PROJECT="$ROOT/PROJECT.md"
ALLOWLIST="$ROOT/SCRIPTS/portability-allowlist.txt"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "check-portability: missing $TEMPLATE — cannot diff without the frozen baseline." >&2
  exit 2
fi
if [[ ! -f "$PROJECT" ]]; then
  echo "check-portability: missing $PROJECT — nothing to check." >&2
  exit 2
fi

extract_words() {
  LC_ALL=C grep -oE '[A-Za-zÅÄÖåäö]{3,}' "$1" | sort -u
}

# Identifier-shaped tokens inside backtick code spans. A filled-in PROJECT.md keeps its
# service names, ports, commands, and spec paths in code spans, and those are exactly
# the leaks the prose-word scan below cannot see: they are lowercase, hyphenated, or
# contain digits and dots (`chromoscope-frontend`, `3002`, `e2e/persons.spec.js`).
extract_code_tokens() {
  grep -oE '`[^`]+`' "$1" \
    | tr -d '`' \
    | LC_ALL=C grep -oE '[A-Za-z0-9_][A-Za-z0-9_./-]{2,}' \
    | sort -u
}

# Words new in PROJECT.md relative to the blank template.
new_words="$(comm -23 <(extract_words "$PROJECT") <(extract_words "$TEMPLATE"))"

# Prose candidates: proper-noun-shaped only (Titlecase, MixedCase, ALLCAPS). Ordinary
# lowercase prose is not checked — the template already contains nearly all generic
# vocabulary, so what survives the diff is mostly names anyway.
name_candidates="$(printf '%s\n' "$new_words" | LC_ALL=C grep -E '^[A-ZÅÄÖ][A-Za-zåäö]*$' || true)"

# Code-span candidates: anything new relative to the template's own code spans.
code_candidates="$(comm -23 <(extract_code_tokens "$PROJECT") <(extract_code_tokens "$TEMPLATE"))"

candidates="$(printf '%s\n%s\n' "$name_candidates" "$code_candidates" | sed '/^$/d' | sort -u)"

if [[ -f "$ALLOWLIST" ]]; then
  # Drop allowlisted tokens, one per line, '#' comments allowed. Matched as whole-line
  # fixed strings (-x -F) so an entry like `PROJECT.md` cannot regex-match anything else.
  candidates="$(printf '%s\n' "$candidates" \
    | grep -vixF -f <(grep -vE '^\s*#|^\s*$' "$ALLOWLIST" || true) || true)"
fi
candidates="$(printf '%s\n' "$candidates" | sed '/^$/d')"

if [[ -z "$candidates" ]]; then
  echo "PASS: no project-specific tokens found outside PROJECT.md."
  exit 0
fi

# Generic files this package promises stay portable. DECISIONS/LOG.md,
# DECISIONS/<id>-*.md, DOMAIN/CONCEPTS.md, WORKFLOWS/MAP.md (plus any
# WORKFLOWS/<slug>.md narrative), and PLANS/ content other than its README are
# deliberately excluded — those are expected to name real, project-specific things.
mapfile -t generic_files < <(
  find "$ROOT/BUILDING" "$ROOT/PLANNING" "$ROOT/SUBAGENTS" -type f -name '*.md' 2>/dev/null
  [[ -f "$ROOT/DECISIONS/README.md" ]] && echo "$ROOT/DECISIONS/README.md"
  [[ -f "$ROOT/DOMAIN/README.md" ]] && echo "$ROOT/DOMAIN/README.md"
  [[ -f "$ROOT/WORKFLOWS/README.md" ]] && echo "$ROOT/WORKFLOWS/README.md"
  [[ -f "$ROOT/PLANS/README.md" ]] && echo "$ROOT/PLANS/README.md"
  [[ -f "$ROOT/SCRIPTS/README.md" ]] && echo "$ROOT/SCRIPTS/README.md"
)

fail=0
while IFS= read -r token; do
  [[ -z "$token" ]] && continue
  # Case-SENSITIVE, fixed-string, whole-word. Case-insensitive matching used to make
  # every Titlecase prose word in PROJECT.md ('Stack', 'Actor') hit ordinary lowercase
  # prose in the generic docs; those false positives then got allowlisted, which blinded
  # the check to the word permanently. A real product name keeps its capitalization.
  hits="$(grep -rnwF -- "$token" "${generic_files[@]}" 2>/dev/null || true)"
  if [[ -n "$hits" ]]; then
    fail=1
    echo "LEAK: '$token' (from PROJECT.md) found in a generic file:"
    echo "$hits" | sed 's/^/  /'
  fi
done <<< "$candidates"

if [[ "$fail" -eq 1 ]]; then
  echo
  echo "FAIL: project-specific term(s) leaked into generic docs (see above)."
  echo "Fix: rewrite the generic doc to not name the specific thing, point it at"
  echo "PROJECT.md instead, or if the term is legitimately generic vocabulary, add it"
  echo "to SCRIPTS/portability-allowlist.txt with a one-line reason."
  exit 1
fi

echo "PASS: no leaked terms found (checked ${#generic_files[@]} generic files)."
