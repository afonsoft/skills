#!/usr/bin/env python3
"""Generate the OpenCode HTTP catalog (skills/index.json).

OpenCode can consume a remote catalog: an ``index.json`` at a base URL whose
entries point at ``<name>/<file>`` downloads. Users add the catalog to their
``opencode.json``::

    { "skills": ["https://raw.githubusercontent.com/afonsoft/skills/main/skills/"] }

Each entry's ``version`` is ``<frontmatter-version>-<content-hash8>`` so any
file change forces OpenCode to refresh its cache. Output is deterministic
(sorted) so re-running produces no diff.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"
CATALOG_PATH = SKILLS_DIR / "index.json"
VERSION_RE = re.compile(r"^\s*version:\s*[\"']?([^\"'\n]+)", re.MULTILINE)


def read_frontmatter_version(skill_md: Path) -> str | None:
    text = skill_md.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return None
    block = text.split("---", 2)[1] if text.count("---") >= 2 else ""
    match = VERSION_RE.search(block)
    return match.group(1).strip() if match else None


def collect_skill(skill_dir: Path) -> dict | None:
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        return None
    files = sorted(
        p.relative_to(SKILLS_DIR).as_posix()
        for p in skill_dir.rglob("*")
        if p.is_file()
    )
    digest = hashlib.sha256()
    for rel in files:
        digest.update(rel.encode("utf-8"))
        digest.update(b"\0")
        digest.update((SKILLS_DIR / rel).read_bytes())
        digest.update(b"\0")
    frontmatter_version = read_frontmatter_version(skill_md) or "0"
    return {
        "name": skill_dir.name,
        "version": f"{frontmatter_version}-{digest.hexdigest()[:8]}",
        "files": files,
    }


def build_catalog() -> dict:
    skills = [
        skill
        for skill_dir in sorted(SKILLS_DIR.iterdir())
        if skill_dir.is_dir() and (skill := collect_skill(skill_dir))
    ]
    return {"skills": skills}


def main() -> int:
    if not SKILLS_DIR.is_dir():
        print(f"error: skills directory not found: {SKILLS_DIR}", file=sys.stderr)
        return 1
    catalog = build_catalog()
    if not catalog["skills"]:
        print(f"error: no skills found under {SKILLS_DIR}", file=sys.stderr)
        return 1
    CATALOG_PATH.write_text(
        json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print(f"ok: {len(catalog['skills'])} skills -> {CATALOG_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
