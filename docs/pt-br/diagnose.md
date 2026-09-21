# Diagnose — Análise de Causa Raiz para Bugs Difíceis

Loop de diagnóstico disciplinado para bugs difíceis, falhas inesperadas e regressões de performance. Constrói primeiro um loop de feedback pass/fail apertado, depois minimiza, levanta hipóteses, instrumenta, corrige e revalida — nunca chuta.

## 🎯 Propósito

Transformar um relato vago de falha em uma correção de causa raiz verificada. A disciplina central da skill: **sem correção sem reprodução, sem "pronto" sem revalidação**. Todas as perguntas e achados são reportados ao usuário em português (pt-BR).

## 🛠️ Como Funciona

1. **Construir um loop de feedback** — Montar um comando único, determinístico e executável pelo agente que fica vermelho *neste* bug (teste falhando, script curl, diff de CLI, browser headless, replay de trace, fuzz, harness de bisseção, loop diferencial ou script HITL). A fase só termina quando existe um comando capaz de ficar vermelho.
2. **Reproduzir + minimizar** — Confirmar que o loop mostra o sintoma exato do usuário, depois cortar código/dados/config/deps/ambiente um a um até que todo elemento restante seja essencial.
3. **Levantar hipóteses** — Gerar 3–5 hipóteses ranqueadas e falsificáveis (cada uma com previsão declarada) e mostrar o ranking ao usuário antes de testar.
4. **Instrumentar** — Testar uma variável por vez; debugger primeiro, depois logs direcionados taggeados `[DEBUG-xxxx]` para remoção via grep. Bugs de performance: medição de baseline, depois bisseção.
5. **Corrigir + teste de regressão** — Transformar a repro mínima em teste falhando num *seam correto* antes de corrigir; se não existe seam correto, isso já é um achado para `improve-codebase-architecture`.
6. **Limpar + revalidar** — Rodar a reprodução original, rodar regressão e testes vizinhos, remover toda a instrumentação e registrar a hipótese confirmada no commit/PR.

## 📚 Playbooks por Stack

Quando o código corresponde a um stack suportado, a skill carrega um playbook pronto de `skills/diagnose/references/` com comandos de reprodução, fluxos de debugger/profiler, snippets de instrumentação taggeada e cheat sheets de consulta de logs:

- `dotnet-debugging.md` — dotnet-counters, dotnet-stack, dotnet-dump (SOS), dotnet-trace, dotnet-gcdump, dotnet-monitor, EF Core `LogTo`/`TagWith`, queries journalctl/jq
- `angular-debugging.md` — Angular DevTools profiler, APIs de console `ng.*`, probes `tap` de RxJS, profiling de change detection
- `python-debugging.md` — `breakpoint()`/`pdb`, pytest `--pdb`/`--trace`, py-spy, faulthandler, tracemalloc, modo debug de asyncio
- `react-debugging.md` — React DevTools profiler, why-did-you-render, padrões de bugs de re-render/effect

## 🧩 Modos Especiais

- **Agent Self-Debug** — quando a falha é a própria sessão do agente (loops de tool calls, context drift): Failure Capture → Root-Cause Diagnosis → Contained Recovery → Self-Debug Report.
- **AI Workflow Diagnostic** — quando o sistema que falha é um agente ou workflow de IA: auditoria com score 1–5 em Prompt Quality, Context Efficiency, Tool Health, Architecture Fitness e Safety & Reliability, com remediação priorizada.
- **Silent-Failure Hunt** — quando o código "funciona" mas se comporta mal silenciosamente: caça `catch` vazios, fallbacks perigosos, stack traces perdidos e tratamento de erro ausente.

## 🚀 Uso

Use esta skill quando o usuário reportar um bug difícil, falha inesperada ou regressão de performance (ex.: "use /diagnose", "debugar isso", "execute diagnose").

## 🔗 Correlação

- **Upstream**: `orchestrator` roteia bugs e regressões para cá; relatórios de bug do `qa-analyst` a alimentam.
- **Downstream**: `improve-codebase-architecture` quando o diagnóstico revela seams ausentes; `create-issues` para documentar a causa raiz; `observability-and-instrumentation` quando a correção precisa de telemetria durável.
- **Irmãs**: `write-specs` quando o bug revela requisitos faltantes.
