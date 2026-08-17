# Subagents (repo-specific, read-only)

Canonical source for the repo's read-only subagents. The intended shape: bodies are
written once here, and a generator script stamps them into each harness's native
format:

- Claude CLI → `.claude/agents/<name>.md`
- opencode → `.opencode/agents/<name>.md`

That generator is `../SCRIPTS/gen_agents.py`, and it ships with every install — run it
after changing anything in this folder:

```bash
python3 AGENT-INSTRUCTIONS/SCRIPTS/gen_agents.py
```

It writes to the **repo root's** `.claude/agents/` and `.opencode/agents/`, which is
where the harnesses look — not inside this package. The generated files are artifacts:
never hand-edit one, edit the source here and re-run. `models.json` assigns the model
per agent per harness.

CI gates and hooks are a different question and are **not** part of this package —
check `../PROJECT.md` §2 for what this repo actually has wired up rather than assuming
either way.

## When you may spawn them — and when you must NOT

Subagents exist to offload bounded read/judgment work during **scoping, detailing,
implementation self-review, and review** — so the main model does not burn its context on
locating code or re-checking rules.

- **Implementing a phase — executing its build steps (e.g. under Primer B) — you must NOT
  spawn any writing subagent.** Read the context and edit directly. The only allowed
  implementation-time subagent is the read-only `phase-implementation-reviewer`, after an
  implementation pass, to audit the phase with fresh context. (This rule is restated
  verbatim in `../PLANNING/IMPLEMENTATION-PRIMERS.md`'s Primer B, not just linked —
  Primer B is a self-contained copy-paste message sent straight to a weak implementer
  model, which may never read this file on its own.)
- **Scoping / detailing a phase / reviewing finished work** — spawn the relevant agent
  below.

## The agents

- **`seam-scout`** — read-only locator. Give it the symbols/files a phase needs; it
  returns exact `file:line` definitions, callers, covering tests, and config values (from
  the seam/config indexes first, grep only to fill gaps), plus any invariant the area
  touches. Use it while **detailing** to gather facts without spending the main model on
  reads. Claude `haiku` / opencode deepseek.
- **`invariant-reviewer`** — read-only reviewer. Give it a diff/branch/file; it checks
  against `../BUILDING/REPO-RULES.md` §1 (no-hack) + §6 (hard invariants) and flags permanent docs the
  change makes stale (§7). One line per finding, severity-tagged. Use it while
  **reviewing**. Claude `haiku` / opencode deepseek (→ mistral later).
- **`phase-spec-auditor`** — read-only auditor. Give it a `phases/<id>.md`; it checks the
  phase is actually implementable without inventing or deciding anything (every named
  symbol real, no deferred choices, ripples/tests/MUST-NOT present). Returns `PASS` or a
  gap list. Use it **before handing a detailed phase to an implementer**. Claude `haiku`
  / opencode deepseek (→ mistral later).
- **`phase-implementation-reviewer`** — read-only implementation auditor. Give it the
  phase document, current diff/branch, and relevant context; it re-checks completeness,
  correctness, scope, docs, verification, and repo-rule compliance. Use it **after an
  implementation pass under Primer B**; the main implementer fixes any valid findings.
  Claude `haiku` / opencode deepseek.

## Source shape & model assignment

Each source file is frontmatter (`description` shared by both tools, `access: read-only`)
plus the system-prompt body. `models.json` is the single knob for model assignment:
Claude never uses opus; opencode uses `opencode-go/deepseek-v4-flash`. For a stronger
variant later (a mistral key), change only the reviewer/auditor opencode ids to
`mistral/<model>`.
