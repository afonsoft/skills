---
name: scaffold-mvp
license: MIT
description: Use when starting a new project in an empty repository. Initializes an agile, high-productivity MVP stack with clean engineering boundaries, atomic configurations, and system stability without architectural shortcuts. User-facing questions and recommendations must be in Portuguese (pt-BR). Part of the afonsoft/skills collection.
metadata:
  version: "1.1.0"
  visibility: public
  author: afonsoft
  url: https://github.com/afonsoft/skills
---

# Scaffold MVP

## Trigger

This skill is activated **only** in brand-new repositories, right after `/grill-me-with-spec` has established the shared language, domain, and SPEC SDD.

## Golden Rule (Non-Negotiable)

**It is strictly forbidden to build base UI components or infrastructure from scratch.**

Reuse shared components and mature libraries focused on prototyping speed. This is the highest priority and non-negotiable. Always prefer shadcn/ui, Radix, MUI, or equivalent proven UI kits over custom components.

## Stability and Technical Cadence (No Rushing)

MVP speed must not produce unstable code or structural shortcuts. Syntactic and architectural integrity is sovereign. The agent must follow:

1. **Incremental compilation check**: After installing any dependency or creating a base directory, run the local build or type check command (e.g., `npx tsc --noEmit`, `go build`, `cargo check`). Never accumulate changes without confirming the current build passes.
2. **Zero pseudo-code**: Escape comments such as `// ...` or `// rest of the code here` are forbidden in routes or scaffold files. Every created file must be self-contained and commercially functional.
3. **Safe dependency setup**: Pin exact library versions. Always run the explicit install command to ensure clean lockfile updates (`package-lock.json`, `go.sum`, `yarn.lock`, `pnpm-lock.yaml`).
4. **Bridge and contract building**: If the MVP depends on external services (database, auth), provide locally usable stubs or mocks. Avoid unhandled crashes on the first startup.

## Workflow

### Phase 1 — Context Ingestion and Stack Proposal (Aligned Bootstrap)

Do not perform generic business interrogation; the predecessor skill already established the domain.

1. **Read** `CONTEXT.md`, `docs/architecture/`, and the approved `.specs/SPEC-*.md`.
2. Based on the discovered domain, design a hyper-productive infrastructure. Be consultative and opinionated in favor of speed.
3. If the context suggests a standard web app, categorically propose the proven ecosystem: **Next.js + Tailwind + shadcn/ui**. For other profiles (CLI, worker, pure backend), propose the equivalent MVP stack in the respective language.
4. **Mandatory validation:** Present the chosen stack and ask the user in Portuguese:

```text
Baseado no nosso contexto de dominio, proponho iniciar com [STACK_ESCOLHIDA] para maxima produtividade sem reinventar a roda.

Voce concorda com esta stack ou temos alguma restricao tecnica ainda nao mapeada?

➡️ Meu palpite: concordo com a proposta.
```

Wait for explicit user approval. If the user wants changes, adapt the bootstrap. If the user agrees, proceed.

### Phase 2 — Technical and Structural Execution

Proceed only after explicit user approval.

1. **Project initialization** (`package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`, etc.): configure the ecosystem.
2. **Base stack installation** (e.g., `npx shadcn-ui@latest init` where applicable).
3. **Agile directory structure** focused on code reuse:
   - `/components/shared` — reusable UI components injected via libraries
   - `/lib` — utility functions and service integrations
   - `/hooks` — custom state logic
4. **Generate a lean README** documenting:
   - local run commands
   - adopted architectural view
   - how rapid prototyping should be guided (reuse first)
5. **Run the build/type check** after each significant step. Fix any error before moving on.

## Stack Decision Tree

Use this table to propose a reasonable default. Confirm with the user before committing.

| Profile | Default MVP stack | UI kit |
| --- | --- | --- |
| Web app (SaaS, marketing, dashboard) | Next.js 15 + Tailwind + React Server Components | shadcn/ui |
| CLI / script | Node.js + Commander or Python + Click / Typer | — |
| API / backend | Node.js/Express or .NET 8 or FastAPI | — |
| Mobile | React Native (Expo) or Flutter | nativewind / shadcn RN |
| Data / ML | Python + Pydantic + FastAPI or Jupyter | — |

If the user has a different preference, ask in Portuguese:

```text
A stack padrao para este perfil e [STACK_SUGERIDA]. Voce confirma ou prefere uma alternativa?

➡️ Meu palpite: confirmo a stack padrao.
```

## External Service Stubs

For every external dependency (database, cache, queue, auth, object storage, payment), create a local, runnable stub:

- Use Docker Compose or a local in-memory implementation where possible.
- Provide a `.env.example` with all required keys and fake local values.
- Add a health-check script.
- Never leave the app crashing on startup when a service is missing.

## Return Criteria

Before handing back to the orchestrator:

- [ ] `CONTEXT.md` is updated with the chosen stack under **Technical Details**.
- [ ] `README.md` exists with run commands and a short architecture note.
- [ ] The build / type check passes cleanly.
- [ ] Lockfiles are updated and committed.
- [ ] No pseudo-code, `TODO`, or `// ...` escape comments remain in scaffold files.
- [ ] External dependencies have local stubs or mocks.

Then return control to the orchestrator reporting that the ground is ready for feature development.

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Custom UI base components | Use a proven UI kit. |
| Skipping build checks | Run build/type check after every structural step. |
| Leaving `// ...` comments | Every file must be self-contained and functional. |
| No local stubs for external services | Add Docker / in-memory / env-example stubs. |
| Proceeding without user stack approval | Ask and wait for explicit Portuguese confirmation. |

## References

- `grill-me-with-spec` — for producing the SPEC SDD that precedes this skill
- `create-agent-harness` — for installing the agent harness in the new repo
- `create-issues` — for turning Epics into GitHub Issues
