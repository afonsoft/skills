# Spec Driven

Uma coleção de Agent Skills centrada no orchestrator para **desenvolvimento orientado a spec** (spec-driven development): a skill [`orchestrator`](docs/pt-br/orchestrator.md) transforma um PRD ou ideia em SPECs aprovados, GitHub Issues rastreáveis, fatias implementadas com TDD, gates de QA e PRs revisados — em Claude Code, OpenCode, Devin, Cursor e outros runtimes.

[![skills.sh](https://skills.sh/b/afonsoft/skills)](https://skills.sh/afonsoft/skills)
[![Spec Validation](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml/badge.svg?job=validate-spec)](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml)
[![Quality Check](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml/badge.svg?job=validate-quality)](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml)
[![Security Scan](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml/badge.svg?job=security-scan)](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Agent Skills Spec](https://img.shields.io/badge/Agent%20Skills-Spec-blue)](https://agentskills.io)

## 🚀 Visão Geral

Este repositório implementa **Spec-Driven Development (SDD)** para agentes de IA, seguindo a **Agent Skills Specification** (agentskills.io). No centro está a skill [`orchestrator`](docs/pt-br/orchestrator.md): um loop de controle que audita pré-condições, provisiona o harness do agente, consolida a linguagem de domínio em SPEC SDDs aprovados (`.specs/SPEC-*.md`), fragmenta o trabalho em GitHub Issues e delega implementação, revisão, QA e documentação para skills especializadas — sem nunca executar trabalho complexo por conta própria.

Todas as outras skills do catálogo são alvos de delegação nesse loop. Em vez de prompts genéricos, cada skill fornece padrões estruturados, restrições e materiais de referência que permitem aos agentes realizar tarefas complexas de engenharia de software com qualidade de produção.

## 🧭 O Orchestrator

O [`orchestrator`](docs/pt-br/orchestrator.md) é o ponto de entrada e a skill de controle central para projetos conduzidos por agentes. Invoque-o com `/spec-driven` (atalho para `/spec-driven:orchestrator`, ou *"use a skill orchestrator"*) e ele executa um loop contínuo, delegando trabalho complexo para skills especializadas e persistindo o estado em `.claude/memory/orchestrator_stats.md`.

```mermaid
flowchart TD
    A[Fase -1: Atualização do Framework] --> B[Fase 0: Governança]
    B --> C[Fase 1: Descoberta]
    C --> D[Fase 2: Auditoria]
    D --> E[Fase 3: Fragmentação no GitHub]
    E --> F[Fase 4: Loop de Implementação]
    F --> G[Fase 5: Verificação e QA]
    G --> H[PR / Merge]

    C -->|apenas PRD| I[/scaffold-mvp\]
    C -->|precisa de spec| J[/write-specs\]
    D -->|gap P2| K[/improve-codebase-architecture\]
    E --> L[/create-issues\]
    F -->|por fatia| M[/execute-specs\]
    F -->|bug| N[/diagnose\]
    G --> O[/qa-analyst\]
    G --> P[/drawio-architecture\]
    G --> Q[/mermaid-architecture\]
    G --> R[/gap-analysis\]
```

O orchestrator avança automaticamente entre as fases assim que a validação passa. Ele só para em escalation gates (segurança, schema, APIs públicas, dados), falhas de validação ou pedido explícito do usuário.

## 🛠️ Catálogo de Skills e Correlação

As skills estão organizadas em torno do pipeline do orchestrator: **Engenharia de Harness**, **Orquestração e Entrega**, **Qualidade e Revisão de Código**, **Frontend e Design**, **Extensibilidade e Integração** e **Integrações MCP**.

### 🏗️ Engenharia de Harness
*Fundação para criação e gerenciamento de agentes de IA.*
- **[`create-agent-harness`](docs/pt-br/create-agent-harness.md)**: O ponto de partida. Use para inicializar um ambiente completo de agente (CLAUDE.md, AGENTS.md, regras, skills) em qualquer repositório. Suporta Claude Code, Devin, OpenCode, Cursor, Gemini e Antigravity.
- **[`create-readme`](docs/pt-br/create-readme.md)**: Profissionaliza a página inicial do repositório. Gera READMEs baseados em evidência e CHANGELOGs compatíveis com SemVer.
- **[`observability-and-instrumentation`](docs/pt-br/observability-and-instrumentation.md)**: Depois que o harness está configurado, use para garantir que as ações do agente e o comportamento da aplicação sejam visíveis e diagnosticáveis em produção.

### 🧭 Orquestração e Entrega
*Planejamento, execução, verificação e documentação para projetos conduzidos por agentes.*
- **[`orchestrator`](docs/pt-br/orchestrator.md)**: Skill de controle central. Audita pré-condições, cria documentação, reconcilia GitHub Issues abertas, transforma gaps em Issues e coordena execução, testes, QA e PR em um loop contínuo. Persiste o estado em `.claude/memory/orchestrator_stats.md` e continua automaticamente para a próxima fatia.
- **[`write-specs`](docs/pt-br/write-specs.md)**: Entrevista o usuário em português para consolidar a linguagem de domínio e produzir um `.specs/SPEC-{YYYYMMDD}-{feature}.md` aprovado antes da implementação.
- **[`scaffold-mvp`](skills/scaffold-mvp/SKILL.md)**: Inicializa um novo repositório .NET/Blazor/Angular após o alinhamento de domínio/spec. Instala o harness de agente, propõe uma stack produtiva e gera o esqueleto inicial do projeto, AD-0001 e stubs.
- **[`create-issues`](skills/create-issues/SKILL.md)**: Converte gaps aprovados, roadmap e specs em GitHub Issues com fatias verticais e links de dependência. Utiliza a estrutura do template de SPEC SDD ao criar Issues a partir de especificações.
- **[`execute-specs`](docs/pt-br/execute-specs.md)**: Test-driven development utilizando o SPEC SDD aprovado como única fonte de verdade. Red-green-refactor uma fatia vertical por vez.
- **[`qa-analyst`](skills/qa-analyst/SKILL.md)**: Ciclo completo de QA — análise de requisitos, plano de testes, casos de teste, execução, relatórios de bugs e melhoria contínua de processos.
- **[`diagnose`](skills/diagnose/SKILL.md)**: Diagnóstico disciplinado e loop de re-validação para bugs difíceis e regressões de performance.
- **[`improve-codebase-architecture`](skills/improve-codebase-architecture/SKILL.md)**: Identifica oportunidades de aprofundamento arquitetural lendo `.claude/CONTEXT.md`, `.claude/MEMORY.md` e `docs/architecture/`, e gera um relatório em HTML.
- **[`gap-analysis`](docs/pt-br/gap-analysis.md)**: Auditoria baseada em evidências do AS-IS do código vs. TO-BE de specs/docs. Gaps confirmados viram SPECs Draft (`write-specs`), um Epic rastreável com slices (`create-issues`) e execução orquestrada (`orchestrator`) — atrás de um gate de aprovação explícito.

### 💎 Qualidade e Revisão de Código
*Garantindo que a saída atenda a padrões profissionais.*
- **[`code-review-and-quality`](docs/pt-br/code-review-and-quality.md)**: O guardião principal. Realiza revisões multi-eixo (corretude, segurança, performance) antes de qualquer código ser merged.
- **[`quality-test-implementation`](docs/pt-br/quality-test-implementation.md)**: A intervenção de qualidade em todo o repo. Corrige warnings de análise estática (Roslyn/Sonar, SpotBugs/Checkstyle, Bandit/Ruff), resolve CVEs de segurança e aplica SOLID/DDD/Clean Architecture em repositórios .NET, Java ou Python.
- **[`sonarqube-autofix`](docs/pt-br/sonarqube-autofix.md)**: O auditor automático. Integra com SonarQube para identificar e corrigir débito técnico e code smells sistematicamente.

### 🎨 Frontend e Design
*Moldar interfaces com design responsivo e mobile-first.*
- **[`design`](docs/pt-br/design.md)**: Design de UI frontend para Angular, React e Blazor. Cobre layouts responsivos mobile-first, tipografia, cor, componentes, acessibilidade, motion, design tokens, exemplos Bootstrap/Tailwind CSS e endurecimento para produção.

### 🔌 Extensibilidade e Integração
*Expandindo o que o agente pode realmente fazer.*
- **[`building-mcp-servers`](docs/pt-br/building-mcp-servers.md)**: A ferramenta de power-user. Ensina agentes a construir seus próprios servidores Model Context Protocol (MCP) para conectar a qualquer API ou banco de dados.
- **[`drawio-architecture`](docs/pt-br/drawio-architecture.md)**: Inteligência visual. Combina autoria de diagramas de arquitetura com o servidor MCP oficial do draw.io para design automatizado de sistemas.
- **[`mermaid-architecture`](docs/pt-br/mermaid-architecture.md)**: Diagramas como código. Gera diagramas de arquitetura, fluxogramas, sequências e modelos C4 em Mermaid nativo, salvos diretamente em `docs/architecture/`.
- **[`obsidian`](docs/pt-br/obsidian.md)**: Operações em vaults do Obsidian. Executa o Obsidian CLI (ler/criar/buscar/gerenciar notas, tarefas, properties), constrói Bases (views/filters/formulas em .base), escreve Obsidian Flavored Markdown (wikilinks, embeds, callouts) e desenvolve/depura plugins e temas.

### 🔗 Integrações MCP
*Configurando, autenticando e usando servidores MCP externos em todas as plataformas de agente suportadas.*
- **[`composio-mcp`](docs/pt-br/composio-mcp.md)**: Conecta agentes de IA a mais de 1000 aplicativos externos (Gmail, GitHub, Slack, Notion, Linear, Jira) via Composio. Caminho CLI-first (`ak_*` chave de projeto) com fallback MCP (`ck_*` chave de consumidor via header `x-consumer-api-key`). Inclui script de setup multiplataforma (trata `serverUrl` vs `url`, `mcp` vs `mcpServers`, `environment` vs `env` em Claude Code/Desktop, Cursor, Devin CLI/Desktop, OpenCode, Antigravity IDE/CLI, OpenClaw), script de verificação, referência de config por plataforma e matriz de peculiaridades cross-platform.
- **[`notebooklm-mcp`](docs/pt-br/notebooklm-mcp.md)**: Integração do Google NotebookLM (Gemini Notebook) via CLI `nlm` e servidor `notebooklm-mcp`. Autenticação baseada em cookies para servidores headless com três métodos (OpenClaw CDP preferencial, arquivo manual `cookies.txt`, auto desktop + cópia) e script de setup multiplataforma cobrindo todas as 8 plataformas de agente suportadas. Inclui verificação, helper de extração de cookies, referência de config por plataforma e matriz de peculiaridades cross-platform.
- **[`wordpress-mcp`](docs/pt-br/wordpress-mcp.md)**: Expõe WordPress para agentes de IA via MCP. Três caminhos: (A) plugin oficial `wordpress/mcp-adapter` (Abilities API, 3 meta-tools, HTTP+STDIO), (B) plugin AI Engine (43–109+ ferramentas admin: posts, usuários, mídia, plugins, SEO, social) e (C) wp-mcp-ultimate (58 abilities, OAuth 2.1, WP 6.7+). Inclui scripts de install via WP-CLI, setup de Application Password / Bearer Token / OAuth, config MCP por plataforma (Claude Code, Devin, OpenCode, Gemini, Codex, AGY, OpenClaw), verificação de endpoint e troubleshooting.

> 📚 **Documentação:** cada skill tem uma página de doc dedicada em [`docs/en/`](docs/en/) (Inglês) e [`docs/pt-br/`](docs/pt-br/) (Português).

## 🛡️ Auditoria de Segurança

Resultados mais recentes da auditoria de terceiros do [skills.sh](https://skills.sh) (**Gen Agent Trust Hub**, **Socket**, **Snyk**). Clique em **Ver** para ver o relatório completo de cada skill.

> **Atualizado em:** 2026-09-10

| Skill | Gen Agent Trust Hub | Socket alerts | Snyk | Detalhes |
|-------|---------------------|---------------|------|----------|
| `building-mcp-servers` | ✅ safe | 0 | 🟡 medium | [Ver](https://skills.sh/afonsoft/skills/building-mcp-servers) |
| `code-review-and-quality` | ✅ safe | 0 | 🟡 medium | [Ver](https://skills.sh/afonsoft/skills/code-review-and-quality) |
| `composio-mcp` | ✅ safe | 0 | 🟡 medium | [Ver](https://skills.sh/afonsoft/skills/composio-mcp) |
| `create-agent-harness` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/create-agent-harness) |
| `create-issues` | ✅ safe | 0 | 🟡 medium | [Ver](https://skills.sh/afonsoft/skills/create-issues) |
| `create-readme` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/create-readme) |
| `design` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/design) |
| `diagnose` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/diagnose) |
| `drawio-architecture` | ✅ safe | 0 | 🟡 medium | [Ver](https://skills.sh/afonsoft/skills/drawio-architecture) |
| `execute-specs` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/execute-specs) |
| `gap-analysis` | ⚪ pending | — | ⚪ pending | [Ver](https://skills.sh/afonsoft/skills/gap-analysis) |
| `improve-codebase-architecture` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/improve-codebase-architecture) |
| `mermaid-architecture` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/mermaid-architecture) |
| `notebooklm-mcp` | ✅ safe | 1 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/notebooklm-mcp) |
| `observability-and-instrumentation` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/observability-and-instrumentation) |
| `obsidian` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/obsidian) |
| `orchestrator` | ✅ safe | 1 | 🟡 medium | [Ver](https://skills.sh/afonsoft/skills/orchestrator) |
| `qa-analyst` | ✅ safe | 0 | 🟡 medium | [Ver](https://skills.sh/afonsoft/skills/qa-analyst) |
| `quality-test-implementation` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/quality-test-implementation) |
| `scaffold-mvp` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/scaffold-mvp) |
| `sonarqube-autofix` | ✅ safe | 0 | 🟡 medium | [Ver](https://skills.sh/afonsoft/skills/sonarqube-autofix) |
| `wordpress-mcp` | 🟡 medium | 0 | 🟡 medium | [Ver](https://skills.sh/afonsoft/skills/wordpress-mcp) |
| `write-specs` | ✅ safe | 0 | 🟢 low | [Ver](https://skills.sh/afonsoft/skills/write-specs) |

---

## 📦 Instalação

### ⚡ via skills.sh (Recomendado)
A forma mais rápida de instalar e auto-detectar seu ambiente.
```bash
npx skills add afonsoft/skills
```

### 🧩 via plugin do Claude Code
Instala skills **e** slash commands nativamente (sem precisar do `install.sh`):
```text
/plugin marketplace add afonsoft/skills
/plugin install spec-driven@afonsoft
```
Os comandos recebem o namespace do plugin: `/spec-driven:orchestrator` e `/spec-driven:<skill>` para cada skill.

### 🖥️ via install.sh (clone local)
Copia as skills para o diretório de skills de cada IDE e gera os slash commands:
```bash
./install.sh --all        # todos os IDEs/CLIs suportados + slash commands
./install.sh --claude     # apenas Claude Code
./install.sh --opencode   # apenas OpenCode
./install.sh --devin      # apenas Devin
./install.sh --cursor     # apenas Cursor
./install.sh --dry-run    # preview sem alterar nada
```

Slash commands gerados (Claude Code, OpenCode, Devin):

| Comando | Destino |
|---------|---------|
| `/spec-driven` | skill `orchestrator` — inicia o pipeline completo spec → issues → fatias → QA → PR |
| `/spec-driven:orchestrator` | o mesmo que `/spec-driven` |
| `/spec-driven:<skill>` | a skill indicada (ex.: `/spec-driven:write-specs`, `/spec-driven:execute-specs`) |

Na reinstalação, os shims legados `/architecture:<skill>` são removidos automaticamente.

## 📣 Publicar em Diretórios de Skills

### SkillsLLM
[SkillsLLM](https://skillsllm.com/) indexa skills open-source para Claude Code, Codex CLI e ChatGPT. O scraper descobre repos diariamente via GitHub topics (`claude-code`, `ai-agent`, `mcp-server`, `agent-skills`, `skill-md`) e arquivos `SKILL.md`. Para listar esta coleção:

1. Entre com GitHub em [Submit a Skill](https://skillsllm.com/submit)
2. Submeta a URL do repositório: `https://github.com/afonsoft/skills`
3. O scraper valida, busca metadados, roda security scan (Semgrep + npm audit + pip-audit) e adiciona ao catálogo em 24 horas

> **Nota:** A descoberta automática do SkillsLLM filtra repos com 100+ stars. A submissão manual via formulário contorna esse filtro — o repo é escaneado e listado independente do número de stars. Os topics e a descrição do GitHub já estão configurados para o scraper categorizar as skills corretamente.

### Awesome Skills
[Awesome Skills](https://awesomeskill.ai/) descobre skills `SKILL.md` open-source do GitHub via seu **Awesome List Import**. Cada diretório `skills/<nome>/SKILL.md` vira uma listagem separada com slug `afonsoft-skills-<nome>`. Submeta a URL do repositório através do formulário **Submit a Skill** do site:

- **Repository URL:** `https://github.com/afonsoft/skills`
- **Branch:** `main`
- **Skills Path:** `/skills`

O `description` de cada skill inclui `afonsoft` para que a coleção seja pesquisável em [awesomeskill.ai/search?q=afonsoft](https://awesomeskill.ai/search?q=afonsoft). A API de busca do Awesome Skills matcheia apenas contra `name` e `description` (não owner, repo ou tags), então a atribuição `afonsoft` em cada descrição é o que faz a busca retornar resultados.

### SkillHub
[SkillHub](https://www.skill-marketplace.com/) agrega skills de fontes do GitHub. Abra **Sources** → **Add Source**, então use:

- **Name:** `afonsoft/skills`
- **Repository URL:** `https://github.com/afonsoft/skills`
- **Source Type:** `GitHub Repo`
- **Branch:** `main`
- **Skills Path:** `/skills`

SkillHub importa a coleção desta fonte e lista cada diretório `SKILL.md` válido em seu marketplace.

### LobeHub Skills Marketplace
[LobeHub](https://lobehub.com/skills) é o maior marketplace de skills do mundo (100.000+ skills). A publicação é via CLI (sem formulário web). Cada skill recebe o identificador `afonsoft-skills-<nome>`.

**Configuração única (por máquina, requer Node.js >= 22):**
```bash
npx -y @lobehub/market-cli login           # OAuth no navegador
npx -y @lobehub/market-cli github connect  # verificar propriedade do GitHub
```

**Publicar todas as skills localmente:**
```bash
./publish-lobehub.sh          # publica todas as skills
./publish-lobehub.sh --dry-run # preview sem publicar
```

**Publicar uma skill individual:**
```bash
npx -y @lobehub/market-cli skill publish --dir skills/<nome-da-skill> --identifier afonsoft-skills-<nome-da-skill>
```

**Publicação automática via GitHub Actions:**

Um workflow (`.github/workflows/lobehub-publish.yml`) publica todas as skills a cada push em `main`. Para habilitar, adicione dois secrets no repositório:

1. **`LOBEHUB_M2M_CREDENTIALS`** — conteúdo de `~/.lobehub-market/credentials.json` (registro do dispositivo)
2. **`LOBEHUB_USER_CREDENTIALS`** — conteúdo de `~/.lobehub-market/user-credentials.json` (tokens OAuth)

```bash
# Após rodar lhm login + lhm github connect localmente:
gh secret set LOBEHUB_M2M_CREDENTIALS < ~/.lobehub-market/credentials.json
gh secret set LOBEHUB_USER_CREDENTIALS < ~/.lobehub-market/user-credentials.json
```

O workflow restaura os dois arquivos de credenciais, verifica a auth e executa `./publish-lobehub.sh`. O refresh token renova o access token automaticamente, mantendo o workflow autenticado entre execuções.

Após publicar, as skills aparecem em `market.lobehub.com/s/skills/afonsoft-skills-<nome>` e são pesquisáveis em [lobehub.com/skills?q=afonsoft](https://lobehub.com/skills?q=afonsoft).

## 📖 Como usar

1. **Instale** a coleção usando um dos métodos acima. Rodar `./install.sh` também gera os slash commands `/spec-driven:<skill>` para Claude Code, OpenCode e Devin.
2. **Comece pelo orchestrator** — `/spec-driven` (o mesmo que `/spec-driven:orchestrator`) ou *"use a skill orchestrator"* — e deixe ele conduzir o pipeline spec → issues → fatias → QA → PR.
3. **Invoque** uma skill individual diretamente quando souber exatamente o que precisa (ex.: `/spec-driven:write-specs`, ou *"Use a skill create-agent-harness para configurar este repo"*). O agente carrega o `SKILL.md` e segue o workflow estruturado.

## ⚖️ Licença
MIT - Veja `LICENSE`.

## 🛠️ Ferramentas de Desenvolvimento de Skills

### skillxp
[skillxp](https://skillxp.dev/) observa o comportamento de carregamento de skills em harnesses (Claude Code, Codex CLI, Antigravity). Stage uma skill em um fixture novo, invoque o harness headless, e veja o que realmente chegou ao modelo com evidência de transcript. Instale via `brew install agent-ecosystem/tap/skillxp` ou `npm install -g skillxp`. Use `skillxp harnesses` para listar plataformas suportadas e `skillxp observe -harness <name> -install ./my-skill ...` para rastrear ativação de skills e carregamento de frases.

## 📊 Catálogo de Skills
Navegue todas as skills disponíveis em [skills.sh](https://www.skills.sh/?q=afonsoft).

---

## Star History

<a href="https://www.star-history.com/?repos=afonsoft%2Fskills&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=afonsoft/skills&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=afonsoft/skills&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=afonsoft/skills&type=date&legend=top-left" />
 </picture>
</a>

## StarMapper

[![StarMapper](https://img.shields.io/badge/StarMapper-afonsoft%2Fskills-blue)](https://starmapper.bruniaux.com/afonsoft/skills)

> O StarMapper também requer um token do GitHub para obter os dados de geolocalização das estrelas. O mapa ao vivo não está disponível até que o repositório seja escaneado.
