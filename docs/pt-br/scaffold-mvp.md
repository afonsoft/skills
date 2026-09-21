# Scaffold MVP — Bootstrap .NET/Blazor/Angular

Inicializa um novo repositório MVP após o alinhamento de domínio/spec: instala o harness de agente, propõe uma stack produtiva e gera o esqueleto do projeto, AD-0001 e stubs locais.

## 🎯 Propósito

Levar um repo vazio a um esqueleto de MVP compilável, documentado e pronto para agentes — rápido, mas nunca desleixado: sem pseudo-código, dependências pinadas, checks de build incrementais e decisão de arquitetura registrada.

## 🛠️ Como Funciona

- **Phase 0 — Harness de agente** — invoca `/create-agent-harness` primeiro; confirma `CLAUDE.md`/`AGENTS.md`, `.claude/`, `docs/` e branch `main`.
- **Phase 1 — Resumo + proposta de stack** — lê `.claude/CONTEXT.md` e o SPEC aprovado, pede um resumo de uma linha do projeto (pt-BR) e propõe a stack mais produtiva.
- **Phase 2 — Decisão de stack** — árvore de decisão (Blazor vs. Angular vs. API vs. CLI vs. MAUI híbrido) com kit de UI obrigatório; **aguarda aprovação explícita do usuário** antes de scaffoldar.
- **Phase 3 — Execução** — esqueleto de solution/projetos, gerenciamento central de pacotes, `global.json`, kit de UI + libs compartilhadas, estrutura `src/`/`tests/`, pastas de docs, README enxuto — com build/type check após cada passo estrutural.
- **Phase 4 — AD-0001** — registra a decisão de stack inicial em `docs/architecture/AD-0001-initial-stack.md`.
- **Phase 5 — Stubs externos** — Docker Compose ou stubs in-memory para cada dependência externa, `.env.example`, health checks — a app nunca quebra no primeiro startup.

## 🚫 Regra de Ouro (inegociável)

**Nunca construir componentes base de UI ou infraestrutura do zero.** Blazor → MudBlazor/Radzen/Fluent UI; Angular → Material/PrimeNG/NG-ZORRO; backend → ABP/FastEndpoints/minimal APIs. Também proibido: comentários de escape `// ...`, versões não pinadas, lockfiles não commitados.

## ✅ Critérios de Retorno

Harness instalado, CONTEXT/MEMORY atualizados, AD-0001 escrito, `.specs/`/`docs/specs/` existem, README com comandos de execução, build limpo, lockfiles commitados, sem TODOs, stubs externos presentes, histórico git inicial na `main`.

## 🚀 Uso

Use ao iniciar um novo MVP .NET/Blazor/Angular num repositório vazio — tipicamente logo após `/write-specs` aprovar um SPEC, ou quando o usuário pedir um bootstrap rápido de MVP.

## 🔗 Correlação

- **Upstream**: `write-specs` (domínio + SPEC aprovado) e `create-agent-harness` (pré-requisito da Phase 0).
- **Downstream**: `orchestrator` retoma o trabalho de features no repo scaffoldado; `create-issues` rastreia os Epics; `execute-specs` implementa as fatias.
