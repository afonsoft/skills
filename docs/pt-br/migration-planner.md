# Migration Planner

Produz planos de migração completos e baseados em evidências de sistemas legados para **.NET** — preferencialmente **Blazor WebAssembly** para UIs web, **.NET MAUI** para desktop/mobile e **ASP.NET Core** para backends — usando o padrão Strangler Fig, e então entrega cada domínio ao pipeline de entrega orientado a SPECs.

Adaptada da skill `legacy-migration-planner` (tech-leads-club/agent-skills, CC-BY-4.0), integrada a este catálogo e ampliada com o fluxo de migração de legado descrito no guia da Claudera (visibilidade via MCP, suítes de paridade lógica, governança human-in-the-loop, redesign de débito de segurança).

## 🎯 Propósito

Reescritas big-bang falham. Esta skill planeja uma migração gradual e reversível: clona (quando recebe uma URL) e pesquisa o código legado com evidências `file:line`, mapeia bounded contexts, desenha seams e facades (rotas YARP, adapters de DI, dual-write com EF Core, ilhas Blazor/MAUI) e escreve um plano por domínio mais um roadmap consolidado — tudo em `migration-plan/` no repositório de destino.

Depois converte cada domínio em um SPEC Draft via `write-specs`, aguarda aprovação explícita, publica um Epic rastreável + Issues de fatia via `create-issues` e entrega a execução ao `orchestrator`.

## 🛠️ Como Funciona

1. **RESEARCH** — análise profunda do código (sinais de `.sln`/`.csproj`, `web.config`, `.aspx`, `.xaml`), inventário de dependências com verificação de EOL, mapeamento de bounded contexts com razão de acoplamento, pesquisa do alvo .NET (versões verificadas), riscos + scan de débito de segurança. Fontes MCP opcionais (schema do banco, índice do git, observabilidade) aumentam a visibilidade.
2. **PLAN** — direção de migração escolhida por evidência; seams e facades desenhados por padrão; um arquivo de plano por domínio (`migration-plan/domains/`); `00-roadmap.md` consolidado com fases, estratégia de banco compartilhado, ponte de auth e observabilidade.
3. **SPECs** — `write-specs` é invocada por domínio com o plano como pacote de evidências, produzindo `.specs/SPEC-*.md` em `Draft`.
4. **Gate de aprovação** — resumo em pt-BR; nada externo acontece antes de um `sim` explícito.
5. **Issues** — `create-issues` cria o Epic `migration-{YYYYMMDD}` e uma Issue de fatia por domínio, ordenadas pelas dependências do roadmap.
6. **Handoff** — `orchestrator` executa os SPECs aprovados (`execute-specs`/`tdd-spec`), com as suítes de paridade como parte do DoD de cada SPEC.
7. **Estado** — `.claude/memory/migration-planner-{YYYYMMDD}.md` permite re-execuções idempotentes.

## 🚀 Uso

Use esta skill quando:

- Planejar migração de legado → .NET (ou para uma stack escolhida pelo usuário): WebForms/MVC/WinForms/WPF/Xamarin, frontends AngularJS/jQuery/Angular, ou backends não-.NET.
- O usuário informa o repo de origem (diretório atual, path local ou URL — URLs são sempre clonadas em diretório temporário e analisadas read-only) e, opcionalmente, o repo de destino que recebe `migration-plan/`, `.specs/` e as Issues.
- Decompor um monólito em serviços ASP.NET Core, ou consolidar em um monólito modular.
- O usuário pede um "plano de migração", "roadmap de modernização" ou "strangler fig".
- Invocada explicitamente: `/migration-planner` (ou "run migration-planner", "planejar migração").

Não a use para escrever código de migração, para uma mudança única e bem delimitada, ou quando SPECs aprovados já cobrem o trabalho.

## 🧪 Redes de Segurança

Cada passo exige plano de rollback mais uma rede de segurança: testes de caracterização, a **suíte de paridade lógica** (os mesmos testes xUnit contra legado e novo), testes de contrato, golden masters (Verify), parallel-run com tráfego sombra, validação de consistência de dados e regressão visual com Playwright para UI.

## 🔗 Correlação

- **Downstream**: `write-specs` escreve o SPEC de cada domínio; `create-issues` publica Epic + fatias; `orchestrator` + `execute-specs`/`tdd-spec` implementam.
- **Irmãs**: `architecture`/`mermaid-architecture` são donas dos diagramas TO-BE e ADRs; `gap-analysis` complementa com auditoria por evidência; `qa-analyst` aprofunda o planejamento de testes; `observability-and-instrumentation` guia a telemetria `migration_path`.
- **Companheiras (quando instaladas)**: `aspnet-core-api`, `abp-*`, `fluentui-blazor`, `ef-core`, `testing-xunit`, `security-jwt`, `modern-csharp-coding-standards`, `migrate-aspnetboilerplate-to-abp` — usadas apenas quando já instaladas, nunca instaladas em tempo de execução.
