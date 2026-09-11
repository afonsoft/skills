# Qualidade Multi-Linguagem e Cobertura de Testes
Uma intervenção estruturada para melhorar a qualidade do código, reduzir dívida técnica e elevar a cobertura de testes em repositórios .NET, Java e Python.
## 🎯 Propósito
Estabilizar o build, corrigir avisos de análise estática (Roslyn/Sonar, SpotBugs/Checkstyle, Bandit/Ruff), resolver CVEs de segurança, aplicar SOLID/DDD/Clean Architecture e produzir um relatório de melhoria mensurável — sem abrir o Pull Request automaticamente.
## 🛠️ Como Funciona
1. **Preparação**: Clonar, criar branch `feature/{YYYYMMDD}-{nome}`, detectar build/test tooling.
2. **Análise Estática**: Corrigir logging, async, cleanup, exceções, web/API, segurança e documentação por linguagem.
3. **Arquitetura**: Aplicar SOLID, DDD e Clean Architecture apenas onde reduz avisos ou melhora a testabilidade.
4. **Testes e Cobertura**: Estabilizar a suíte, adicionar testes estilo BDD, atingir metas por linguagem (.NET/Python 90%, Java 85%).
5. **Entrega**: Atualizar README/CHANGELOG, usar Conventional Commits, emitir um Resumo Técnico Detalhado — o usuário abre o PR manualmente.

Os detalhes de cobertura por linguagem (opções de framework, limites, relatórios HTML) ficam em `skills/quality-test-implementation/references/coverage-{dotnet,java,python}.md`, além de um dispatcher `run-coverage.sh` com auto-detecção.
## 🚀 Uso
Use quando um repositório acumulou avisos, baixa cobertura ou CVEs e precisa de um esforço de qualidade em todo o repositório. Para uma única alteração, use `code-review-and-quality`; para remediação automatizada do SonarQube, use `sonarqube-autofix`.
## 🔗 Correlação
- **Revisão**: Complementa `code-review-and-quality` (manual, por alteração) com uma passada automatizada e abrangente.
- **Segurança**: Compartilha etapas de fechamento de CVE com `sonarqube-autofix`.
