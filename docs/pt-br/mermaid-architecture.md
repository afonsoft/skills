# Mermaid Architecture Diagrams

Cria diagramas de arquitetura, fluxos de trabalho e documentação de design de sistemas em Mermaid estruturados, com alto contraste e prontos para produção, salvos diretamente em `docs/architecture/`.

## 🎯 Objetivo

Fornecer diagramas como código que renderizam nativamente no GitHub, GitLab, Obsidian, wikis e páginas de documentação sem depender de ferramentas externas, com suporte a exportações opcionais em PNG/SVG via Mermaid CLI (`mmdc` ou `npx @mermaid-js/mermaid-cli`).

## 📁 Local de Armazenamento (`docs/architecture/`)

Todos os artefatos de diagramas e documentação de arquitetura gerados por esta skill são salvos em `docs/architecture/`, consistente com a convenção da `drawio-architecture`:

```text
docs/architecture/
├── system-architecture.md             # Documentação de arquitetura com blocos Mermaid embutidos
├── <diagrama>_<tipo>_<titulo>.mmd     # Código-fonte Mermaid
├── <diagrama>_<tipo>_<titulo>.png     # Exportação raster opcional
└── <diagrama>_<tipo>_<titulo>.svg     # Exportação vetorial opcional
```

## 🛠️ Como Funciona

1. **Seleção de Visão** — Escolhe o tipo de diagrama adequado: C4 / Arquitetura (limites de componentes), Sequência (APIs/autenticação), Atividade/Fluxo (lógica de negócios/ETL), Implantação (nuvem/K8s) ou ER/Classes.
2. **Extração de Código para Diagrama** — Mapeia arquitetura e interações a partir do código-fonte (controllers, serviços, entidades, Docker Compose, Helm, Terraform).
3. **Validação Resiliente** — Valida a sintaxe antes de incluir na documentação usando `scripts/resilient_diagram.py`. Em caso de erro, aplica correções documentadas em `troubleshooting.md`.
4. **Alto Contraste e Ícones Semânticos** — Aplica obrigatoriamente `color:` dentro de `classDef` para garantir legibilidade em temas claros e escuros, enriquecido com símbolos Unicode semânticos.
5. **Coordenação com Orchestrator** — Na Fase 5 (Verificação e QA), executa imediatamente após `/drawio-architecture` para manter sincronizados tanto os arquivos `.drawio` quanto os diagramas Mermaid nativos em Markdown.

## 🚀 Uso

Use esta skill quando:
- Projetar ou documentar a arquitetura do sistema, microsserviços ou infraestrutura em nuvem.
- Visualizar interações de API, fluxos de autenticação ou pipelines de dados.
- Atualizar a documentação em `docs/architecture/` durante a Fase 5 do Orchestrator.
- Acionada explicitamente: `/mermaid-architecture` (ou "gerar diagrama mermaid", "mermaid architecture").

## 🔗 Correlação

- **Complementar**: `drawio-architecture` gera arquivos XML editáveis em `.drawio`; `mermaid-architecture` gera diagramas Mermaid nativos em Markdown em `docs/architecture/`.
- **Anterior na Fase 5**: `drawio-architecture` executa primeiro; `mermaid-architecture` executa logo em seguida.
- **Posterior**: `create-readme` referencia os diagramas de arquitetura no `README.md`.
- **Orquestração**: `orchestrator` coordena ambas as skills de diagrama no gate final antes da abertura do PR.
