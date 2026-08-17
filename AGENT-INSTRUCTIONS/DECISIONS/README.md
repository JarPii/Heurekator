# DECISIONS — why the code is the way it is, across sessions

Every session starts cold. Code survives in the repo; two things don't: what the
project is for, and why something was decided this way and not another. Those live in
conversation, and conversation evaporates with the session. The result: the same
rejected approach gets proposed again three weeks later, because nothing in the repo
says no. The work either happens twice, or gets quietly reverted.

This folder's only job: the next session knows what this one knew. It does not make
the agent better, does not prevent bad code (other rules do that), and does not
replace judgment.

## The inversion

Normally a vision doc and a roadmap describe what will be built, and decisions are a
side effect of that description. Here it's reversed: a **decision** is the only thing
that causes a change, and vision/roadmap-style docs (if this project has them) are
traces the decision left behind. A vision change with no decision behind it is
illegitimate by definition — and that's noticeable without remembering what was agreed.

## The four mechanisms, each against one failure

| Mechanism | Failure it targets |
|---|---|
| Two-layer docs — compact binding source, longer narrative rendering | A doc nobody has time to read binds nothing. A 1000-line file is an archive, not context. |
| Append-only log, threshold = it changes the vision or roadmap | The rejected branch is the most expensive piece of information and the first thing cleaned up — once you see the answer, the wrong path looks like clutter. It isn't. |
| Stop rule, cross-detected | The agent silently resolves an ambiguity because the task is mid-flight. The developer skips writing down an insight because in the moment it's obvious. Each should catch the other. |
| Tests instead of documents | A doc only holds if someone read it. A test doesn't depend on attention. |

The fourth is what separates a working system from a good intention — which is why
every invariant below carries an honest `Enforced by:` line stating which kind it is.

## 1. Two-layer docs

- **Compact, binding source:** [`LOG.md`](LOG.md) — one row per decision, the exact
  format is documented there. This is what an agent reads at the start of a session.
- **Long, narrative rendering:** `DECISIONS/<id>-<slug>.md`, one file per decision that
  has real nuance (context, alternatives that didn't make the `Rejected` column's one
  line, tradeoffs). Linked from `LOG.md`'s `Narrative` column. Optional — not every row
  needs one.

The binding direction only goes one way: `LOG.md` is truth, the narrative expands it.
Nothing outside `LOG.md` may restate a decision as if it were the source (§8 below).

## 2. Append-only log, threshold = it changes the vision or roadmap

See [`LOG.md`](LOG.md) for the exact table format. The threshold is set by
`../BUILDING/REPO-RULES.md` §0, "Discuss, compare, decide": a discussion concludes, the
conclusion is checked against the vision/roadmap, and only then is the decision to act
made — as one of two kinds.

- **Changes the vision or roadmap** (direction, scope, plan) → gets a row here.
- **Resolves only the discussion/task at hand** (an implementation or tactical choice,
  even one where an alternative was considered and set aside) → not logged. Most
  decisions are this kind; logging them would turn `LOG.md` back into the 1000-line
  archive nobody reads.

Once something clears that bar, it still needs a concrete rejected alternative and the
reason — a row without a named alternative and reason is half a record; don't write
either half alone.

## 3. Stop rule, cross-detected

Two failure directions, one rule:

- **Agent → log:** before proposing or implementing something that touches an area
  `LOG.md` already has an entry for, name the entry (`D<n>`) and either follow it or
  explicitly ask the user whether to revisit it. Do not silently pick a side of an
  already-settled question. This is
  [`../BUILDING/REPO-RULES.md`](../BUILDING/REPO-RULES.md) §0's "Discuss, compare,
  decide" applied at the moment a new proposal meets an old one.
- **Developer → log:** when the user makes a judgment call in conversation that reverses
  or settles something contested, the agent prompts to log it (`"Kirjataanko tämä
  DECISIONS/LOG.md:hen?"`) before the session ends — the call feels obvious in the
  moment, which is exactly why it's the one most likely to go unrecorded.

Both directions rely on the same file being read and written at the right moments —
see `../BUILDING/REPO-RULES.md` §3 for where this is wired into the standing rules.

## 4. Tests instead of documents — the honest `Enforced by:` list

Applies to this mechanism itself. Every invariant below is checked by
`../SCRIPTS/check-decision-log.sh` (mechanical, runs without a human) or is `review
only` (a human or agent must actually apply judgment — say so, don't pretend otherwise).

1. A row exists only when the decision changes the vision or roadmap — never for a
   conclusion that only resolves the discussion/task at hand (§2 above). **Enforced
   by:** review only — whether something is vision/roadmap-level is a judgment call no
   script can make; the script can only check the rows that do exist, not whether a row
   should have existed.
2. Every row names a rejected alternative and a reason. **Enforced by:** script.
3. IDs are unique and strictly increasing in file order; never reused. **Enforced by:** script.
4. `LOG.md` is append-only — `Date`/`Decision`/`Rejected`/`Why rejected` on an existing
   row never change after that row is committed. **Enforced by:** script (diffs against
   the last committed version when one exists).
5. A `superseded by D<n>` reference always points at a real row in the same file.
   **Enforced by:** script.
6. A reversal adds its new row and marks the old row superseded **in the same change**
   — not eventually, not in a later cleanup. **Enforced by:** review only (the script
   can confirm a reference is valid; it cannot confirm one was created when it should
   have been).
7. Before touching an area with an existing entry, the agent names it and follows or
   contests it rather than silently deciding (§3 above). **Enforced by:** review only —
   behavioral, session-level, not statically checkable.
8. A narrative file exists for any decision whose reasoning doesn't fit the one-line
   `Why rejected` cell. **Enforced by:** review only — "doesn't fit" is a judgment call.
9. Decision history is not duplicated into `PROJECT.md`, a roadmap, or a vision doc —
   those may describe the resulting *what*, never restate the *why* that belongs only
   in `LOG.md`. **Enforced by:** review only.

Run the script before committing a change to `LOG.md`:

```bash
./SCRIPTS/check-decision-log.sh
```

## Why this folder is generic

If this were one project's decision log, it would just be that project documented
better. Shared across projects, it's a method: `PROJECT.md` gets rewritten per project
(see `../PROJECT.md`'s own note on this); everything else here, including the two
scripts, moves unchanged. `LOG.md` and any `DECISIONS/<id>-*.md` narrative files are the
one deliberate exception — they are expected to be project-specific, which is why
`../SCRIPTS/check-portability.sh` excludes them from its scan.

That boundary is not a convention someone has to remember to respect — it's a test that
ships with the package. See `../SCRIPTS/check-portability.sh` and
`../PROJECT.md` / `../PROJECT.template.md`.

## How to know it's working

Not "the files exist." These:

- The same argument doesn't happen twice. If it does, a decision went unlogged.
- A rejected approach doesn't come back. If it does, the rejection's reason went
  unlogged — a row without the *why* is half a record.
- A new session gets the first thing right without you re-explaining the same
  constraints.
- When something contradicts an earlier decision, something stops it — a gate, an
  auditor, a script. Not your memory.

That last one is the actual measure: this mechanism succeeds exactly to the extent that
it moves the burden of remembering off you and onto the system.
