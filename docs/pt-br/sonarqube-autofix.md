# SonarQube Auto-Fix

Sistema automatizado para analisar issues do SonarQube e produzir SPEC SDDs aprovados com as correções propostas.

## 🎯 Objetivo

Fazer a ponte entre a análise estática automatizada e as especificações executáveis. Transforma uma lista de bugs, code smells e vulnerabilidades em SPEC SDDs aprovados que o `execute-tdd-spec` implementa.

## 🛠️ Como Funciona

1. **Detecção de Stack**: Identifica a linguagem e as ferramentas de build do projeto.
2. **Extração de Issues**: Baixa as issues não resolvidas do SonarQube via API.
3. **Classificação**: Agrupa as issues por tipo: `bug`, `code smell` ou `security`.
4. **Geração de SPECs**: Escreve um `.specs/SPEC-{YYYYMMDD}-{issue-key}-{type}.md` aprovado por issue, usando `references/spec-sdd-template.md`.
5. **Hand-off**: Invoca `execute-tdd-spec` para implementar cada SPEC com testes e cobertura.

## 🚀 Uso

Use esta skill quando existe um relatório SonarQube e você precisa formalizar as correções como SPECs antes da implementação. Normalmente é invocada por `code-review-and-quality` quando o repositório tem SonarQube configurado.

## 🔗 Correlação

- **Gatilho**: `code-review-and-quality` chama esta skill ao detectar configuração do SonarQube.
- **Implementação**: Delega a correção real para `execute-tdd-spec`.
- **Relacionada**: `quality-test-implementation` cuida de qualidade em todo o repo sem SonarQube.
