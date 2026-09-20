# Criando o Harness do Agente
A skill fundamental para iniciar um ambiente profissional de agentes de IA em qualquer repositório.

## 🎯 Objetivo
Implementar o princípio "Agente = Modelo + Harness". Ela transforma um repositório bruto em um espaço de trabalho pronto para IA, criando um sistema de loops de feedforward (instruções) e feedback (validação).

## 🛠️ Como Funciona
A skill segue um fluxo de trabalho rigorosamente baseado em evidências:
1. **Descoberta**: Analisa a stack tecnológica, arquitetura e convenções do repositório.
2. **Geração de Artefatos**: Cria arquivos críticos:
   - `CLAUDE.md`: A Fonte Única da Verdade (SSoT).
   - `.claude/rules/`: Guardrails específicos por domínio.
   - `.claude/skills/`: Guias comportamentais especializados.
   - `.claude/agents/`: Sub-agentes especializados (Engineer, Plan, Review, Test, Architecture), cada um ligado à sua skill (`orchestrator`, `write-specs`, `qa-analyst` + `code-review-and-quality`, `quality-test-implementation`, `architecture`).
3. **Validação**: Garante que todos os artefatos sejam consistentes e as permissões estejam seguras.

## 🚀 Uso
Execute esta skill primeiro em qualquer projeto novo. Ela garante que o agente não "alucine" convenções, mas siga as evidências reais encontradas no código.

## 🔗 Correlação
- **Fundação**: Esta é a skill raiz. Todas as outras skills da coleção (como `code-review-and-quality`) foram projetadas para serem colocadas dentro do diretório `skills/` criado por este harness.
- **Fluxo**: Ela estabelece os padrões de sub-agentes dos quais a skill `code-review-and-quality` depende.
