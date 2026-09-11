# Design

Frontend UI design skill for Angular, React, and Blazor. Mobile-first, responsive, production-grade, and framework-agnostic at the concept stage.

## When to Use

- Design, redesign, or improve a frontend interface in Angular, React, or Blazor.
- Build landing pages, dashboards, components, forms, or responsive layouts.
- The interface must work on mobile first and then scale gracefully to desktop.
- You need to choose or compare CSS frameworks such as Bootstrap or Tailwind.

## What It Does

`design` turns a brief into a deliberate, framework-aware UI concept. It starts at 375px, defines a clear visual hierarchy, and scales up through content-driven breakpoints. It covers typography, color, spacing, layout, components, motion, accessibility, UX writing, design tokens, and CSS framework mapping.

## Design Modes

- **Persuade** — landing pages, marketing, pricing. Earn attention and action.
- **Operate** — dashboards, admin, editors, settings. Task completion wins.
- **Read** — docs, articles, help, changelogs. Structure for comprehension.
- **Experience** — portfolios, galleries, showcases. Let the artifact lead.

## Commands

| Command | Purpose |
|---------|---------|
| `shape` | Plan UX/UI before writing code |
| `layout` | Fix spacing, rhythm, and visual hierarchy |
| `typeset` | Improve typography hierarchy and font choices |
| `colorize` | Build or refine a color system |
| `adapt` | Adapt the design across breakpoints |
| `audit` | Check a11y, performance, and responsive behavior |
| `harden` | Cover edge cases, i18n, errors, and real-world inputs |
| `onboard` | Design first-run and empty-state experiences |
| `polish` | Final quality pass before shipping |

## Craft Floor

- Mobile-first layout at 375px remains the strongest story.
- Touch targets ≥ 44×44 px and visually separated.
- Body text ≥ 16 px, measure 45–75 ch.
- WCAG AA contrast (4.5:1 body, 3:1 large text/controls).
- Light or dark mode chosen from the use scene, not the category.
- Reduced-motion preference respected.
- Keyboard focus visible and logical.
- Hover, focus, active, disabled, loading, empty, and error states are designed.
- Framework defaults are not passed off as brand design.
- No banned patterns from the `craft-floor` reference.

## References

See [`skills/design/references/`](https://github.com/afonsoft/skills/tree/main/skills/design/references).
