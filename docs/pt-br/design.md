# Design

Skill de design de UI frontend para Angular, React e Blazor. Mobile-first, responsivo, pronto para produção, e agnóstico de framework na fase de conceito.

## Quando Usar

- Projetar, redesenhar ou melhorar uma interface frontend em Angular, React ou Blazor.
- Construir landing pages, dashboards, componentes, formulários ou layouts responsivos.
- A interface precisa funcionar primeiro no mobile e depois escalar para desktop.
- Você precisa escolher ou comparar frameworks CSS como Bootstrap ou Tailwind.

## O Que Faz

`design` transforma um brief em um conceito de UI deliberado e consciente do framework. Começa em 375 px, define uma hierarquia visual clara e escala por breakpoints guiados por conteúdo. Cobre tipografia, cor, espaçamento, layout, componentes, motion, acessibilidade, UX writing, design tokens e mapeamento de frameworks CSS.

## Modos de Design

- **Persuade** — landing pages, marketing, pricing. Conquistar atenção e ação.
- **Operate** — dashboards, admin, editores, settings. A conclusão da tarefa é prioridade.
- **Read** — docs, artigos, help, changelogs. Estruturar para compreensão.
- **Experience** — portfolios, galerias, showcases. Deixar o artefato liderar.

## Comandos

| Comando | Propósito |
|---------|-----------|
| `shape` | Planejar UX/UI antes de escrever código |
| `layout` | Ajustar espaçamento, ritmo e hierarquia visual |
| `typeset` | Melhorar hierarquia tipográfica e escolha de fontes |
| `colorize` | Construir ou refinar um sistema de cores |
| `adapt` | Adaptar o design entre breakpoints |
| `audit` | Verificar a11y, performance e responsividade |
| `harden` | Cobrir edge cases, i18n, erros e inputs reais |
| `onboard` | Projetar first-run e empty states |
| `polish` | Passada final de qualidade antes do envio |

## Piso de Qualidade

- Layout mobile-first em 375 px continua sendo a história mais forte.
- Alvos de toque ≥ 44×44 px e visualmente separados.
- Texto do corpo ≥ 16 px, medida de 45–75 caracteres.
- Contraste WCAG AA (4.5:1 corpo, 3:1 texto grande/controles).
- Modo claro/escolhido a partir da cena de uso, não da categoria.
- Respeito à preferência `prefers-reduced-motion`.
- Foco de teclado visível e lógico.
- Estados de hover, focus, active, disabled, loading, empty e error desenhados.
- Defaults do framework não são usados como identidade da marca.
- Nenhum padrão banido da referência `craft-floor`.

## Referências

Veja [`skills/design/references/`](https://github.com/afonsoft/skills/tree/main/skills/design/references).
