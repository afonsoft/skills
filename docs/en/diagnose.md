# Diagnose — Root-Cause Analysis for Hard Bugs

Disciplined diagnosis loop for hard bugs, unexpected failures, and performance regressions. Builds a tight pass/fail feedback loop first, then minimises, hypothesises, instruments, fixes, and re-validates — never guesses.

## 🎯 Purpose

Turn a vague failure report into a verified root-cause fix. The skill's core discipline: **no fix without a reproduction, no "done" without re-validation**. All user-facing questions and findings are reported in Portuguese (pt-BR).

## 🛠️ How it Works

1. **Build a feedback loop** — Construct one tight, deterministic, agent-runnable command that goes red on *this* bug (failing test, curl script, CLI diff, headless browser, trace replay, fuzz loop, bisection harness, differential loop, or HITL script). The phase ends only when a red-capable command exists.
2. **Reproduce + minimise** — Confirm the loop shows the user's exact symptom, then cut code/data/config/deps/environment one at a time until every remaining element is load-bearing.
3. **Hypothesise** — Generate 3–5 ranked, falsifiable hypotheses (each with a stated prediction) and show the ranking to the user before testing.
4. **Instrument** — Probe one variable at a time; debugger first, then targeted logs tagged `[DEBUG-xxxx]` for grep-clean removal. Performance bugs: baseline measurement, then bisect.
5. **Fix + regression test** — Turn the minimal repro into a failing test at a *correct seam* before fixing; if no correct seam exists, that itself is a finding for `improve-codebase-architecture`.
6. **Cleanup + re-validate** — Re-run the original repro, run the regression and neighbouring tests, remove all instrumentation, and record the confirmed hypothesis in the commit/PR message.

## 📚 Stack Playbooks

When the codebase matches a supported stack, the skill loads a ready-made playbook from `skills/diagnose/references/` with reproduction commands, debugger/profiler workflows, tagged instrumentation snippets, and log-query cheat sheets:

- `dotnet-debugging.md` — dotnet-counters, dotnet-stack, dotnet-dump (SOS), dotnet-trace, dotnet-gcdump, dotnet-monitor, EF Core `LogTo`/`TagWith`, journalctl/jq queries
- `angular-debugging.md` — Angular DevTools profiler, `ng.*` console APIs, RxJS `tap` probes, change-detection profiling
- `python-debugging.md` — `breakpoint()`/`pdb`, pytest `--pdb`/`--trace`, py-spy, faulthandler, tracemalloc, asyncio debug mode
- `react-debugging.md` — React DevTools profiler, why-did-you-render, re-render/effect bug patterns

## 🧰 Technique References & Scripts

Technique references merged from `obra/superpowers` systematic-debugging (v1.5.0):

- `references/root-cause-tracing.md` — trace a bad value backward through the call stack to its origin; fix at the source, not the throw site
- `references/defense-in-depth.md` — validate at every layer bad data crosses, so the bug class becomes impossible
- `references/condition-based-waiting.md` — replace guessed `sleep`/`setTimeout` with condition polling in flaky tests
- `scripts/find-polluter.sh` — bisects test files to find which one leaves stray files/state behind

The skill also enforces an **iron rule** (no fixes without a red loop and a confirmed root cause), a **red-flags** self-check list, and a **three-strike rule** that escalates to an architecture review after 3 failed fixes.

## 🧩 Special Modes

- **Agent Self-Debug** — when the failure is the agent session itself (tool-call loops, context drift): Failure Capture → Root-Cause Diagnosis → Contained Recovery → Self-Debug Report.
- **AI Workflow Diagnostic** — when the misbehaving system is an agent or AI workflow: scored 1–5 audit across Prompt Quality, Context Efficiency, Tool Health, Architecture Fitness, and Safety & Reliability, with prioritized remediation.
- **Silent-Failure Hunt** — when code "works" but misbehaves quietly: hunts empty catches, dangerous fallbacks, lost stack traces, and missing error handling.

## 🚀 Usage

Use this skill when the user reports a hard bug, unexpected failure, or performance regression (e.g., "use /diagnose", "debug this", "execute diagnose").

## 🔗 Correlation

- **Upstream**: `orchestrator` routes bugs and regressions here; `qa-analyst` bug reports feed it.
- **Downstream**: `improve-codebase-architecture` when diagnosis reveals missing seams; `create-issues` to document the root cause; `observability-and-instrumentation` when the fix needs durable telemetry.
- **Siblings**: `write-specs` when the bug reveals missing requirements.
