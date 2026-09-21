# Architecture

The single entry point for **all repository architecture deliverables** under `docs/architecture/` — ADRs, architecture and design documents, and architecture diagrams in every supported format.

## 🎯 Purpose

Give the pipeline one skill to call for architecture work instead of naming each diagram engine. `/architecture` routes every deliverable to the right engine and keeps `docs/architecture/` coherent as the project evolves.

## 📁 Ownership (`docs/architecture/`)

```text
docs/architecture/
├── AD-NNNN-<slug>.md                    # Architecture Decision Records
├── architecture-design.md               # Architecture design doc
├── system-design.md / api-design.md     # Design docs
├── database-design.md / feature-*.md    # Design docs
├── system-architecture.md               # Markdown + embedded Mermaid
├── <name>.mmd / <name>.drawio           # Diagram sources
├── <name>.png | .svg | .pdf             # Exported images
└── <name>.json / <name>.html            # Archify spec + interactive artifact
```

## 🛠️ How it Works

1. **Classifies the request** — ADR, design doc, Markdown-native diagram, editable `.drawio` diagram, or interactive HTML.
2. **Routes to the engine**:
   - `/mermaid-architecture` → Markdown-native diagrams + design doc templates (headless-safe).
   - `/drawio-architecture` → editable `.drawio` diagrams via draw.io MCP or desktop CLI export.
   - `archify` (optional, third-party) → interactive standalone HTML diagrams.
3. **ADRs** — writes sequential `AD-NNNN-<slug>.md` records (Context / Decision / Consequences / Related SPEC).
4. **Archify availability** — detects the skill across the known skills roots; if missing, falls back to Mermaid — a missing optional engine never blocks the pipeline. External skills are never installed at runtime.
5. **Gap audit handoff** — ends the pipeline by invoking `gap-analysis` for the evidence-backed audit (see `references/gap-audit-handoff.md`); the orchestrator no longer calls it directly. Its own pt-BR gate decides whether confirmed gaps become Issues.
6. **Validates** — each engine's own validator runs before success is reported.

## 🚀 Usage

Use this skill when:
- Creating or updating anything under `docs/architecture/` — ADRs, design docs, diagrams.
- The orchestrator reaches the architecture step of Phase 5 (Verification & QA).
- The user asks for an architecture diagram without specifying a format.
- A significant architectural decision must be recorded mid-implementation.
- Invoked explicitly: `/architecture` (or "update the architecture docs", "atualize a arquitetura").

## 🔗 Correlation

- **Upstream**: `orchestrator` calls `/architecture` in Phase 5 after the final code review.
- **Engines**: `drawio-architecture`, `mermaid-architecture`, and optional `archify` (used only when already installed, [tt-a1i/archify](https://github.com/tt-a1i/archify)).
- **Audit**: invokes `gap-analysis` at the end of the pipeline — approved gaps re-enter the orchestrator queue via `create-issues`.
- **Downstream**: `create-readme` references the generated diagrams in `README.md`.
- **Helpers**: `scripts/architecture-doctor.sh` (read-only preflight), `references/architecture-inventory.md`, `references/gap-audit-handoff.md`.
- **Related**: `improve-codebase-architecture` refactors code-level architecture (this skill only documents it); `scaffold-mvp` creates `docs/architecture/` and `AD-0001` in new projects.
