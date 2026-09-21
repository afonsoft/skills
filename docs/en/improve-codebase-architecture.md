# Improve Codebase Architecture — Deepening Opportunities

Surfaces architectural friction and proposes deepening opportunities — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

## 🎯 Purpose

Find where the codebase leaks complexity across seams, where shallow modules force callers to know too much, and where missing seams make bugs untestable — then present candidates as a visual HTML report the user can pick from.

## 🛠️ How it Works

1. **Explore** — reads `.claude/CONTEXT.md` (domain glossary), `.claude/MEMORY.md`, and approved decisions in `docs/architecture/`, then walks the codebase (read-only subagent) noting friction: concepts scattered across small modules, shallow interfaces, extracted-but-unlocal code, untestable seams. Applies the **deletion test**: would deleting the module concentrate complexity or just move it?
2. **HTML report** — a self-contained file in the OS temp dir (never in the repo), Tailwind + Mermaid via CDN, one card per candidate: files, problem, solution, benefits in locality/leverage terms, before/after diagram, recommendation strength (`Strong` / `Worth exploring` / `Speculative`) — ending with a top recommendation.
3. **Grilling loop** — once the user picks a candidate, walk the design tree together: constraints, dependencies, the deepened module's shape, what sits behind the seam, which tests survive. Side effects inline: new domain terms go to `.claude/CONTEXT.md`, load-bearing rejections can be captured as a SPEC via `/write-specs`.

## 📐 Glossary (use these terms exactly)

- **Module** — anything with an interface and an implementation.
- **Interface** — everything a caller must know to use the module.
- **Depth** — leverage at the interface; deep = much behaviour behind a small interface.
- **Seam** — where an interface lives; where behaviour can change without editing in place.
- **Leverage / Locality** — what callers / maintainers gain from depth.
- Key principles: *the interface is the test surface*; *one adapter = hypothetical seam, two = real*.

## 🚀 Usage

Use when the user wants to improve architecture, consolidate tightly-coupled modules, or make a codebase more testable (e.g., "use /improve-codebase-architecture").

## 🔗 Correlation

- **Upstream**: `diagnose` flags missing seams discovered during bug work; `gap-analysis` may surface architecture drift as P2 gaps.
- **Downstream**: `write-specs` captures load-bearing rejections or agreed redesigns as SPECs; `orchestrator` schedules accepted candidates.
- **References**: `references/LANGUAGE.md` (full vocabulary), `references/HTML-REPORT.md` (report scaffold), `references/INTERFACE-DESIGN.md`.
