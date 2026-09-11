---
name: diagnose
license: MIT
description: Disciplined diagnosis and re-validation loop for hard bugs and performance regressions. Reproduce, minimise, hypothesise, instrument, fix, and regression-test. Use when the user says diagnose this / debug this, reports a bug, says something is broken/throwing/failing, or describes a performance regression. User-facing questions and findings must be in Portuguese (pt-BR). Part of the afonsoft/skills collection.
metadata:
  version: "1.0.1"
  visibility: public
  author: afonsoft
  url: https://github.com/afonsoft/skills
---

# Diagnose

A discipline for hard bugs and regressions. Skip phases only when explicitly justified. All questions and findings reported to the user must be in **Portuguese (pt-BR)**.

When exploring the codebase, use the project's domain glossary from `.claude/CONTEXT.md` to get a clear mental model of the relevant modules, and check `docs/architecture/` for decisions in the area you are touching.

**Re-validation loop**: after every hypothesis, fix, or change, re-run the reproduction and the regression checks before declaring the bug resolved.

## When to Use

- User asks or mentions this skill in English (e.g., "use /diagnose", "run diagnose").
- O usuário pede ou menciona esta skill em português (ex.: "use /diagnose", "execute diagnose").

## Phase 1 — Build a feedback loop

**This is the skill.** Everything else is mechanical. If you have a fast, deterministic, agent-runnable pass/fail signal for the bug, you will find the cause — bisection, hypothesis-testing, and instrumentation all just consume that signal. If you do not have one, no amount of staring at code will save you.

Spend disproportionate effort here. **Be aggressive. Be creative. Refuse to give up.**

### Ways to construct one — try them in roughly this order

1. **Failing test** at whatever seam reaches the bug — unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) — drives the UI, asserts on DOM/console/network.
5. **Replay a captured trace.** Save a real network request / payload / event log to disk; replay it through the code path in isolation.
6. **Throwaway harness.** Spin up a minimised version of the problem in a new project, then debug that.

Ask the user in Portuguese when you need more data:

```text
Preciso de um exemplo minimo que reproduza o erro. Voce consegue me fornecer:

1. O comando ou acao que dispara o problema.
2. A saida ou mensagem de erro exata.
3. O ambiente (local, CI, staging, producao).

➡️ Se nao tiver, vou tentar construir um caso de reproducao sozinho.
```

## Phase 2 — Minimise the problem

**This is the skill.** If you cannot reproduce the bug in isolation, you cannot fix it. If you cannot minimise the problem, you cannot reproduce it. If you cannot reproduce it, you cannot fix it.

### Ways to minimise — try them in roughly this order

1. **Remove code** until the bug disappears. Add it back in small chunks to find the culprit.
2. **Remove data** until the bug disappears. Add it back in small chunks to find the culprit.
3. **Remove configuration** until the bug disappears. Add it back in small chunks to find the culprit.
4. **Remove dependencies** until the bug disappears. Add them back in small chunks to find the culprit.
5. **Remove environment** until the bug disappears. Add it back in small chunks to find the culprit.

## Phase 3 — Hypothesise

**This is the skill.** If you cannot explain the bug, you cannot fix it.

### Ways to hypothesise — try them in roughly this order

1. **Check the obvious.** Is the bug in the code you are looking at? Is it in the code you are calling? Is it in the code calling you?
2. **Check the documentation.** Is the bug in the docs you are looking at? Is it in the docs you are calling?
3. **Check the logs.** Are the logs telling the truth? Are they masking the real error?
4. **Check the tests.** Is the bug in the tests you are running? Are they covering the real path?
5. **Check the codebase.** Are there other call sites with the same pattern?

Report the hypothesis to the user in Portuguese:

```text
Hipotese atual: [DESCRICAO_DA_HIPOTESE].

Vou validar com [ACAO_EXPERIMENTAL]. Se confirmar, o proximo passo e [PROXIMO_PASSO].

Concorda ou quer que eu teste outra hipotese primeiro?
```

## Phase 4 — Instrument

**This is the skill.** If you cannot see the bug, you cannot fix it.

### Ways to instrument — try them in roughly this order

1. **Add logs** around the suspect seam.
2. **Add metrics** to measure the suspect behaviour.
3. **Add traces** to follow the request path.
4. **Add assertions** to fail fast on invariants.
5. **Add tests** that reproduce the bug before the fix.

## Phase 5 — Fix

Do the smallest, safest change that removes the root cause. Avoid band-aids. If the fix touches many files, present the plan to the user in Portuguese before editing.

```text
Raiz do problema: [RAIZ].
Correcao proposta: [DESCRICAO_DA_CORRECAO].
Arquivos afetados: [LISTA].

Posso aplicar a correcao e depois rodar os testes?
```

## Phase 6 — Regression-test and re-validate

**This is the skill.** If you cannot verify the fix, you cannot call it done.

### Required checks

1. **Reproduction fails before the fix, passes after.**
2. **Add a regression test** for the fixed bug.
3. **Run the affected test layer** (unit, integration, E2E).
4. **Run a lightweight regression** on neighbouring flows.
5. **Remove or revert instrumentation** that is no longer needed.

Report the result in Portuguese:

```text
Correcao aplicada em [ARQUIVOS].

- Teste de reproducao: [PASS/FAIL]
- Testes de regressao: [PASS/FAIL]
- Testes afetados: [PASS/FAIL]

O bug esta resolvido. Quer que eu abra uma Issue para documentar a causa raiz com /create-issues?
```

## Agent Self-Debug / Introspection (use when the failure is the agent itself)

If the bug is not in the codebase but in the agent session — repeated tool-call failures, loops, context drift, or mismatch between expected and actual filesystem state — apply the agent-introspection loop.

### Phase A — Failure Capture
Before trying to recover, record:
- error type, message, and stack trace when available
- last meaningful tool call sequence
- what the agent was trying to do
- current context pressure: repeated prompts, oversized pasted logs, duplicated plans, or runaway notes
- current environment assumptions: cwd, branch, relevant service state, expected files

```markdown
## Failure Capture
- Session / task:
- Goal in progress:
- Error:
- Last successful step:
- Last failed tool / command:
- Repeated pattern seen:
- Environment assumptions to verify:
```

### Phase B — Root-Cause Diagnosis
Match the failure to a known pattern:

| Pattern | Likely Cause | Check |
| --- | --- | --- |
| Maximum tool calls / repeated same command | loop or no-exit observer path | inspect the last N tool calls for repetition |
| Context overflow / degraded reasoning | unbounded notes, repeated plans, oversized logs | inspect recent context for duplication and low-signal bulk |
| `ECONNREFUSED` / timeout | service unavailable or wrong port | verify service health, URL, and port assumptions |
| `429` / quota exhaustion | retry storm or missing backoff | count repeated calls and inspect retry spacing |
| file missing after write / stale diff | race, wrong cwd, or branch drift | re-check path, cwd, git status, and actual file existence |
| tests still failing after “fix” | wrong hypothesis | isolate the exact failing test and re-derive the bug |

Diagnosis questions:
- is this a logic failure, state failure, environment failure, or policy failure?
- did the agent lose the real objective and start optimizing the wrong subtask?
- is the failure deterministic or transient?
- what is the smallest reversible action that would validate the diagnosis?

### Phase C — Contained Recovery
Prefer these interventions in order:
1. Restate the real objective in one sentence.
2. Verify the world state instead of trusting memory.
3. Shrink the failing scope.
4. Run one discriminating check.
5. Only then retry.

Bad pattern: retrying the same action three times with slightly different wording.
Good pattern: capture failure → classify the pattern → run one direct check → change the plan only if the check supports it.

### Phase D — Self-Debug Report
End with:

```markdown
## Agent Self-Debug Report
- Session / task:
- Failure:
- Root cause:
- Recovery action:
- Result: success | partial | blocked
- Token / time burn risk:
- Follow-up needed:
- Preventive change to encode later:
```

## Silent-Failure Hunt

When the code "works" but misbehaves quietly, hunt for silent failures before declaring the bug resolved.

### Hunt Targets
1. **Empty Catch Blocks** — `catch {}`, ignored exceptions, errors converted to `null` / empty arrays with no context.
2. **Inadequate Logging** — logs without enough context, wrong severity, log-and-forget handling.
3. **Dangerous Fallbacks** — default values that hide real failure, `.catch(() => [])`, graceful-looking paths that make downstream bugs harder to diagnose.
4. **Error Propagation Issues** — lost stack traces, generic rethrows, missing async handling.
5. **Missing Error Handling** — no timeout or error handling around network/file/db paths, no rollback around transactional work.

### Output Format
For each finding:
- location
- severity
- issue
- impact
- fix recommendation

## Re-Validation Loop

Diagnosis is iterative. After every change, re-run the reproduction. If the bug moves or changes, go back to Phase 3. Do not declare the bug fixed until the reproduction passes and the regression suite is green.

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Fixing without a reproduction first | Build a reproduction before changing code. |
| Skipping minimisation | Minimise first, or you fix symptoms, not the cause. |
| Removing instrumentation too early | Keep it until the fix is verified. |
| Not adding a regression test | Every fixed bug deserves a test. |
| Declaring done without re-validation | Re-run the reproduction and the suite. |

## References

- `qa-analyst` — for test planning and bug reporting
- `grill-me-with-spec` — for producing specs when the bug reveals missing requirements
- `improve-codebase-architecture` — when the diagnosis reveals structural seams that need deepening
- `agent-introspection-debugging` — when the failure is the agent session itself (loops, context drift, repeated tool calls)
- `silent-failure-hunter` — when the code works but misbehaves quietly
