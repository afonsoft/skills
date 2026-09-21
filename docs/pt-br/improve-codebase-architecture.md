# Improve Codebase Architecture — Oportunidades de Aprofundamento

Expõe atrito arquitetural e propõe oportunidades de deepening — refactors que transformam módulos rasos em profundos. O objetivo é testabilidade e navegabilidade por IA.

## 🎯 Propósito

Encontrar onde o código vaza complexidade pelos seams, onde módulos rasos forçam os callers a saber demais, e onde seams ausentes tornam bugs não testáveis — e apresentar os candidatos num relatório HTML visual para o usuário escolher.

## 🛠️ Como Funciona

1. **Explorar** — lê `.claude/CONTEXT.md` (glossário de domínio), `.claude/MEMORY.md` e decisões aprovadas em `docs/architecture/`, depois percorre o código (subagente read-only) anotando atrito: conceitos espalhados em módulos pequenos, interfaces rasas, código extraído sem localidade, seams não testáveis. Aplica o **deletion test**: deletar o módulo concentraria a complexidade ou só a moveria?
2. **Relatório HTML** — arquivo autocontido no diretório temporário do SO (nunca no repo), Tailwind + Mermaid via CDN, um card por candidato: arquivos, problema, solução, benefícios em termos de localidade/alavancagem, diagrama antes/depois, força da recomendação (`Strong` / `Worth exploring` / `Speculative`) — terminando com a recomendação principal.
3. **Grilling loop** — escolhido o candidato, percorre a árvore de decisões com o usuário: restrições, dependências, o formato do módulo aprofundado, o que fica atrás do seam, quais testes sobrevivem. Efeitos colaterais inline: novos termos de domínio vão para `.claude/CONTEXT.md`; rejeições com razão relevante podem virar SPEC via `/write-specs`.

## 📐 Glossário (use estes termos exatamente)

- **Module** — qualquer coisa com interface e implementação.
- **Interface** — tudo que o caller precisa saber para usar o módulo.
- **Depth** — alavancagem na interface; profundo = muito comportamento atrás de uma interface pequena.
- **Seam** — onde a interface vive; onde o comportamento pode mudar sem editar no lugar.
- **Leverage / Locality** — o que callers / mantenedores ganham com a profundidade.
- Princípios-chave: *a interface é a superfície de teste*; *um adapter = seam hipotético, dois = real*.

## 🚀 Uso

Use quando o usuário quiser melhorar a arquitetura, consolidar módulos acoplados ou tornar o codebase mais testável (ex.: "use /improve-codebase-architecture").

## 🔗 Correlação

- **Upstream**: `diagnose` sinaliza seams ausentes descobertos durante bugs; `gap-analysis` pode expor drift arquitetural como gaps P2.
- **Downstream**: `write-specs` registra rejeições relevantes ou redesigns acordados como SPECs; `orchestrator` agenda os candidatos aceitos.
- **Referências**: `references/LANGUAGE.md` (vocabulário completo), `references/HTML-REPORT.md` (scaffold do relatório), `references/INTERFACE-DESIGN.md`.
