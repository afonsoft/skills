# Web Design Guidelines

Audita código de UI quanto à conformidade com guidelines de interface — acessibilidade, foco, formulários, animação, tipografia, imagens, performance, estado, toque, temas, i18n, hidratação, copy — e opcionalmente valida páginas publicadas contra metas **Lighthouse 95+**, convertendo as pendências confirmadas em Draft SPECs via `write-specs`.

Merge de duas fontes: a skill `web-design-guidelines` (vercel-labs/agent-skills — regras versionadas localmente, sem fetch em runtime) e a skill `lighthouse-95` (aliborhothamud — loop medir → diagnosticar → reportar). Read-only: nunca edita código da aplicação; correções seguem o pipeline SPEC/PR.

## 🎯 Propósito

Débito de design se esconde em dois lugares: no código-fonte (botão de ícone sem `aria-label`, `transition: all`, imagens sem dimensões) e no runtime (LCP esperando fonte, TBT de uma lib JS, falhas de contraste na página publicada). Esta skill cobre os dois:

1. **Revisão estática** — aplica o conjunto completo de regras de interface aos arquivos de UI (findings `file:line`), com mapeamentos para React/Next.js, Angular e Blazor/Razor.
2. **Verificação Lighthouse** — mede a URL de produção real (mobile + desktop), interroga o JSON em busca das causas exatas e reporta evidências — nunca alegações de uma única execução.
3. **Pipeline de SPECs** — agrupa pendências confirmadas em unidades corrigíveis, escreve um Draft SPEC por grupo via `write-specs`, aguarda o gate de aprovação e publica um Epic + Issues de fatia via `create-issues`, entregando ao `orchestrator`.

## 🛠️ Como Funciona

1. **Escopo** — escolha do modo: revisão estática, Lighthouse ou ambos; resolve globs de arquivos e/ou a URL publicada.
2. **Revisão estática** — cada arquivo no escopo lido por completo contra o conjunto de regras; findings citados `file:line` com severidade.
3. **Lighthouse** — execuções mobile primeiro (emulação padrão), desktop confirma; JSON interrogado para elemento/fases do LCP, culpados de TBT e cada auditoria reprovada com seletores.
4. **Relatório** — `design-review-{YYYYMMDD}.md` na raiz do repo: findings por categoria com severidade + direção de correção, tabela de métricas, cobertura e grupos de findings propostos.
5. **SPECs** — `write-specs` invocada por grupo aprovado (`.specs/SPEC-*.md`, `Draft`).
6. **Gate de aprovação** — resumo em pt-BR; nada externo acontece antes de um `sim` explícito.
7. **Issues** — `create-issues` publica o Epic `Design Review {YYYYMMDD}` mais uma Issue de fatia por SPEC.
8. **Handoff e estado** — `orchestrator` executa; `.claude/memory/web-design-guidelines-{YYYYMMDD}.md` mantém a execução idempotente.

## 🚀 Uso

Use esta skill quando:

- O usuário pedir para "revisar minha UI", "checar acessibilidade", "auditar design", "revisar UX" ou "validar meu site".
- Validar uma página publicada contra Lighthouse 95+ (performance, acessibilidade, boas práticas, SEO).
- Transformar pendências de design em SPECs/Issues rastreáveis em vez de um despejo de findings.
- Invocada explicitamente: `/web-design-guidelines` (ou "run web-design-guidelines", "auditar o design").

Não a use para desenhar/construir UI nova (use `design`), para code review não-UI (`code-review-and-quality`) ou para corrigir findings inline — pendências seguem o pipeline de SPECs.

## 🧪 Regras de Evidência

- Findings estáticos sempre citam `file:line`; findings de Lighthouse citam o ID da auditoria, métrica, valor e nó/URL ofensor.
- Veredictos Lighthouse exigem **3 execuções consecutivas** (variância de ±4 pontos); mobile é autoritativo, desktop confirma.
- Apenas URLs publicadas com build de produção são medidas — nunca localhost ou bundles de dev; o alias preview-vs-produção é confirmado antes.

## 🔗 Correlação

- **Downstream**: `write-specs` escreve o SPEC de cada grupo; `create-issues` publica Epic + fatias; `orchestrator` + `execute-specs` coordenam as correções.
- **Irmãs**: `design` constrói UI nova (esta skill a audita); `qa-analyst` aprofunda o planejamento de testes de a11y/visuais; `code-review-and-quality` cobre qualidade não-UI; `observability-and-instrumentation` ajuda quando Core Web Vitals precisam de monitoramento real-user.
