#!/usr/bin/env python3
"""Generate a static HTML status dashboard from this project's own planning state.

Source of truth (read, never written):
  PLANS/<slug>/full-plan.md — top matter (Scope, Target) + phase status table
  DECISIONS/LOG.md          — decision log table
  VISION.md                 — Problem / Solution sections (optional, project-owned)

Target:
  DASHBOARD.html — written next to these sources, self-contained (no external
  assets), meant to be opened directly in a browser (file://). It is a generated
  artifact: edit the sources above, never this file, and do not commit it — it is
  fully derivable from the sources and would just be a second copy to go stale.
  Add `DASHBOARD.html` to .gitignore.

Run from anywhere inside the repo; all paths are resolved from this script's
location. Re-run whenever PLANS/, DECISIONS/LOG.md, or VISION.md change — wire
SCRIPTS/post-commit for that instead of remembering to run this by hand.
"""
import html
import re
import sys
from pathlib import Path

PKG_ROOT = Path(__file__).resolve().parent.parent
PLANS_DIR = PKG_ROOT / "PLANS"
LOG_FILE = PKG_ROOT / "DECISIONS" / "LOG.md"
VISION_FILE = PKG_ROOT / "VISION.md"
OUT_FILE = PKG_ROOT / "DASHBOARD.html"

STATUS_ORDER = {"active": 0, "next": 1, "planned": 2, "done": 3}


def parse_table(text: str) -> list[dict[str, str]]:
    """Parse the first markdown table found in text into a list of row dicts.

    Skips the header and the `---` separator row. Strips HTML comments first and
    only consumes a contiguous run of `|`-lines, so a commented-out example row
    (LOG.md ships one as format reference) is never mistaken for real data. Tolerant
    of a missing table (returns []) so a plan that has not reached that section yet
    does not crash the whole run.
    """
    text = re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL)
    lines = text.splitlines()
    start = next((i for i, l in enumerate(lines) if l.strip().startswith("|")), None)
    if start is None:
        return []
    table_lines = []
    for line in lines[start:]:
        if not line.strip().startswith("|"):
            break
        table_lines.append(line.strip())
    if len(table_lines) < 2:
        return []
    header = [c.strip() for c in table_lines[0].strip("|").split("|")]
    rows = []
    for line in table_lines[2:]:
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) != len(header):
            continue
        rows.append(dict(zip(header, cells)))
    return rows


def parse_top_matter(text: str) -> dict[str, str]:
    """Pull `> **Field:** value` lines from the top-matter blockquote."""
    fields = {}
    for m in re.finditer(r"^>\s*\*\*([^*]+?):\*\*\s*(.+)$", text, re.MULTILINE):
        fields[m.group(1).strip()] = m.group(2).strip()
    return fields


def parse_plan(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    title_m = re.search(r"^#\s+(.+)$", text, re.MULTILINE)
    title = title_m.group(1).strip() if title_m else path.parent.name
    top = parse_top_matter(text)
    phase_section_m = re.search(r"## Phase status\b(.*?)(?:\n##\s|\Z)", text, re.DOTALL)
    phases = parse_table(phase_section_m.group(1)) if phase_section_m else []
    phases.sort(key=lambda r: STATUS_ORDER.get(r.get("Status", ""), 99))
    return {
        "slug": path.parent.name,
        "title": title,
        "scope": top.get("Scope", ""),
        "target": top.get("Target", ""),
        "phases": phases,
    }


def parse_vision(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    out = {}
    for section in ("Problem", "Solution"):
        m = re.search(rf"^##\s+{section}\s*\n(.+?)(?:\n##\s|\Z)", text, re.MULTILINE | re.DOTALL)
        if m:
            out[section] = m.group(1).strip()
    return out


def e(s: str) -> str:
    return html.escape(s or "", quote=True)


def render(plans: list[dict], decisions: list[dict], vision: dict[str, str]) -> str:
    vision_html = ""
    if vision:
        parts = [f"<p><strong>{e(k)}.</strong> {e(v)}</p>" for k, v in vision.items()]
        vision_html = f'<section class="vision"><h2>Vision</h2>{"".join(parts)}</section>'

    plan_blocks = []
    for plan in plans:
        rows = "".join(
            f'<tr class="status-{e(p.get("Status", ""))}">'
            f'<td>{e(p.get("Phase", ""))}</td>'
            f'<td>{e(p.get("Title", ""))}</td>'
            f'<td><span class="pill">{e(p.get("Status", ""))}</span></td>'
            f'<td>{e(p.get("Exit state", ""))}</td>'
            "</tr>"
            for p in plan["phases"]
        )
        table_html = (
            f'<table><thead><tr><th>Phase</th><th>Title</th><th>Status</th>'
            f'<th>Exit state</th></tr></thead><tbody>{rows}</tbody></table>'
            if rows else '<p class="empty">No phases scoped yet.</p>'
        )
        plan_blocks.append(
            f'<article class="plan"><h3>{e(plan["title"])}</h3>'
            f'<p class="meta">{e(plan["scope"])}'
            f'{" &middot; " + e(plan["target"]) if plan["target"] else ""}</p>'
            f'{table_html}</article>'
        )
    plans_html = (
        f'<section class="plans"><h2>Plans</h2>{"".join(plan_blocks)}</section>'
        if plan_blocks else '<section class="plans"><h2>Plans</h2><p class="empty">No plans under PLANS/ yet.</p></section>'
    )

    decision_rows = "".join(
        f"<tr><td>{e(d.get('ID', ''))}</td><td>{e(d.get('Date', ''))}</td>"
        f"<td>{e(d.get('Decision', ''))}</td><td>{e(d.get('Rejected', ''))}</td>"
        f"<td>{e(d.get('Why rejected', ''))}</td>"
        f'<td><span class="pill">{e(d.get("Status", ""))}</span></td></tr>'
        for d in decisions
    )
    decisions_html = (
        f'<section class="decisions"><h2>Decisions</h2><table><thead><tr>'
        f"<th>ID</th><th>Date</th><th>Decision</th><th>Rejected</th>"
        f"<th>Why rejected</th><th>Status</th></tr></thead>"
        f"<tbody>{decision_rows}</tbody></table></section>"
        if decision_rows else '<section class="decisions"><h2>Decisions</h2><p class="empty">No decisions logged yet.</p></section>'
    )

    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Project dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  :root {{
    --bg: #ffffff; --fg: #1a1a1a; --muted: #666666; --border: #e0e0e0;
    --card: #f7f7f8; --accent: #2952cc;
    --status-active: #b8860020; --status-active-fg: #8a6400;
    --status-next: #2952cc20; --status-next-fg: #2952cc;
    --status-planned: #66666620; --status-planned-fg: #666666;
    --status-done: #1a7a4620; --status-done-fg: #1a7a46;
  }}
  @media (prefers-color-scheme: dark) {{
    :root {{
      --bg: #16171a; --fg: #e8e8e8; --muted: #9a9a9a; --border: #2c2d31;
      --card: #1e1f23; --accent: #7fa2ff;
    }}
  }}
  * {{ box-sizing: border-box; }}
  body {{
    background: var(--bg); color: var(--fg); margin: 0; padding: 2rem;
    font: 15px/1.5 -apple-system, "Segoe UI", Helvetica, Arial, sans-serif;
  }}
  main {{ max-width: 960px; margin: 0 auto; }}
  h1 {{ font-size: 1.5rem; margin-bottom: 0.25rem; }}
  .generated-note {{ color: var(--muted); font-size: 0.85rem; margin-bottom: 2rem; }}
  h2 {{ font-size: 1.1rem; border-bottom: 1px solid var(--border); padding-bottom: 0.4rem; margin-top: 2.5rem; }}
  section:first-of-type h2 {{ margin-top: 1.5rem; }}
  .plan {{ background: var(--card); border: 1px solid var(--border); border-radius: 8px; padding: 1rem 1.25rem; margin: 1rem 0; }}
  .plan h3 {{ margin: 0 0 0.25rem; }}
  .meta {{ color: var(--muted); font-size: 0.9rem; margin: 0 0 0.75rem; }}
  table {{ width: 100%; border-collapse: collapse; font-size: 0.9rem; }}
  th, td {{ text-align: left; padding: 0.4rem 0.6rem; border-bottom: 1px solid var(--border); vertical-align: top; }}
  th {{ color: var(--muted); font-weight: 600; }}
  .pill {{ display: inline-block; padding: 0.1rem 0.55rem; border-radius: 999px; font-size: 0.8rem; }}
  .status-active .pill {{ background: var(--status-active); color: var(--status-active-fg); }}
  .status-next .pill {{ background: var(--status-next); color: var(--status-next-fg); }}
  .status-planned .pill {{ background: var(--status-planned); color: var(--status-planned-fg); }}
  .status-done .pill {{ background: var(--status-done); color: var(--status-done-fg); }}
  .empty {{ color: var(--muted); font-style: italic; }}
  .vision p {{ margin: 0.4rem 0; }}
</style>
</head>
<body>
<main>
  <h1>Project dashboard</h1>
  <p class="generated-note">Generated by SCRIPTS/gen_dashboard.py — edit PLANS/, DECISIONS/LOG.md, or VISION.md, not this file.</p>
  {vision_html}
  {plans_html}
  {decisions_html}
</main>
</body>
</html>
"""


def main() -> None:
    plans = []
    if PLANS_DIR.exists():
        for full_plan in sorted(PLANS_DIR.glob("*/full-plan.md")):
            plans.append(parse_plan(full_plan))

    decisions = parse_table(LOG_FILE.read_text(encoding="utf-8")) if LOG_FILE.exists() else []
    vision = parse_vision(VISION_FILE)

    OUT_FILE.write_text(render(plans, decisions, vision), encoding="utf-8")
    print(f"gen_dashboard: wrote {OUT_FILE} ({len(plans)} plan(s), {len(decisions)} decision(s))")


if __name__ == "__main__":
    main()
