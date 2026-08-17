#!/usr/bin/env python3
"""Generate .claude/agents/ and .opencode/agents/ from SUBAGENTS/ source files.

Source of truth:
  SUBAGENTS/<name>.md  — frontmatter (description, access) + system-prompt body
  SUBAGENTS/models.json — model assignment per agent per harness

Targets (at the repo root, which is where the harnesses look — not inside this
package when it is vendored as <repo>/AGENT-INSTRUCTIONS/):
  .claude/agents/<name>.md   — Claude CLI subagent
  .opencode/agents/<name>.md — opencode subagent

Run from anywhere inside the repo; all paths are resolved from this script's location.
Re-run whenever SUBAGENTS/*.md or models.json changes. The targets are generated
artifacts — edit the source in SUBAGENTS/, not the generated copies.
"""
import json
import sys
from pathlib import Path

PKG_ROOT = Path(__file__).resolve().parent.parent
SUBAGENTS_DIR = PKG_ROOT / "SUBAGENTS"
MODELS_FILE = SUBAGENTS_DIR / "models.json"


def find_repo_root(pkg_root: Path) -> Path:
    """Locate the directory whose .claude/ and .opencode/ the harness actually reads.

    Agent definitions belong to the *repo*, not to this package. When the package is
    vendored as <repo>/AGENT-INSTRUCTIONS/, writing them inside the package would put
    them somewhere no harness looks. Only step up when the parent is a real repo, so
    that a standalone checkout (this package as its own repo) still targets itself.
    """
    if pkg_root.name == "AGENT-INSTRUCTIONS" and (pkg_root.parent / ".git").exists():
        return pkg_root.parent
    return pkg_root


REPO_ROOT = find_repo_root(PKG_ROOT)

CLAUDE_OUT = REPO_ROOT / ".claude" / "agents"
OPENCODE_OUT = REPO_ROOT / ".opencode" / "agents"

# Files in SUBAGENTS/ that are not agent body sources.
SKIP = {"README.md", "models.json"}


def parse_frontmatter(text: str) -> tuple[dict[str, str], str]:
    """Split a YAML frontmatter block from the document body.

    Returns (fields_dict, body_string). If no frontmatter is present, returns
    ({}, original_text).
    """
    if not text.startswith("---"):
        return {}, text
    try:
        end = text.index("\n---", 3)
    except ValueError:
        return {}, text
    fm_block = text[4:end]
    body = text[end + 4:].lstrip("\n")
    fields: dict[str, str] = {}
    for line in fm_block.splitlines():
        if ":" in line:
            k, _, v = line.partition(":")
            fields[k.strip()] = v.strip()
    return fields, body


def write_agent(path: Path, name: str, description: str, model: str, body: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    content = f"---\nname: {name}\ndescription: {description}\nmodel: {model}\n---\n\n{body}"
    path.write_text(content, encoding="utf-8")


def main() -> None:
    if not MODELS_FILE.exists():
        sys.exit(f"gen_agents: missing {MODELS_FILE}")

    models: dict = json.loads(MODELS_FILE.read_text(encoding="utf-8"))
    claude_models: dict[str, str] = models.get("claude", {})
    opencode_models: dict[str, str] = models.get("opencode", {})

    sources = sorted(
        f for f in SUBAGENTS_DIR.glob("*.md") if f.name not in SKIP
    )
    if not sources:
        print("gen_agents: no source agent files found in SUBAGENTS/")
        return

    generated: list[str] = []
    for src in sources:
        name = src.stem
        fm, body = parse_frontmatter(src.read_text(encoding="utf-8"))
        description = fm.get("description", "")

        claude_model = claude_models.get(name, "haiku")
        opencode_model = opencode_models.get(name, "opencode-go/deepseek-v4-flash")

        write_agent(CLAUDE_OUT / f"{name}.md", name, description, claude_model, body)
        write_agent(OPENCODE_OUT / f"{name}.md", name, description, opencode_model, body)
        generated.append(name)

    for name in generated:
        print(f"generated  {name}")
        print(f"           → {CLAUDE_OUT / f'{name}.md'}")
        print(f"           → {OPENCODE_OUT / f'{name}.md'}")

    print(f"\n{len(generated)} agent(s) written under {REPO_ROOT}.")


if __name__ == "__main__":
    main()
