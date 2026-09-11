# Revisão de Código e Qualidade
Esta skill fornece um framework estruturado e multidimensional para revisar alterações de código, garantindo qualidade profissional antes que cheguem ao branch principal.

## 🎯 Objetivo
Prevenir regressões, vulnerabilidades de segurança e dívida técnica, avaliando cada alteração em cinco dimensões críticas: **Corretude, Legibilidade, Arquitetura, Segurança e Performance**.

## 🛠️ Como Funciona
A skill impõe um "Gate de Qualidade" onde nenhuma alteração é aprovada a menos que melhore a saúde geral da base de código. Ela vai além do "LGTM" para um checklist rigoroso:
- **Corretude**: O código realmente resolve o problema e trata casos de borda?
- **Legibilidade**: O código é simples o suficiente para que outros o mantenham?
- **Arquitetura**: A alteração se encaixa no design do sistema sem introduzir acoplamento?
- **Segurança**: Existem vulnerabilidades ou segredos expostos?
- **Performance**: Existem queries N+1 ou loops não limitados?

## 🚀 Uso
Use esta skill ao final de qualquer fase de implementação ou ao revisar um Pull Request. O agente categorizará os achados como **Críticos**, **Obrigatórios**, **Opcionais** ou **Nits**, garantindo que o autor saiba exatamente o que deve ser corrigido versus o que é apenas uma sugestão.

## 🔗 Correlação
- **Pré-requisito**: Use `create-agent-harness` para configurar o sub-agente de `review`.
- **Complemento**: Complementa a skill `sonarqube-autofix` para auditoria automatizada de qualidade.
