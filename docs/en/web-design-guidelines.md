# Web Design Guidelines

Audits UI code for interface-guideline compliance — accessibility, focus, forms, animation, typography, images, performance, state, touch, theming, i18n, hydration, copy — and optionally validates deployed pages against **Lighthouse 95+** targets, then turns confirmed pendencies into Draft SPECs via `write-specs`.

Merged from two sources: the `web-design-guidelines` skill (vercel-labs/agent-skills — its rules are vendored locally, no runtime fetch) and the `lighthouse-95` skill (aliborhothamud — measure → diagnose → report loop). Read-only: it never edits application code; fixes flow through the SPEC/PR pipeline.

## 🎯 Purpose

Design debt hides in two places: the source (an icon button without `aria-label`, `transition: all`, images without dimensions) and the runtime (LCP waiting on a font, TBT from a JS lib, contrast failures on the deployed page). This skill covers both:

1. **Static review** — applies the complete interface-guidelines rule set to UI files (`file:line` findings), with mappings for React/Next.js, Angular, and Blazor/Razor.
2. **Lighthouse verification** — measures the real production URL (mobile + desktop), interrogates the JSON for exact causes, and reports evidence — never single-run claims.
3. **SPEC pipeline** — groups confirmed pendencies into fixable units, writes one Draft SPEC per group via `write-specs`, waits for the approval gate, then publishes an Epic + slice Issues via `create-issues` and hands off to `orchestrator`.

## 🛠️ How it Works

1. **Scope** — choose mode: static review, Lighthouse, or both; resolve file globs and/or the deployed URL.
2. **Static review** — every in-scope file read in full against the full rule set; findings cited `file:line` with severity.
3. **Lighthouse** — mobile runs first (default emulation), desktop confirms; JSON interrogated for LCP element/phases, TBT culprits, and every failing audit with selectors.
4. **Report** — `design-review-{YYYYMMDD}.md` at the repo root: findings by category with severity + fix direction, metric table, coverage, and proposed finding groups.
5. **SPECs** — `write-specs` invoked per approved group (`.specs/SPEC-*.md`, `Draft`).
6. **Approval gate** — pt-BR summary; nothing external happens before an explicit `sim`.
7. **Issues** — `create-issues` publishes the `Design Review {YYYYMMDD}` Epic plus one slice Issue per SPEC.
8. **Handoff & state** — `orchestrator` executes; `.claude/memory/web-design-guidelines-{YYYYMMDD}.md` keeps the run idempotent.

## 🚀 Usage

Use this skill when:

- The user asks to "review my UI", "check accessibility", "audit design", "review UX", or "validate my site".
- Validating a deployed page against Lighthouse 95+ (performance, accessibility, best practices, SEO).
- The user wants design pendencies turned into trackable SPECs/Issues instead of an unreadable findings dump.
- Invoked explicitly: `/web-design-guidelines` (or "run web-design-guidelines", "auditar o design").

Do **not** use it to design or build new UI (use `design`), for non-UI code review (`code-review-and-quality`), or to fix findings inline — pendencies go through the SPEC pipeline.

## 🧪 Evidence Rules

- Static findings always cite `file:line`; Lighthouse findings cite the audit ID, metric, value, and offending node/URL.
- Lighthouse verdicts require **3 consecutive runs** (±4 points variance); mobile is authoritative, desktop confirms.
- Only deployed production-built URLs are measured — never localhost or dev bundles; preview-vs-production alias is confirmed first.

## 🔗 Correlation

- **Downstream**: `write-specs` authors each finding-group SPEC; `create-issues` publishes Epic + slices; `orchestrator` + `execute-specs` coordinate fixes.
- **Siblings**: `design` builds new UI (this skill audits it); `qa-analyst` deepens a11y/visual test planning; `code-review-and-quality` covers non-UI quality; `observability-and-instrumentation` helps when Core Web Vitals need real-user monitoring.
