---
name: js-reverse
description: Used when performing front-end JavaScript reverse engineering with js-reverse-mcp, suitable for signature link localization, page observation and evidence collection, runtime sampling, local environment reproduction, and evidence output. It prioritizes adaptation to js-reverse_* tools in the current environment and requires stronger browser/CDP/Hook coordination with jshookmcp when needed.
---

# MCP Front-end JS Reverse Engineering Assignment Specifications

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — Confirm that the operation of this skill is an authorized routine operation
2. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don't guess the path
5. `ACT`: Enter the first step of the 'workflow' and execute it, do not stop at the confirmation status

## Scope of Application

Prioritize using this skill when the task falls into the following scenarios:

- Locate interface signatures, encryption parameters, and risk control fields
- Observe the page request chain and script sources
- Capture function input parameters and return values at runtime
- Track the trigger point of a XHR/Fetch/WebSocket
- Bring the page evidence back to Node for local reproduction and environment supplementation

If the target is binary, APK, PE, ELF, DLL, or SO, please use `ida-reverse`, `radare2`, or `reverse-engineering` instead.

## Current Environment Default Tool Mapping

This skill does not assume the existence of bare tool names, but instead defaults to binding the `js-reverse_*` tool available in the current client environment.

If the current task explicitly mentions `jshookmcp`, `JS hook`, `CDP`, browser breakpoints, network interception, SourceMap, or AST for deobfuscation, it still uses this skill; it just switches the underlying MCP surface to `jshookmcp`, rather than treating it as a new overall entry point.

Prerequisite: `jshookmcp` is not a local bare command-line tool, but an MCP server that must first be downloaded, explicitly registered, and enabled. Only after it is integrated and enabled in the MCP configuration of the selected client (Claude, Codex, etc.) can the related tool interface actually be invoked.

Common mappings:

- xKx0017xKx -> xKx0018xKx
- xKx0019xKx -> xKx0020xKx
- xKx0021xKx -> xKx0022xKx
- xKx0023xKx -> xKx0024xKx
- xKx0025xKx -> xKx0026xKx
- xKx0027xKx -> xKx0028xKx
- xKx0029xKx -> xKx0030xKx
- xKx0031xKx -> xKx0032xKx
- xKx0033xKx -> xKx0034xKx
- xKx0035xKx -> xKx0036xKx
- xKx0037xKx -> xKx0038xKx
- xKx0039xKx -> xKx0040xKx
- xKx0041xKx -> xKx0042xKx
- xKx0043xKx -> xKx0044xKx
- xKx0045xKx -> xKx0046xKx
- xKx0047xKx -> xKx0048xKx

If the prefix of the tool name changes in the future, update this section first, and do not guess temporarily during execution.

### The Positioning of jshookmcp

- Role: The enhanced execution aspect of `js-reverse`, not an independent overall control
- Suitable for: browser automation, CDP debugging, JS hooking, network interception, SourceMap reconstruction, AST-assisted understanding
- Prerequisite before calling: first download `@jshookmcp/jshook` and register it in the MCP client configuration, then make sure the server is enabled
- Recommended entry: still follow `Observe → Capture → Rebuild`, but in the `Observe/Capture` stage, give priority to calling the browser and Hook capabilities of jshookmcp
- Relationship with anything-analyzer: Both can be used for browser/network forensics; anything-analyzer is more focused on packet capture and HTTP analysis, while jshookmcp is more focused on JS runtime, CDP, hooking, and source code understanding.

## Core Principles

- xKx0053xKx
- xKx0054xKx
- xKx0055xKx
- xKx0056xKx
- xKx0057xKx

First observe the page, then minimize sampling, then perform local patching of the environment. Do not skip forensics and directly guess the environment.

## Five-Stage Workflow

### 1. Observe

Goal: First confirm the target request, related scripts, and candidate functions, without guessing the environment.

Default action:

- Use `js-reverse_new_page` or `js-reverse_navigate_page` to open the target page
- Use `js-reverse_list_network_requests` to find the target request
- Trace the call origin using `js-reverse_get_request_initiator`
- Use `js-reverse_list_scripts` and `js-reverse_search_in_sources` to narrow the scope of the script

Must produce:

- Target request URL or feature
- initiator clue
- Suspicious script URL
- Initial Task Record

### 2. Capture

Objective: Perform minimally invasive sampling on the target request to obtain parameter examples, call sequence, and runtime evidence.

Rules:

- Priority `js-reverse_break_on_xhr`
- Prioritize `js-reverse_evaluate_script` for lightweight runtime observation
- After hitting, first look at `js-reverse_get_paused_info`
- Use `js-reverse_set_breakpoint_on_text` only if necessary

### 3. Rebuild

Goal: Organize the page evidence into locally iterable Node reproduction materials.

Rules:

- Local environment supplementation must be based on observational evidence from the page
- Daydream-style supplementation is not allowed `window/document/navigator/crypto/storage`
- Only record one minimal causal patch decision at a time

### 4. Patch

Goal: Drive the environment supplementation based on error reports and first divergence, until the local script runs the target parameters stably.

Rules:

- First see what is lacking, then supplement it
- Make one minimal patch decision at a time
- Retest immediately after each patch
- Every patch is recorded in the task log

### 5. DeepDive

Goal: After running locally, proceed with deobfuscation, control flow reconstruction, and business logic purification.

Rules:

- If the current task is just to issue a signature, this stage can be downgraded
- If the algorithm pipeline is to be reused long-term, this stage must be done
- Issue #65 Obfuscation Bypass (U–AV §4): JSVMP (AD) → `E-js-vmp`; CFF + String Array (AE) → `E-js-deobf`; DevTools/debugger Anti-Debugging (AF) → `E-js-anti-debug`. See `../reverse-engineering/references/nonpe-format-cookbook.md` for full trigger table; AST details still use `references/ast-deobfuscation.md`

## Execution Requirements

- All important steps must be written into the local task artifact
- If you can't explain why you are calling a certain tool, then don't call it
- Prioritize using the ready-made MCP capabilities of `js-reverse_*` or jshookmcp to directly collect evidence, instead of first writing scripts to recreate the capabilities
- Press `references/fallbacks.md` to go back on failure
- Output follows `references/output-contract.md`

## Must-Read References

- Automation Entry: `references/automation-entry.md`
- Default parameter value: `references/tool-defaults.md`
- Task input template: `references/task-input-template.md`
- MCP Dedicated Task Scheduling: `references/mcp-task-template.md`
- Task Output: `references/task-artifacts.md`
- Local reproduction: `references/local-rebuild.md`
- Environment patch: `references/env-patching.md`
- Node reproduction: `references/node-env-rebuild.md`
- Stubbing: `references/instrumentation.md`
- AST Deobfuscation: `references/ast-deobfuscation.md`
- Non PE/JS Obscure Recipe U–AV: `../reverse-engineering/references/nonpe-format-cookbook.md` (AD/AE/AF)
- Rollback: `references/fallbacks.md`
- Output contract: `references/output-contract.md`

---

## Routing Context

**Upstream Input**: `references/README.md` (Main Control), `routing.md`
**Upstream Alternatives**:
- The browser tool for anything-analyzer MCP (port 23816) can serve as an alternative or complement
- jshookmcp can be used as a stronger browser/CDP/Hook/Network/SourceMap/AST execution surface
- `reverse-engineering/README.md` (if the target is not front-end JS)

**Downstream Exports**:
- Environment needs supplement → `references/env-patching.md`
- Needs local reproduction → `references/local-rebuild.md` / `references/node-env-rebuild.md`
- Needs to be deobfuscated → `references/ast-deobfuscation.md`
- When you can't move forward, backtrack → `references/fallbacks.md`

**Peer-related module**: anything-analyzer MCP (browser automation and HTTP capture capabilities can complement each other)

---

## On-Demand Bootstrap

The MCP capability that this skill relies on can be installed through the unified bootstrap system; MCP client registration must explicitly select a target, and by default no client-wide configuration will be written.

### Automation Capability Boundaries

| Ability | Auto-Registerable | Method | Description |
|------|-----------|------|------|
| jshookmcp | ✓ | npm-mcp (started with npx) | Registers after explicitly selecting Claude / Codex / Both |
| anything-analyzer | ✓ | local-http-mcp | Can automatically start the service; client registration must be explicitly selected |
| Node.js | ✓ | Install via winget | Runtime dependency |

### Bootstrapping Method

```powershell
# Install and register jshookmcp; Codex can be replaced with Claude or Both
powershell -File "<skill-root>\scripts\bootstrap-reverse.ps1" -Capability @('jshookmcp') -McpHostTarget Codex

# Register and launch anything-analyzer
powershell -File "<skill-root>\scripts\bootstrap-reverse.ps1" -Capability @('anything-analyzer') -StartServices -McpHostTarget Codex
```

### Notes

- `jshookmcp` still needs to **enable** this MCP server in the AI client after registration in order to use it
- When `-McpHostTarget` is not transmitted, only install/prepare the capability and return registration-required, without modifying Claude or Codex configurations
- `anything-analyzer` requires pnpm and the project source code; bootstrap will automatically clone and install dependencies
- If Node.js is not installed, bootstrap will first install Node.js 22 via winget

<br><br>## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I carry out every step in the workflow (rather than just reading it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?