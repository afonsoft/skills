# Orchestrator

Skill de controle central para projetos conduzidos por agentes. Audita pré-condições, cria documentação, reconcilia GitHub Issues abertas, transforma gaps em Issues e coordena execução, testes, QA e PR em um loop contínuo.

## 🎯 Objetivo

Governar o ciclo de vida completo de entregas de software conduzidas por agentes, delegando trabalho complexo para skills especializadas. Persiste o estado em `.claude/memory/orchestrator_stats.md`, reconcilia GitHub Issues abertas e continua automaticamente para o próximo Epic/Slice na fila.

## 🛠️ Como Funciona

1. **Fase -1 — Atualização do Framework**: Verificar atualizações da coleção de skills.
2. **Fase 0 — Pré-condições de Governança**: Verificar árvore de trabalho limpa (`git status`), `gh auth`, remotos e runtimes.
3. **Fase 1 — Descoberta**: Alinhar domínio com ADRs prévias, produzir SPEC SDDs e fazer scaffold quando necessário.
4. **Fase 2 — Auditoria**: Identificar gaps de arquitetura e vulnerabilidades de segurança (`sonarqube-autofix`).
5. **Fase 3 — Fragmentação no GitHub**: Transformar gaps aprovados em GitHub Issues.
6. **Fase 4 — Loop de Implementação**: Executar Issues com `design` (UI), migrações de banco e `execute-spec`, tratando rejeições de review com refatoração corretiva.
7. **Fase 5 — Verificação e QA**: Executar QA, code review, diagramas resilientes (`drawio` / `mermaid`), atualização de README e CHANGELOG (SemVer), e arquivamento de SPECs.
8. **Fase 6 — Revisão de SPECs Não Aprovados**: Escanear SPECs pendentes; SPECs aprovados entram na fila completa pelas Fases 4 e 5.
9. **Fase 7 — Verificação Final e Checagem de Gaps**: Confirmar que todos os SPECs, Issues e gaps foram encerrados; se houver próximo item, continuar automaticamente.

## 🚀 Uso

Use esta skill ao iniciar ou retomar um projeto, planejar um Epic, ou coordenar a implementação de um SPEC SDD aprovado.

## 🔗 Correlação

- **Anterior**: `write-specs` produz SPECs aprovados.
- **Paralela**: `create-issues` transforma SPECs em Issues.
- **Execução**: `execute-spec` implementa cada fatia; `diagnose` trata regressões; `code-review-and-quality` revisa diffs.
- **Posterior**: `qa-analyst` realiza a revisão obrigatória pré-PR; `drawio-architecture` e `mermaid-architecture` atualizam os diagramas de arquitetura em `docs/architecture/`.
