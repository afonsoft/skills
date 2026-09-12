# Execute TDD from SPEC

Test-driven development guided by an approved SPEC SDD. The SPEC is the single source of truth and every test is derived from a numbered requirement or acceptance criterion.

## 🎯 Purpose

Turn an approved `.specs/SPEC-{YYYYMMDD}-{feature}.md` into working code through red-green-refactor vertical slices, one requirement at a time.

## 🛠️ How it Works

1. **Read the SPEC** — Identify numbered requirements (`RF-###`), BDD acceptance criteria (`AC-###`), and the task plan.
2. **Slice the work** — Each slice is one requirement or one acceptance criterion.
3. **Red-Green-Refactor** — Write one failing test, make it pass, then refactor while green.
4. **Re-validate** — Run tests, build, and lint after every slice.
5. **Advance automatically** — Report progress and move to the next slice without asking for approval; the SPEC is already approved.

## 🚀 Usage

Use this skill when the user asks to execute, run, or implement from an approved SPEC (e.g., "execute the spec", "rodar o spec").

## 🔗 Correlation

- **Upstream**: `write-specs` produces the approved SPEC SDD.
- **Downstream**: `qa-analyst` performs the mandatory pre-PR review after all slices are green.
- **Sibling**: `diagnose` helps when a test fails unexpectedly.
