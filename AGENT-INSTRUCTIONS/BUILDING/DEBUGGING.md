# DEBUGGING.md - Scientific Debugging

Use this when the user reports a bug, intermittent failure, unexplained behavior, flaky
test, or production symptom. It is for diagnosing before fixing; once the cause is
proven, normal build rules and verification still apply.

---

## 1. Debugging loop

Work in small, falsifiable steps:

1. **State the symptom.** Record what fails, where it was observed, and what success would look like.
2. **Predict.** Name one expected fact that would be true if your current hypothesis is correct.
3. **Observe.** Read code, run a targeted command, query safe state, or add temporary logging to test that prediction.
4. **Resolve.** Decide whether the observation confirms, narrows, or rejects the hypothesis.
5. **Repeat.** Keep narrowing until the root cause is specific enough to fix without guessing.
6. **Fix.** Make the smallest clean change that addresses the proven cause.
7. **Verify.** Re-run the reproducer, affected tests, and the required baseline from `VERIFICATION-COMMITS-DEPLOY.md`.

Do not skip from symptom to broad refactor. If the first hypothesis is wrong, say so and
move to the next narrow prediction.

---

## 2. Task tracking shape

For non-trivial bugs, keep explicit tasks so the investigation does not sprawl:

```text
TASK #1: Reproduce failure
PREDICT: <one expected fact>
OBSERVE: <command/log/query/read>
RESOLVE: <confirmed/rejected/narrowed>

TASK #2: Narrow to boundary
PREDICT: <one expected fact>
OBSERVE: <command/log/query/read>
RESOLVE: <confirmed/rejected/narrowed>

TASK #3: Fix proven cause
VERIFY: <reproducer + tests>
```

Use the repo task tool for multi-step investigations. Keep exactly one active thread of
debugging unless independent repros can run in parallel.

---

## 3. Temporary instrumentation

Temporary logs or assertions are allowed only to prove a hypothesis.

Rules:

- Do not log secrets, provider keys, prompts containing sensitive user data, cookies, or bearer tokens. See `../PROJECT.md` §4 for what counts as sensitive in this repo.
- Prefer counters, ids already safe to log, state labels, and timing over payload dumps.
- Remove temporary instrumentation before final verification unless it is deliberately promoted to product observability.
- If instrumentation reveals behavior permanent docs describe, update those docs if behavior changes.

---

## 4. Reproduction discipline

- Prefer a minimal command, test, request, or browser step that fails before the fix and passes after it.
- If a bug is intermittent, run enough iterations to show direction; record counts and conditions.
- If the issue crosses a permission boundary or a hard invariant from `../PROJECT.md` §4, verify the real path rather than bypassing it.
- If the issue depends on external providers, isolate the local contract with fake providers or fixtures; tests must not require network or real keys.

---

## 5. Stop conditions

Stop and ask instead of guessing when:

- the symptom cannot be reproduced and no safe observation can distinguish hypotheses;
- the fix would require a product, security, or data-retention decision;
- the apparent fix would violate `REPO-RULES.md` hard invariants;
- current code contradicts the plan or permanent docs in a way that changes scope.

---

## 6. Completion summary for debugging

In addition to the normal completion summary, include:

- root cause proven;
- reproducer or observation that proved it;
- fix made;
- verification commands and results;
- any temporary instrumentation removed or retained deliberately.
