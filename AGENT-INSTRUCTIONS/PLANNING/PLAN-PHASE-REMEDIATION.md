# PLAN-PHASE-REMEDIATION.md - How to re-detail a phase that landed but failed verification

This guide is for the case where a phase was already detailed (`PLAN-PHASE-DETAILING.md`),
implemented, and then **failed its `User test` / owner retest** or shipped latent defects.
The phase is not done, but it is also not a blank scoped phase anymore: real code exists, some
of it correct. The job is to **keep what works, find everything broken, and re-detail the fix
to the same implementation grade as the original phase** so a weak model can finish it.

It applies after detailing/implementation, before `../BUILDING/WORKING-FROM-PLANS.md`
resumes on the rewritten phase. The phase stays `active` throughout; remediation is not a
new phase id.

> **Output target:** the SAME `phases/<id>-<title>.md` file, rewritten in place to the
> `PLAN-PHASE-DETAILING.md` §3 output shape, where the build steps are now fix steps. The file
> still reads as one implementation-grade phase, not as a bug list.

---

## 1. Inputs

- the failing phase file `phases/<id>-<title>.md` and the `full-plan.md` row (still `active`);
- the retest evidence: the user's observed-vs-expected results, error text, screenshots;
- traces/logs the system already records for the affected path (do not add new instrumentation
  before reading what exists);
- the frozen contracts in `done/` that this phase must still honor;
- current code, read directly — the implementation changed the tree since the phase was written.

---

## 2. Diagnose before rewriting (no-guess protocol)

Same no-invention bar as detailing. You must read the actual code paths, not theorize.

1. Reproduce each reported symptom against the code: trace the exact call path from the user
   action to the failing line, file:line.
2. For each symptom, name the **single root cause** at a file:line, not the surface behavior.
   "Two notes appear" is a symptom; "`X` links every id including deduped ones" is the cause.
3. Separate symptom clusters that share one root cause (fix once, not N times).
4. **Hunt latent defects** the retest did not surface, in the code the phase touched:
   - inconsistent row/return shapes between sibling methods;
   - guards that are unreachable because an earlier filter already excluded the case;
   - swallowed exceptions (`except Exception`, `catch {}`) hiding the real failure;
   - second source of truth created for a fact the phase was supposed to centralize;
   - fallback paths that re-introduce the exact dependency the phase was meant to remove.
5. **Catalog tech debt the implementation created** against `PLAN-PHASE-DETAILING.md` §8a
   no-hack rules: duplicate pipelines/stores, copy-paste blocks, hardcoded values, fake
   fallbacks, permission bypasses, parallel state stores.
6. If a root cause requires a design decision the original phase did not settle (e.g. which
   authority backs an action), stop and ask the user; do not pick silently.

If code and the phase's claimed behavior disagree, that disagreement IS a finding — record it.

---

## 3. Compact the working parts

Do not delete the record of what was built. Compress it so the implementer does not rebuild it
and does not re-question it.

- Replace the original `Current state (verified)` / long build plan for the working areas with a
  short **"Implemented and sound (do not rebuild)"** list: one line per kept seam, naming the
  real symbol/file and one phrase on what it correctly does.
- Where a kept part has a limitation that becomes one of the bugs, say so inline and point to the
  fix step id ("EXACT topic match only — becomes bug F1").
- This list is reference, not work. The implementer reads it to know the boundaries of the fix.

---

## 4. Re-detail the fixes to full implementation grade

Each fix is written to the **same detail bar as the original detailed phase**
(`PLAN-PHASE-DETAILING.md` §4 and §6). A small model must be able to implement it from the text
alone. For every fix:

- give it a stable id (`F1`, `F2`, … or reuse the phase's sub-id scheme);
- state the **root cause** at file:line;
- write **file-by-file steps in implementation order**, each naming the real path + symbol,
  before→after signature when it changes, and the exact semantic;
- list every **caller / wiring / import** ripple, found by grep, explicitly;
- name every **schema/function/migration/config key** touched with the repo's apply convention;
- never say "resolve the workspace", "update callers", "store it", "use the existing service"
  without naming the concrete function/method/table/store (the §6 no-invention rules apply in
  full).

A fix step that only says what is wrong is not done. It must say exactly what to change.

### The implementer makes ZERO decisions. You (the author) must KNOW the fix.

The model that implements a remediation chunk is weak and must only type what you wrote. Therefore:

- **You must have proven the root cause before writing the fix** — by reading the exact code AND,
  when static reading is not conclusive, by RUNNING it (repro script, live query, instantiate the
  app object and call the function, measure the actual value). Do not hand the implementer a
  hypothesis. "Likely", "probably", "should be" mean you have not finished researching.
- **No deferred choices.** Forbidden in a chunk: "debug first", "pick one of", "choose the fix",
  "if X then … else …", "investigate whether", "try lowering the threshold". If you found yourself
  about to write a branch, go run the code until the branch collapses to one instruction.
- **Verify the fix LOCATION is the live one.** Before naming a file/symbol, confirm it is actually
  on the executing path (grep for the caller; check it is not dead/duplicate code). A fix pointed at
  a dead constant is worse than no fix.
- **Concrete values, not ranges.** If a threshold/limit/scope name is part of the fix, state the
  exact value and show the measurement or code that justifies it (a range or "tune later" is only
  acceptable if the user explicitly deferred it, and then you still pick the starting value).
- **Already-correct is a valid finding.** If research shows the code is already right (the bug was
  stale data, or fixed in an unbuilt commit), say so and make the chunk VERIFY-ONLY with a re-test —
  do not invent a change. Re-specifying working code is tech debt.

If a root cause genuinely depends on a decision only the user can make (a product/authority/UX
choice, not a fact you can discover by running the code), STOP and ask the user (per §2.6) — do not
push that decision down to the implementer.

---

## 5. Tests and gate

- Add a regression test per fixed root cause that fails on the old behavior and passes on the new
  one. Name the test file and test name.
- Extend the original phase's `User test` into a **retest** section: re-run the exact failing
  steps from the retest evidence; state the precise pass result for each.
- Keep the original phase's `Completion checklist (gate)` shape; its boxes now cover the fixes,
  the latent defects, and the tech-debt cleanup, plus baseline/build/docs/commit and the
  compress-to-`done/` step.

---

## 6. Output shape

Rewrite the file in the `PLAN-PHASE-DETAILING.md` §3 shape, with these adaptations:

- `**Status:**` stays `active`, annotated `(remediation — landed, failed retest)`.
- Keep `Current state (verified)` but split it: **"Implemented and sound (do not rebuild)"**
  (the §3 compaction) and **"Broken / latent (root causes)"**.
- `Build plan:` becomes the numbered **fix steps** from §4, full grade.
- `Callers / wiring`, `Config / schema / migrations`, `Rules / MUST NOT`, `Tests`,
  `User test` (as retest), and `Completion checklist (gate)` are all still required and still
  filled to the detailing bar.

The reader must still be able to implement the whole remaining phase from this one file plus
`full-plan.md`.

---

## 7. Done for remediation authoring

- [ ] Every reported symptom mapped to a root cause at file:line.
- [ ] Latent defects and tech debt in the touched code enumerated, not just the reported bugs.
- [ ] Working parts compacted to a do-not-rebuild list, not deleted.
- [ ] Each fix written to full implementation grade (real symbols, ripples, schema, tests) — a
      weak model could implement it without inventing anything OR making any decision.
- [ ] Every root cause was PROVEN (read + run/repro/measure), not hypothesized — no "likely/probably".
- [ ] No chunk contains a deferred choice ("debug first", "pick one", "if X then…", "try"). Each step is a single concrete instruction.
- [ ] Every named fix location confirmed to be on the LIVE executing path (not dead/duplicate code).
- [ ] Any threshold/value/scope is an exact value backed by a shown measurement or code citation.
- [ ] Chunks for already-correct code are VERIFY-ONLY re-tests, not invented changes.
- [ ] Regression test per root cause; retest section mirrors the original failing steps.
- [ ] Gate includes latent/tech-debt boxes, baseline/build/docs/commit, and compress-to-`done/`.
- [ ] Still one `phases/<id>-<title>.md` file; `full-plan.md` row still `active`.
