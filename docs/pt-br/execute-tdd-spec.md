# Execute TDD from SPEC

Test-driven development guiado por um SPEC SDD aprovado. O SPEC é a única fonte de verdade e cada teste é derivado de um requisito numerado ou de um critério de aceitação.

## 🎯 Objetivo

Transformar um `.specs/SPEC-{YYYYMMDD}-{feature}.md` aprovado em código funcionando, através de fatias verticais red-green-refactor, uma requisito por vez.

## 🛠️ Como Funciona

1. **Ler o SPEC** — Identificar requisitos numerados (`RF-###`), critérios de aceitação BDD (`AC-###`) e o plano de tarefas.
2. **Fatiar o trabalho** — Cada fatia é um requisito ou um critério de aceitação.
3. **Red-Green-Refactor** — Escrever um teste que falha, fazê-lo passar e depois refatorar com o suite verde.
4. **Re-validar** — Executar testes, build e lint após cada fatia.
5. **Avançar automaticamente** — Reportar o progresso e seguir para a próxima fatia sem pedir aprovação; o SPEC já está aprovado.

## 🚀 Uso

Use esta skill quando o usuário pedir para executar, rodar ou implementar a partir de um SPEC aprovado (ex.: "execute the spec", "rodar o spec").

## 🔗 Correlação

- **Anterior**: `grill-me-with-spec` produz o SPEC SDD aprovado.
- **Posterior**: `qa-analyst` realiza a revisão obrigatória pré-PR após todas as fatias estarem verdes.
- **Relacionada**: `diagnose` ajuda quando um teste falha inesperadamente.
