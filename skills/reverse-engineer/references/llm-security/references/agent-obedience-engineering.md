#AI Agent Compliance Engineering - Let AI actually do the work after reading the workflow

> Source: 2026 Multi-Source Comprehensive (Anthropic Skill Engineering, Microsoft Code Words, Strands Steering Hooks, Gradient Flow Harness Engineering)
> Applicable scenarios: AI coding agent (Claude Code / Codex / Cursor / Cline / Windsurf / Kiro, etc.) only confirms not to execute, skips steps, and omits key operations after reading README/RULES.md.

---

## Core problem diagnosis

The root cause of AI Agent "reading the workflow but not working" is not that the model has insufficient capabilities, but that there is a semantic escape space for natural language instructions:

| Root cause | Explanation |
|------|------|
| **Contextual Attention Decay** | The content in the middle of a long document is downgraded by the LLM attention mechanism, and the Agent actually only "sees" the beginning and end |
| **Semantic coverage** | The model will creatively reinterpret explicit instructions when optimizing "helpfulness" (such as interpreting MUST DO X as "recommended to do X") |
| **Passive language is treated as optional** | "Ready for next step → invoke X" is treated as a suggestion rather than an instruction |
| **Stateless Enforcement** | Lack of external state machine validation workflow sequence, Agent can skip steps without being discovered |
| **Silence state corruption** | Agent produces results with correct structure but incorrect semantics, and errors accumulate silently |

---

## Technology 1: Critical-First Pattern

**Put "What to do next" first and the context at the back. **

```
WRONG (Agent ignored):
[70 line item background and tool list]
→ "Next step: Run bootstrap to install missing tools"

CORRECT (Agent execution):
"## Execute now: run `bootstrap-reverse.ps1` to check and install missing tools
→ After completion, read routing.md to determine which skill to enter"
[Then project background and tool list]
```

**Principle**: LLM gives the highest attention weight to the first and last content of the prompt word. Intermediate content may be ignored entirely.

**Apply to this project**:
- The "Routing Entry" section of RULES.md should be after the trigger keyword and before the execution principle
- The first section of each README.md should be "Execute immediately" rather than "Applicable scenarios"

---

## Technique 2: Directive Over Suggestive

Replace all "advisory" language with RFC 2119-level directive language:

| Weak language (Agent may skip) | Strong language (Agent enforces) |
|---|---|
| "You can try..." | **MUST**: You must execute... |
| "Ready for next step → invoke X" | **NOW**: Call X immediately, do not wait for confirmation |
| "It is recommended to read routing.md first" | **REQUIRED**: Routing.md must be read before entering any submodule |
| "If you lack tools, you can bootstrap" | **NO EXCUSE**: The only correct operation when you lack tools is to call bootstrap, manual installation guesswork is prohibited |
| "Remember to update field-journal" | **CHECKLIST ENFORCED**: Check the Checklist item by item after the task is completed. Do not claim that the task is over before it is completed |
| "Should..." | **MUST** / **MUST NOT** |

**Key Mode**:```
MUST — violation = task failed
MUST NOT — Violation = Security Violation
SHOULD — If you don’t do it, you need to explain why.
MAY — truly optional
```

---

## Technique 3: Excuse Rebuttal Table

**This is the most critical patch for this project. ** The AI Agent will automatically generate "reasonable excuses" to skip steps when encountering resistance. List common excuses in advance and refute them one by one:

| Agent common excuses | Refutation (enforcement) |
|---|---|
| "This step can be omitted, I will just..." | **Skipping is prohibited. ** Every step in the behavior chain is required. If you think it can be skipped, output the specific reason first and let the user decide. |
| "In my judgment, this is not necessary" | **Your judgment does not apply here. ** List the specific criteria you used to judge and explain why this criterion allows skipping of explicitly written steps. |
| "Users probably don't need this" | **Never make decisions for users. ** Present all options to the user, marking recommendations but not hiding alternatives. |
| "I already know how to do it, no need to read X" | **Read X before acting. ** Even if you know for sure how to do it, X may contain constraints specific to this task. It only takes 2 seconds to read. |
| "To save time, I can skip in parallel..." | **The correct way to save time is to execute independent steps in parallel, not to skip steps. ** If the two steps do not depend on each other, do them in parallel; if they depend on each other, do them sequentially. |
| "I have used this tool before and know the path" | **Guessing the path is prohibited. ** The actual path must be obtained from tool-index, and the installation location is different on different machines. |
| "The task has been basically completed, no checklist is needed" | **The only definition of task completion is that all the Checklist is ticked. ** Tasks that are not completed on the Checklist are not considered completed. |
| "I didn't find tool-index, so I just guessed the path" | **Missing files is 100 times safer than guessing the wrong path. ** If tool-index is missing, run refresh-tool-index.ps1 to generate it first. |
| "The user didn't explicitly say that he wants to report, so I won't write it." | **Reporting is the default behavior, not optional. ** A report must be generated after the security task is completed, unless the user explicitly says "Do not report". |
| "This is too simple and no need to be recorded in a journal" | **Simple tasks also have pitfall value. ** At least record: target type + what was used + any accidents, one line is fine. |
| "The user asked me to redo the import table/step, but I changed it to another more useful step" | **Redo = redo the same step named** (or a legal prerequisite path confirmed by the user). MUST update the corresponding Evidence; impersonation with irrelevant steps is prohibited, and silent skipping is prohibited. Unpacking is a **prerequisite** for readable IAT, not a **replacement** for importing table Evidence. |
| "The user said that the packed sample should not be unpacked first but look at the import table; I will hand over the flower table directly and it will be completed." | **Feasibility latch:** When User-mandated execution and mark `quality=unreadable/packed`; it is prohibited to use fancy tables to draw negative conclusions. |
| "It crashed after unpacking, and I continued to change files on the disk." | **Patch 6:** Note E-self-check-crash / E-iat-repair-fail, and change to dynamic (bp CreateFile/GetFileSize). Unlimited static file modification is prohibited. |
| "IAT cannot be repaired well, I will try several shell tools statically to delay time" | **IAT repair iron rule:** Give priority to automatic/semi-automatic repair; the tool reports an error or cannot run after repair → Stop static IAT immediately, remember E-iat-repair-fail, and switch to dynamic API breakpoint capture. Infinite static fights are prohibited. |
| ".NET / No import table, hard door does not apply, I skip" | **Equivalent anchors still MUST:** .NET uses dnSpy/IL/ metadata digest to write E-imports semantic slot; DLL/SYS must be parallel to E-exports. No passing is allowed. |


**How to use**: Place this table near the end of RULES.md or other directive file (high attention area). Agent sees rebuttal before making excuses.

---

## Technology 4: Skill Engineering Five Modes (Anthropic 2026 Official)

| Mode | Applicable Scenarios | Key Skills |
|---|---|---|
| **Linear Flow** | Clear step-by-step process (deployment, installation) | Provide safe defaults, use negative instructions ("MUST NOT use --force") |
| **Decision Tree Decision Tree** | Platform navigation, fault diagnosis | Tree navigation + `references/` progressive loading |
| **Iterative Loop iterative loop** | TDD, review-fix loop | Hard rules in advance + **Excuse rebuttal table** Block shortcuts |
| **Baton Loop relay loop** | Multi-session, multi-Agent collaboration | Status externalized to `next-prompt.md` (MUST written before exiting) |
| **Multi-Phase + Checkpoints** | Multi-day complex workflow | Orchestrator "parent" skill + manual Go/No-Go checkpoint, mark time cost |

**This project corresponds**:
- Complete behavior chain = Linear Flow (15 steps executed sequentially)
- Routing matrix = Decision Tree (three-dimensional matching)
- Checklist = Multi-Phase Checkpoint (each step must be ticked)
- Field Journal = Baton Loop (cross-session state externalization)

---

## Technology 5: In-Band forced verification (Steering Hooks idea)

Instead of relying on AI "consciousness", self-verification instructions are embedded in Prompt:

```
Before each claim "task completed", MUST perform a self-check:
1. Did I skip any steps in the behavior chain? Which step?
2. Did I guess any toolpaths? If so, what is the actual tool-index path?
3. Are all the items in the Checklist checked? Why not ticked?
4. If the answer to any of the above items is "yes"/"unchecked", the task is not completed.
Go back to the corresponding step and re-execute it. Do not declare completion.
```

This approach allows the Agent to self-audit before saying "done", which is more immediate than external verification.

---

## Technique 6: Opaque Identifiers (Code Words) - for API/Tool Parameters

Microsoft 2026 research found that semantic parameter names will trigger the model's tendency to "help optimization".

```
WRONG: { "query": "...", "top": 9 } → 68.4% parameter compliance rate
CORRECT: { "query": "...", "code": "alpha" } → 100% parameter compliance rate
```

**Application Scenario**:
- Use shortcodes instead of semantic parameters when precise configuration needs to be passed in bootstrap scripts
- Parameters that require strong guarantees in tool calls are mapped using code word

---

## Technique 7: Dual AI Review Loop (Dual Validation)

```
AI A (executor) writes the output
  ↓
AI B (reviewer) checks against the rules
↓ by
output to user
↓ Failed
Return AI A correction with specific violation citations
```

**Applications in this project**:
- Embed a "self-review" step in RULES.md: before outputting the report, the Agent first uses its own capabilities to check the Checklist item by item.
- If you find that a project is not completed, go back to the corresponding steps to make up for it.

---

## Technique 8: Contextual window layout optimization

LLM attention distribution (high → low):```
[First 10%] ████████████ ← Maximum attention, put "ACT NOW" command
[Central 80%] ████░░░░░░░░ ← Attention decreases, put reference materials
[End 10%] ████████████ ← Attention picked up, put "No Skip" and Checklist
```

**Specific applications**:
1. **The first 10%**: execute the instruction immediately + trigger keyword
2. **Central 80%**: Detailed workflow, reference links, tool list
3. **Ending 10%**: Excuse and Refutation List + Hard Checklist + Prohibited Behavior List

---

## Actual Prompt template

### Template A: Forced startup template (embedded at the beginning of RULES.md)

```markdown
## CRITICAL: You must do the following immediately after reading this article (don’t just confirm, actually do it)

1. **NOW**: Detect the directory where this file is located → This is the package root directory
2. **NOW**: If it is used for the first time, write this rule into the global configuration (see the Global Injection chapter)
3. **NEXT**: Read `references/README.md` → `references/routing.md` → Determine which sub-skill to enter
4. **NEXT**: Read `references/tool-index.md` to confirm tool status
5. **THEN**: Start executing the actual task, do not stay in the "read" state

If you only reply "read", "completed", "I understand" without actually performing the above steps,
You just failed. What users need is that the tools are installed, the code is analyzed, and the vulnerabilities are verified.
Not a confirmation message.
```

### Template B: Submodule entry template (embedded at the beginning of each README.md)

```markdown
## ACTION REQUIRED (execute immediately after reading, don’t wait)

After reading this document:
1. Make sure you understand the applicable scenarios of this skill
2. Check if the machine has the required tools (read `../tool-index.md`)
3. If tools are missing → call bootstrap
4. If you have the tool → Start the first step of the workflow
5. If you’re not sure → List specific questions and don’t stay silent
```

### Template C: Task completion self-check template (embedded at the end of each README.md)

```markdown
## Task completion self-inspection (MUST confirm item by item before claiming completion)

□ I actually performed each step in the behavior chain (no skipping)
□ I didn't guess any tool paths (all from tool-index.md)
□ I produce reproducible commands/scripts/reports (not just describing the steps)
□ I updated field-journal (if there is any error)
□ I executed the post-completion checklist (report + chart + experience write-back)
```

---

## Prohibited behavior (supplemented from the perspective of Agent compliance)

- It is forbidden to only reply "Understood, please tell me the specific tasks" after reading RULES.md.
→ Correct approach: Perform global injection → Read README.md → Read routing.md → Determine the entry
- Don't say "Steps 1-4 completed" but actually just read them once
→ Correct approach: Distinguish between "read document" and "executed action", the latter has actual side effects
- Disable saying "Task Complete" without executing the Checklist
→ Checklist is the only definition of task completion
- Disable using "based on experience" instead of reading tool-index
→ The path is different on different machines. See tool-index as the only way to locate it.

---

## Summary: If I could only change one thing

**Add an "Act Now" instruction at the beginning of RULES.md**, and use strong instruction words such as bold, CRITICAL, and NOW.

This is the modification with the highest investment-output ratio. The "not working" behavior of most Agents comes from: automatically entering the "waiting for user instructions" mode after reading the file. A forced "act now" directive can break this pattern.

If you want to change the second thing: **Add an excuse to refute**. Agent will find excuses to stop when it encounters the first resistance, blocking these excuses in advance.