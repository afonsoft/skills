# Architecture

O ponto de entrada único para **todas as entregas de arquitetura do repositório** em `docs/architecture/` — ADRs, documentos de arquitetura e design, e diagramas de arquitetura em todos os formatos suportados.

## 🎯 Objetivo

Dar ao pipeline uma única skill para chamadas de arquitetura, em vez de nomear cada motor de diagrama. A `/architecture` roteia cada entrega para o motor correto e mantém `docs/architecture/` coerente conforme o projeto evolui.

## 📁 Área de Responsabilidade (`docs/architecture/`)

```text
docs/architecture/
├── AD-NNNN-<slug>.md                    # Architecture Decision Records
├── architecture-design.md               # Doc de design de arquitetura
├── system-design.md / api-design.md     # Docs de design
├── database-design.md / feature-*.md    # Docs de design
├── system-architecture.md               # Markdown + Mermaid embutido
├── <nome>.mmd / <nome>.drawio           # Fontes dos diagramas
├── <nome>.png | .svg | .pdf             # Imagens exportadas
└── <nome>.json / <nome>.html            # Spec archify + artefato interativo
```

## 🛠️ Como Funciona

1. **Classifica a solicitação** — ADR, doc de design, diagrama nativo em Markdown, diagrama `.drawio` editável ou HTML interativo.
2. **Roteia para o motor**:
   - `/mermaid-architecture` → diagramas nativos em Markdown + templates de design doc (seguro em headless).
   - `/drawio-architecture` → diagramas `.drawio` editáveis via MCP do draw.io ou export pela CLI desktop.
   - `archify` (opcional, terceiros) → diagramas HTML interativos e autocontidos.
3. **ADRs** — escreve registros sequenciais `AD-NNNN-<slug>.md` (Context / Decision / Consequences / Related SPEC).
4. **Disponibilidade do archify** — detecta a skill nos diretórios de skills conhecidos; se ausente, faz fallback para Mermaid — um motor opcional ausente nunca bloqueia o pipeline. Skills externas nunca são instaladas em tempo de execução.
5. **Handoff de auditoria** — encerra o pipeline invocando `gap-analysis` para a auditoria baseada em evidências (ver `references/gap-audit-handoff.md`); o orchestrator não a chama mais diretamente. O gate pt-BR dela decide se gaps confirmados viram Issues.
6. **Valida** — o validador de cada motor roda antes de reportar sucesso.

## 🚀 Uso

Use esta skill quando:
- Criar ou atualizar qualquer coisa em `docs/architecture/` — ADRs, docs de design, diagramas.
- O orchestrator chegar ao passo de arquitetura da Fase 5 (Verificação e QA).
- O usuário pedir um diagrama de arquitetura sem especificar formato.
- Uma decisão arquitetural significativa precisar ser registrada durante a implementação.
- Acionada explicitamente: `/architecture` (ou "atualize a documentação de arquitetura").

## 🔗 Correlação

- **Anterior**: `orchestrator` chama `/architecture` na Fase 5, após o code review final.
- **Motores**: `drawio-architecture`, `mermaid-architecture` e o opcional `archify` (usado apenas quando já instalado, [tt-a1i/archify](https://github.com/tt-a1i/archify)).
- **Auditoria**: invoca `gap-analysis` ao final do pipeline — gaps aprovados retornam à fila do orchestrator via `create-issues`.
- **Posterior**: `create-readme` referencia os diagramas gerados no `README.md`.
- **Auxiliares**: `scripts/architecture-doctor.sh` (preflight read-only), `references/architecture-inventory.md`, `references/gap-audit-handoff.md`.
- **Relacionadas**: `improve-codebase-architecture` refatora a arquitetura no nível de código (esta skill apenas a documenta); `scaffold-mvp` cria `docs/architecture/` e `AD-0001` em projetos novos.
