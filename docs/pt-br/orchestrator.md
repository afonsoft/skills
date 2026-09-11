# Orchestrator

Skill de controle central para projetos conduzidos por agentes. Audita pré-condições, cria documentação, reconcilia GitHub Issues abertas, transforma gaps em Issues e coordena execução, testes, QA e PR em um loop contínuo.

## 🎯 Objetivo

Governar o ciclo de vida completo de entregas de software conduzidas por agentes, delegando trabalho complexo para skills especializadas. Persiste o estado em `.claude/memory/orchestrator_stats.md`, reconcilia GitHub Issues abertas e continua automaticamente para o próximo Epic/Slice na fila.

## 🛠️ Como Funciona

1. **Fase -1 — Atualização do Framework**: Verificar atualizações da coleção de skills.
2. **Fase 0 — Pré-condições de Governança**: Verificar Git, remote, harness e SPEC aprovado.
3. **Fase 1 — Descoberta**: Alinhar domínio, produzir SPEC SDDs e fazer scaffold quando necessário.
4. **Fase 2 — Auditoria**: Identificar gaps e problemas de arquitetura.
5. **Fase 3 — Fragmentação no GitHub**: Transformar gaps aprovados em GitHub Issues.
6. **Fase 4 — Loop de Implementação**: Executar Issues fatiadas uma a uma com `execute-tdd-spec`, reportando `Próximo: E1/S1` e continuando automaticamente sem pedir confirmação entre fatias.
7. **Fase 5 — Verificação e QA**: Executar QA, revisão, diagramas de arquitetura e atualizações do README.
8. **Fase 6 — Revisão de SPECs Não Aprovados**: Escanear SPECs pendentes e perguntar ao usuário se aprova ou descarta cada um.
9. **Fase 7 — Verificação Final e Checagem de Gaps**: Confirmar que todos os SPECs, Issues e gaps foram encerrados; se houver próximo item, continuar automaticamente.

## 🚀 Uso

Use esta skill ao iniciar ou retomar um projeto, planejar um Epic, ou coordenar a implementação de um SPEC SDD aprovado.

## 🔗 Correlação

- **Anterior**: `grill-me-with-spec` produz SPECs aprovados.
- **Paralela**: `create-issues` transforma SPECs em Issues.
- **Execução**: `execute-tdd-spec` implementa cada fatia; `diagnose` trata regressões; `code-review-and-quality` revisa diffs.
- **Posterior**: `qa-analyst` realiza a revisão obrigatória pré-PR.
