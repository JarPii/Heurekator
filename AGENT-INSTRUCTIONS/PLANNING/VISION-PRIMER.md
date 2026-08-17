# VISION-PRIMER.md - Discovering and documenting a project vision

This guide is for the very start of a brand-new project — before any plan, before any
code, before `PROJECT.md` is filled in. Its job is to help a developer turn a fuzzy
idea or a real-world problem into three concrete first-pass artifacts: a vision
statement, a use-case list, and a workflow list. Those artifacts are the direct input
to `PLAN-AUTHORING-SCOPING.md`.

---

## When to use this — trigger conditions

Enter vision-discovery mode when **all** of the following are true, or when the
developer's message clearly describes a new idea rather than a task in an existing
system:

| Signal | How to detect |
|---|---|
| No filled-in `PROJECT.md` | `PROJECT.md §1` still contains `<One or two sentences...>` |
| No working plans | `PLANS/` contains no `full-plan.md` files |
| Fuzzy goal language | Developer says "I want to build…", "I have an idea for…", "I'm thinking of…", "What if we made…" |
| Problem description, not task description | Message names a pain or goal, not a file, function, or feature to change |

Do **not** enter vision-discovery mode when:
- `PROJECT.md` is already filled in — vision exists, use `PLAN-AUTHORING-SCOPING.md`.
- The developer references existing code, a specific bug, or a named feature.
- A plan or active phase already defines scope.

---

## 1. The discovery interview

Run the following questions in order. Do not skip or reorder. Do not move to the next
question until the current answer is concrete — ask "can you be more specific?" or
"give me an example" when an answer is still vague.

### Q1 — The problem
> "Describe the problem in one sentence. Whose problem is it, and when does it happen?"

Accept: a specific person/role + a specific situation.
Reject: "there's no good tool for X" without naming who uses it and when.

### Q2 — Why the current situation is not enough
> "How is this solved today? Why isn't that good enough?"

Accept: a concrete friction point or gap.
Reject: "it doesn't exist yet" without explaining what people do instead.

### Q3 — The solution in the user's hands
> "Imagine the user opening your solution for the first time. What is the first thing
>  they do? What do they see?"

Accept: a concrete action + a concrete screen/response.
Reject: system architecture, technology choices, or backend logic.

### Q4 — The complete user journey
> "Walk me through the whole cycle from the user's perspective — step by step, in
>  plain language. Don't describe the system; describe what the user does."

Probe for: entry point, key decision points, the moment the problem is solved,
how the session ends.

### Q5 — Edge cases and failure modes
> "In what situation would this not work? What can the user NOT do?"

This is where non-goals surface naturally — do not impose them.

### Q6 — What this is not
> "What are you deliberately leaving out, at least for now?"

Explicit scope boundaries are more valuable than an expanded feature list.

---

## 2. Output — three artifacts

When the interview is complete, produce these three files. Write them from the
developer's answers — do not add interpretation or technical design.

### `VISION.md` (project-owned, not synced)

```markdown
# Vision

## Problem
<One sentence: whose problem, what situation, why current solutions fall short.>

## Solution
<One or two sentences: what the product does, from the user's point of view.>

## Out of scope (v1)
<Explicit list of what is deliberately excluded.>
```

### First entries for `DOMAIN/CONCEPTS.md`

Extract the key nouns from the interview that will need precise definitions —
actors, objects, states, and relationships the developer named. List them as
candidate terms; do not define them yet (that is `DOMAIN/README.md`'s job).

### First entries for `WORKFLOWS/MAP.md`

Each named user journey from Q4 becomes one workflow heading with its steps
written as plain-English use-case descriptions (not spec references — those come
later when E2E tests exist).

---

## 3. Handoff to planning

After the three artifacts exist, hand off to `PLAN-AUTHORING-SCOPING.md`:

1. Fill in `PROJECT.md §1` from `VISION.md`.
2. Use the workflow list as the starting outline for the plan's phase structure.
3. Use the use-case list to validate that each phase has a clear user-visible outcome.
4. Run `SCRIPTS/check-portability.sh` before committing.

`VISION.md` itself is not tracked by `check-portability.sh` (it is project-owned,
like `DECISIONS/LOG.md`). Keep it in the repo root or under a project-specific
folder — it does not belong inside `AGENT-INSTRUCTIONS/`.

---

## 4. Copy-paste primer — vision discovery session

Send this message to start a vision-discovery session with a new project:

> I want to start a new project. I'll describe the problem and my idea, and I'd
> like you to interview me using the structured discovery process in
> `AGENT-INSTRUCTIONS/PLANNING/VISION-PRIMER.md`. Ask the questions one at a time,
> push back when an answer is too vague, and at the end produce the three artifacts
> the guide describes: `VISION.md`, candidate terms for `DOMAIN/CONCEPTS.md`, and
> first workflow entries for `WORKFLOWS/MAP.md`.
>
> Here is my starting point: <describe your problem or idea in a few sentences>.

---

## 5. Cross-references

- Filling in `PROJECT.md` after this session: `../PROJECT.md` (the template).
- Turning the vision into a scoped plan: `PLAN-AUTHORING-SCOPING.md`.
- Defining the domain terms surfaced here: `../DOMAIN/README.md`.
- Placing the workflows in their index: `../WORKFLOWS/README.md`.
