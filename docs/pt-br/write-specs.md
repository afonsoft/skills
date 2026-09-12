# Write SPECs

Entrevista o usuário em **português (pt-BR)** para consolidar a linguagem de domínio e as decisões arquiteturais, produzindo um SPEC SDD (`.specs/SPEC-{YYYYMMDD}-{feature}.md`) aprovado como fonte única da verdade antes de qualquer implementação.

## 🎯 Objetivo

Eliminar ambiguidades, evitar implementações especulativas e alinhar expectativas técnicas antes de escrever código. O resultado é um documento SPEC SDD completo cobrindo requisitos, contratos de API, critérios de aceitação (BDD) e definição de pronto (DoD).

## 🛠️ Como Funciona

1. **Árvore de Decisão (Design Tree)** — Mapeia decisões da raiz (pedido do usuário) até a fronteira (decisões desbloqueadas). As perguntas são feitas em rodadas até que a fronteira esteja vazia.
2. **Formato das Rodadas (pt-BR)** — Cada pergunta é feita em português com uma resposta recomendada ("meu palpite") para acelerar a convergência.
3. **Coleta de Fatos Autônoma** — O agente pesquisa o código, documentação e ferramentas do repositório por conta própria via subagentes. Nunca pergunta ao usuário o que pode descobrir sozinho.
4. **Redação do SPEC SDD** — Preenche todas as seções 0–9 do template (`references/spec-sdd-template.md`): Metadados, User Story, Escopo, Contexto Técnico, Requisitos, Contrato de API, Critérios de Aceitação, Plano de Tarefas, Guardrails e DoD.
5. **Fluxo de Aprovação** — O SPEC é criado com `Status: Draft`, resumido para o usuário e submetido à aprovação explícita. A implementação só inicia após `Status: Approved`.

## 🚀 Uso

Use esta skill quando:
- O usuário solicitar uma nova funcionalidade, alteração, refatoração ou correção de bug.
- Os requisitos forem ambíguos, incompletos ou precisarem de alinhamento.
- Acionada explicitamente: `/write-specs` (ou "criar spec", "escrever spec").

## 🔗 Correlação

- **Posterior**: `execute-spec` implementa cada fatia vertical a partir do SPEC aprovado.
- **Paralela**: `create-issues` converte SPECs aprovados em GitHub Issues rastreáveis.
- **Relacionada**: `scaffold-mvp` inicializa um novo projeto após o domínio e o SPEC inicial estarem estabelecidos.
- **Orquestração**: `orchestrator` invoca `write-specs` na Fase 1 (Descoberta) e sempre que houver ambiguidade no SPEC.
