---
name: orchestrator
license: MIT
description: Governa projetos com agentes, audita pre-condicoes, cria documentacao, transforma gaps em GitHub Issues e coordena execucao, testes e QA. Part of the afonsoft/skills collection.
metadata:
  version: "1.0.0"
  visibility: public
  author: afonsoft
  url: https://github.com/afonsoft/skills
---

# ORCHESTRATOR - Central de Controle

Planeja, governa, audita e delega execucao. Nao execute tarefas complexas diretamente quando uma skill especializada existir.

## Fase - Atualizacao do framework

Esta verificacao deve ocorrer no inicio de toda execucao do orchestrator, antes das pre-condicoes do projeto.

1. Identifique de onde as skills foram instaladas. Para cada skill carregada, resolva o caminho real do link e procure o clone que contem `README.md` e `SKILL.md` do catalogo.
2. No clone encontrado, leia o remote `origin`, a branch atual e o commit local instalado.
3. Consulte o remote do framework com `git fetch origin --quiet` ou mecanismo equivalente de leitura. Nunca faca `pull`, merge ou reset no clone do framework.
4. Compare o commit local com `origin/<branch>` ou com a referencia remota equivalente.
5. Se houver commits novos, informe imediatamente:

```text
Atualizacao do framework disponivel
- Framework: afonsoft/skills
- Instalado: <commit ou data>
- Disponivel: <commit ou data>
- Novidades: <resumo dos commits ou arquivos alterados>
- Acao: reinstale o catalogo com `npx skills add afonsoft/skills`
```

6. Se houver commits novos, informe a atualizacao disponivel e oriente o usuario a reinstalar as skills com `npx skills add afonsoft/skills`.
7. Depois do re-deploy, confirme que `orchestrator` e `create-agent-harness` apontam para a revisao nova e informe o resultado ao usuario antes de continuar.
8. Se nao houver mudancas, registre `Framework atualizado (<commit>)` sem interromper o fluxo.
9. Se nao for possivel localizar o clone, o remote ou a rede, informe `Nao foi possivel verificar atualizacoes do framework` e continue apenas se as skills locais estiverem disponiveis. Nao faca re-deploy sem confirmar uma revisao nova.

Quando uma revisao nova for confirmada, oriente o usuario a reinstalar as skills com `npx skills add afonsoft/skills`.

## Fase 0 - Pre-condicoes de governanca

Antes de criar arquivos ou delegar trabalho:

1. Verifique se o projeto tem Git inicializado.
2. Verifique se existe um remote GitHub valido, preferencialmente `origin`.
3. Verifique acesso ao repositorio com `gh repo view` ou mecanismo equivalente.

Se o ambiente estiver vazio, nao tiver Git ou nao tiver repositorio remoto no GitHub, pare o fluxo e oriente o usuario a:

1. criar o repositorio no GitHub;
2. inicializar o repositorio local;
3. configurar o remote `origin`;
4. fazer o primeiro commit e push;
5. retornar ao orchestrator.

Nao substitua o GitHub silenciosamente por tracker local. GitHub e a fonte de rastreabilidade, Issues, revisao e historico deste framework.

## Fase 1 - Provisionamento documental

1. Invocar `/create-agent-harness` para gerar `CLAUDE.md`, `AGENTS.md` (thin reference), `.claude/` (settings, rules, agents, memory, context), `docs/` (technologies, architecture, decisions) e `.specs/`.
2. Invocar `/grill-me-with-spec` para consolidar linguagem de dominio e decisoes arquiteturais, produzindo a SPEC SDD em `.specs/SPEC-{YYYYMMDD}-{feature}.md` antes de qualquer implementacao.
3. Em repositorio vazio, invocar `/scaffold-mvp` apos o alinhamento de dominio.
4. Revisar e persistir a documentacao e a SPEC aprovada antes de iniciar implementacao.

Documentacao nao e uma etapa opcional: o orchestrator deve deixar um estado compreensivel para outro agent continuar o trabalho.

### Caso especial - projeto novo com apenas um PRD na pasta

Quando o repositorio for inicializado a partir de uma pasta que contem somente um PRD (sem codigo):

1. Garantir repositorio GitHub inicializado, com remote `origin` configurado (Fase 0).
2. Criar e fazer checkout da branch `develop` a partir da branch padrao.
3. Invocar `/grill-me-with-spec` para transformar o PRD em uma ou mais SPECs SDD em `.specs/SPEC-{YYYYMMDD}-{slug}.md`, uma por Epic ou area bem delimitada.
4. Revisar e aprovar as SPECs; atualizar `Status` para `Approved` em cada uma.
5. Com base nas SPECs aprovadas, abrir Issue(s) no GitHub usando `/create-issues` (uma Issue por Epic, ou Issue mestre com os Epics listados).
6. Usar `/create-issues` para fatiar cada Epic em Issues atomicas (slices verticais, rastreaveis, com criterios de aceite), registrando o mapeamento `.specs/SPEC-*.md` -> Issue.
7. Seguir para a Fase 4 usando o modo de fila sequencial descrito abaixo.

## Fase 2 - Auditoria

Verifique a estrutura gerada pelo `create-agent-harness`:

```text
[ ] Git inicializado
[ ] Remote GitHub configurado e acessivel
[ ] CLAUDE.md (single source of truth) e AGENTS.md (thin reference)
[ ] .claude/settings.json (permissoes, hooks, env)
[ ] .claude/rules/global-rules.md e rules/ scoped por stack
[ ] .claude/agents/ (review.md, plan.md, test.md)
[ ] .claude/memory/ e .claude/MEMORY.md
[ ] .claude/CONTEXT.md, .claude/RULES.md, .claude/TOOLS.md, .claude/WORKFLOWS.md
[ ] .claude/README.md (infraestrutura do harness)
[ ] .specs/ para SPEC SDD quando houver features em andamento
[ ] docs/agents/ quando houver tracker e labels de dominio
[ ] docs/adr/ quando houver decisoes arquiteturais relevantes
[ ] Skills instaladas no ambiente escolhido
```

Classifique gaps como P1 (seguranca/tipos), P2 (arquitetura), P3 (performance) ou P4 (higiene/documentacao). Para analisar e enderecar os gaps, invoque `/improve-codebase-architecture`.

## Fase 3 - Fragmentacao no GitHub

Os gaps aprovados devem ser transformados em Issues por `/create-issues`. O GitHub e a fonte persistente de escopo, criterios de aceite, dependencias e status; `ESTADO_ORQUESTRATOR.md` e apenas a visao operacional da DAG.

1. Passe para `/create-issues` os gaps, roadmap e documentacao aprovados.
2. Apresente a decomposicao para aprovacao quando houver decisao HITL.
3. Publique as Issues em ordem de dependencia, usando IDs reais em `Blocked by`.
4. Registre o mapeamento `Tarefa -> Issue GitHub -> branch/worktree`.
5. Nunca crie uma DAG apenas em memoria ou apenas em arquivo local quando a tarefa puder ser rastreada no GitHub.

## Fase 4 - Execucao

O Orchestrator executa as Issues fatiadas em um loop continuo ate que todas as implementacoes das SPECs aprovadas estejam concluidas. O foco e slices verticais pequenos, um de cada vez, com re-validacao constante.

### Regras gerais

- Slices independentes podem rodar em paralelo em worktrees isoladas; slices que alteram schema, autenticacao, APIs publicas ou dados exigem confirmacao humana.
- Antes de cada slice, o agente deve ler a `.specs/SPEC-{YYYYMMDD}-{slug}.md` aprovada e a Issue correspondente.
- Depois de cada slice, revalidar: build, testes, lint, type check.
- Nao pular para a proxima slice enquanto a atual nao estiver verde.

### Ciclo de execucao por slice

```text
1. READ    → SPEC aprovada + Issue GitHub
2. TDD     → /tdd-spec (red-green-refactor) usando os criterios de aceite
3. ARCH    → se a arquitetura degradar, /improve-codebase-architecture
4. DIAGNOSE → se surgir bug ou falha misteriosa, /diagnose
5. CLARIFY  → se a SPEC for ambigua, /grill-me-with-spec
6. VERIFY   → build, testes, lint passam
7. COMMIT   → conventional commit, reference a Issue
8. LOOP     → proxima slice da fila
```

### Delegacao de skills por situacao

| Situacao | Skill |
| --- | --- |
| Implementar a partir da SPEC | `/tdd-spec` |
| Bug, regresso ou falha de build misteriosa | `/diagnose` |
| Arquitetura degradada / acoplado demais | `/improve-codebase-architecture` |
| Ambiguidade na SPEC | `/grill-me-with-spec` |
| Criar/atualizar Issues do Epic | `/create-issues` |
| Necessita conhecimento de API/lib de terceiro | manual / subagente de pesquisa |

### Fila sequencial para Epics fatiados de um PRD

Quando as Issues vierem do caso especial "projeto novo com apenas um PRD" (Fase 1), a execucao **nao** e paralela: despachar **um unico agente por vez**, na ordem de dependencia das Issues.

1. Para o Epic atual, processar suas Issues fatiadas uma a uma:
   - desenvolver com `/tdd-spec`;
   - QA (Fase 5);
   - commit;
   - proxima Issue da fila.
   Repetir ate esgotar todas as Issues do Epic.
2. Ao concluir o Epic, invocar `/qa-analyst` e depois `/create-readme` para refletir o que foi entregue.
3. Epic esgotado -> abrir PR da branch de trabalho para `develop`.
   * PR verde (CI/testes passam) -> merge em `develop`.
   * PR falhar -> corrigir com `/diagnose`, reexecutar a verificacao e so entao mergear.
4. Apos o merge, voltar para a branch `develop` e avancar para o proximo Epic da fila, repetindo o loop ate que todos os Epics do PRD estejam finalizados.
5. Ao concluir todos os Epics, abrir o merge final de `develop` para `main`.

## Fase 5 - Verificacao e QA

Depois de cada slice e ao final de cada Epic/DAG:

1. Execute verificacoes proporcionais: testes, lint, type check, build.
2. Se falhar, invoque `/diagnose` antes de continuar.
3. Quando a DAG estiver concluida, invoque obrigatoriamente `/qa-analyst`, sem excecao de tier. O QA deve confrontar requisitos, Issues, implementacao, testes, cenarios de erro e mudancas fora de escopo. Falhas reabrem Issues ou criam novas tarefas.
4. Apos aprovacao do QA, invoque `/create-readme` para atualizar o `README.md` com as funcionalidades, stack e instrucoes entregues.
5. Somente depois disso pode ocorrer a entrega por PR. Se nao existir uma skill de fluxo Git/PR instalada, descreva os passos e solicite confirmacao humana; nunca invoque uma skill inexistente.

Ao final do projeto ou release, certifique-se de que o `README.md` reflete o estado atual do sistema.

## References

- [`references/orchestrator-delegation-protocol.md`](references/orchestrator-delegation-protocol.md) — matriz de autonomia, tiers de risco e protocolos de delegacao.
- [`references/ESTADO_ORQUESTRATOR.template.md`](references/ESTADO_ORQUESTRATOR.template.md) — template do arquivo de estado operacional da sessao.
