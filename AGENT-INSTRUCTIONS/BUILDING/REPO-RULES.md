# REPO-RULES.md - Repo Build Rules

These instructions apply to any AI agent working in this repository. They are general
guidance for the whole repo, not tied to one temporary plan. This file is meant to be
portable across repos; everything specific to *this* repo (layout, invariants, test
commands, deploy) lives in `../PROJECT.md` and is linked from here rather than repeated.

---

## 0. Discuss, compare, decide — before you act

Never go from idea straight to implementation. For any non-trivial change:

1. **Discuss the matter to a conclusion first.** Do not start implementing mid-discussion
   or off a half-formed idea.
2. **Compare that conclusion against the vision and roadmap** (`../PROJECT.md` §2 names
   where those live in this repo, if it has them). Does it fit, or does it change direction?
3. **Make the decision to act its own explicit step**, separate from the discussion. It is
   one of two kinds:
   - **Resolves only this discussion/task** (an implementation or tactical choice) →
     not logged.
   - **Changes the vision or roadmap** (project direction, scope, plan) → logged in
     `../DECISIONS/LOG.md` (see `../DECISIONS/README.md`).

Acting because the direction "seems obvious" is the exact drift `../DECISIONS/README.md`
exists to catch — it just hasn't been said out loud and checked yet.

### Why §0 can fail — and how to add a hard gate

§0 is a **review-only rule**: it holds only when the agent reads it and decides to
follow it in that moment.  Under pressure to show progress an agent can construct
permission from an ambiguous signal — read the rule, cite it, and break it in the same
message.  The pattern is: *vague signal → interpret as authorisation → act*.

For most interactive workflows (VS Code Copilot, Claude chat) this is sufficient:
every action is a direct response to a user message, so the conversation itself is the
authorisation.  No technical gate is needed.

For **autonomous or batch agent sessions** where the agent works unsupervised for an
extended period, a hard gate prevents the pattern above from slipping through.  Two
opt-in scripts are included:

- **`SCRIPTS/check-write-authorization.sh`** — Claude `PreToolUse` hook.  Blocks
  `Edit`/`Write`/`MultiEdit` calls until `touch .session-authorized` is run.
  Wire up in `.claude/settings.json` — see the script header for the exact JSON.
- **`SCRIPTS/pre-commit`** — git pre-commit hook.  Blocks commits until
  `.session-authorized` exists.  The install command lives in that script's header;
  read it there rather than from a second copy here.

Both gates use the same key: `touch .session-authorized` opens, `rm` closes.
Add `.session-authorized` to `.gitignore`; it is a local runtime flag.

Be clear about what they buy.  They raise the cost of acting on a misread signal, which
is the failure this section is about.  They do not confine an agent: a shell can write
files without `Edit`, create `.session-authorized` on its own, or commit with
`--no-verify`.  The gate is against drift, not against intent — restrict the agent's
tools if you need the latter.

---

## 1. Do not tape things together

**Do not tape things together.** Do not get something "just about working" by
hardcoding values, special-casing one input, copy-pasting near-duplicate logic,
catching-and-ignoring errors, fabricating data on fallbacks, or bypassing an existing
abstraction. A clean change that does less is better than a messy change that does
more. If you cannot do it cleanly, **stop and say so** instead of shipping a hack.

"Does less" cuts both ways: it also means not solving a more general problem than this
domain has. Check `../DOMAIN/CONCEPTS.md` before designing — its derived terms state the
domain's real cardinalities and exclusions (*the one*, *never*, *at most one*), and a
solution that generalizes past what those already exclude is doing unrequested work,
same as a hack is doing unrequested shortcuts.

Concretely, these are forbidden unless the task explicitly asks for them:

- Hardcoding a model name, provider name, API key/URL, actor id, workspace id, or thread id to make a code path work. Use config / parameters / the resolver that already exists.
- Adding a second code path that does the same thing a slightly different way. Extend or reuse the existing one.
- `try/except: pass` (Python) or `catch {}` (JS) to silence a failure. Fail loudly or handle it deliberately.
- Reaching around a permission check, safe view, or session to "just get the data."
- Faking/mocking real behavior in product code to make a test or demo pass.

When you notice the existing code already solves part of your problem, use it. Search
before you write.

**Read before you write.** Before editing or calling any file, function, table,
column, route, or import, **open and read it**. Never invent or guess a name,
signature, or schema from memory. If something a task or plan names does not exist
in the code, **stop and ask**. Do not fabricate it. Inventing an API that is not
there is the single most common failure; reading first prevents it.

---

## 2. Errors must reach the user

"Fail loudly" is not satisfied by raising an exception. It is satisfied when the person
using the product learns that something failed and what to do about it. Judge every
failure path from the user's seat, not the stack trace's.

Forbidden:

- **A failure the user cannot see.** An exception that escapes into a bare
  `500 Internal Server Error`, an empty response, a spinner that never resolves, or a
  log line nobody reads is a silent failure no matter how loudly it raised internally.
  If a service layer raises a deliberate, well-worded error, the layer above it must
  carry that message out to the caller.
- **Invented or placeholder content standing in for a failed operation.** Never
  substitute made-up data, a generic "best effort" result, or a plausible-looking answer
  when the real operation failed. The user will believe it. If you cannot produce the
  real result, say so instead.
- **A misleading success.** Returning `success` for an operation that did nothing, when
  "nothing" was not what the user asked for, is a lie with a friendly face. Either do the
  work or report why it could not be done.
- **Swallowing an error to keep a flow "smooth."** A degraded path is acceptable only
  when it is explicitly chosen, clearly labelled to the user, and does not pretend to be
  the full result.

Required, for every error path you write or touch:

1. The user sees that it failed - the right status code, a rendered message, or a visible
   state. Not just a log entry.
2. The message says what failed and, where possible, the next action ("link both persons
   first", "set X in settings"). Actionable beats apologetic.
3. It leaks nothing sensitive: no stack traces, connection strings, API keys, tokens, or
   personal data in what the user or the log sees (see `../PROJECT.md` §4).

When you change a deliberate failure into a friendlier one, or vice versa, update the
tests that encode the old contract in the same change and say why - do not leave tests
asserting behavior the code no longer has.

---

## 3. Decisions: stop rule, cross-detected

The same "read before you write" discipline applies to decisions, not just code — see
`../DECISIONS/README.md`. Two failure directions, each catching the other:

- **Before proposing or implementing something that touches an area
  `../DECISIONS/LOG.md` already has a row for**, name the entry (`D<n>`) and either
  follow it or explicitly ask the user whether to revisit it. Do not silently resolve
  the conflict because the task is mid-flight — a proposal that contradicts a logged
  decision without saying so is the exact drift this file exists to stop.
- **When the user settles something contested in conversation** (reverses an earlier
  call, picks between real alternatives, rejects an approach), prompt to log it in
  `../DECISIONS/LOG.md` before the session ends. The call feels obvious in the moment —
  that's exactly why it's the one most likely to go unrecorded.

---

## 4. No permanent references to temporary plans

**Neither code comments nor permanent documentation may refer to temporary plans.**
Working plans are temporary documents: write code, comments, and permanent docs so they
stand on their own without citing a plan or phase. Once a plan is fully implemented, it
is archived or deleted. Anything that must outlive it belongs in permanent architecture
docs, not in a reference to a plan.

This is as binding as §1's no-hack rules, not a style nit — a permanent doc that cites
`PLANS/<slug>/phases/<id>.md` is already stale the day that plan is archived.

---

## 5. What this repo is

See `../PROJECT.md` §1-2 for what this product is and does, and the annotated
directory layout. If this repo has a maintained code map (an annotated tree +
"where do I find X" routing table), `PROJECT.md` names its path — read that instead of
exploring the tree blind. If `PROJECT.md` says no such map exists, grep/read directly;
do not invent a map file that isn't there.

Stable docs to consult before changing a subsystem are listed in `../PROJECT.md` §2.

---

## 6. Hard invariants: never violate

The concrete, binding list for this repo lives in `../PROJECT.md` §4 - read it before
touching anything security- or privacy-sensitive. It typically covers things like: the
one gate that must mediate access to sensitive data, what an AI/automation path may
and may not write, secret handling, dev-fixture safety, and "one source of truth."

If a task seems to require breaking one of those invariants, stop and ask.

---

## 7. Code style and documentation

- **Every code file gets a useful top-of-file docstring/header** explaining its purpose, responsibilities, and notable constraints. Add one when you create a file; improve a missing one when you edit nearby.
- Match the surrounding code's style, naming, and idioms. Do not introduce a new pattern when an established one exists.
- Do not add dependencies unless necessary; explain any you add.
- Keep `docs/` accurate. If you change behavior the docs describe, always update the docs in the same change.
- **When you add or move a tracked file, update the code map named in `../PROJECT.md` §2 (if this repo has one)** and the relevant architecture doc in the same commit, so the map stays the source of truth.
- Comments explain *why*, not *what*. No noisy or generic comments.

---

## 8. Review checklist before finishing

1. Correctness and edge cases.
2. No regressions; behavior preserved unless task changed it.
3. Security: permissions, validation, no secrets, no widened access.
4. No unrelated changes snuck in.
5. No taped-together hacks; no hardcoded ids/models; no dead duplicate paths.
6. **Every failure path you touched is visible to the user with an actionable message
   (§2) - trace it from the raise all the way to the rendered response, not just to the
   log.**
7. Docstrings/headers present and accurate.
8. Docs updated if behavior changed.
9. Verification actually run.
10. Verification left no leftovers: no temp files, scratch dirs, or seeded data from the
    test run remain (`VERIFICATION-COMMITS-DEPLOY.md` §1).

---

## 9. Priority order

1. Follow the user's current request.
2. Obey the hard invariants and no-hacks rule even if it means doing less or stopping to ask.
3. Stay within active phase scope when working from a plan.
4. Keep changes small, clean, and reversible.
5. Verify and report honestly.
