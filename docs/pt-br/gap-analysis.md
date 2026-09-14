# Gap Analysis

Audita o estado atual do repositório (AS-IS) contra o estado desejado documentado (TO-BE) e transforma **gaps comprovados por evidências** em SPECs Draft, um Epic rastreável no GitHub e execução orquestrada — com um gate de aprovação obrigatório antes de qualquer ação externa.

## 🎯 Objetivo

Fechar a distância entre intenção arquitetural, documentação, SPECs e implementação. Toda conclusão cita evidência reproduzível (paths, intervalos de linhas, comandos, saída de testes); fontes ausentes são registradas como evidência, nunca compensadas com conteúdo inventado.

## 🛠️ Como Funciona

1. **Inventário de fontes** — `.specs/`, `docs/`, `docs/architecture/`, `.claude/CONTEXT.md`, rules, código, testes, CI, histórico Git e Issues do GitHub são registrados como presentes/ausentes (`scripts/collect-sources.sh` faz a parte mecânica).
2. **Matriz AS-IS × TO-BE** — mapeia o que existe contra o que specs, docs e regras exigem, distinguindo fato, interpretação e `[A DEFINIR]`.
3. **Vereditos** — cada candidato é testado contra a cobertura existente (compilador, analisadores, testes, CI, hooks, docs, automação) e recebe exatamente um veredito: `CONFIRMADO`, `REJEITADO`, `DUPLICADO` ou `INCONCLUSIVO`.
4. **Priorização e deduplicação** — gaps confirmados recebem uma ficha qualitativa (impacto, urgência, risco, alcance, esforço, confiança) e uma chave estável `GAP-<categoria>-<escopo-kebab>` para reexecuções idempotentes.
5. **SPECs** — `write-specs` é invocada por gap confirmado, usando as evidências coletadas como ponto de partida da design tree; cada um gera um `.specs/SPEC-*.md` em `Draft`.
6. **Gate de aprovação** — a execução para com um resumo em pt-BR. Nenhuma Issue, branch ou execução sem aprovação explícita.
7. **Issues** — `create-issues` publica um Epic `gap-analysis-{YYYYMMDD}` e uma slice Issue por gap aprovado.
8. **Handoff** — `orchestrator` valida e executa todos os SPECs aprovados pelo próprio loop das Fases 4–5.
9. **Relatório** — auditoria consolidada em `.claude/memory/gap-analysis-{YYYYMMDD}.md`, que também serve como estado de retomada.

## 🚀 Uso

Use esta skill quando:

- Auditar um repositório antes de um release ou após uma revisão ("o que está faltando", "o que diverge da spec").
- Converter achados de auditoria em trabalho rastreável e orientado a spec.
- Invocada explicitamente: `/gap-analysis` (ou "execute gap-analysis", "mapear gaps").
- Chamada pelo `orchestrator` como auditoria final baseada em evidências na Fase 5, antes do `create-readme`.

## 🔗 Correlação

- **Posterior**: `write-specs` escreve o SPEC SDD de cada gap; `create-issues` publica o Epic e as slices; `orchestrator` executa os SPECs aprovados.
- **Irmã**: `improve-codebase-architecture` trata oportunidades P2 de aprofundamento; `sonarqube-autofix` trata achados P1/P2 de análise estática.
- **Contraste**: a Fase 2 do `orchestrator` roda um checklist estrutural do harness; `gap-analysis` roda a auditoria profunda de código vs. docs vs. specs, baseada em evidências.
