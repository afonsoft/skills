---
name: binary-diff
description: |
  跨版本符号迁移与二进制差分。当你有旧版本的符号/逆向结果，需要快速迁移到新版本时使用。
  适用场景：内核缺 PDB 用旧版符号推导、程序更新后批量迁移函数名、应用更新后快速定位新偏移。
  核心方法：用 LLM 做结构化差异比对，程序化输入输出，成本极低（200 函数 ~1 元）。
  触发关键词：符号迁移、bindiff、跨版本、PDB 缺失、函数偏移迁移、symbol migration、binary diff、版本对比。
---

# Cross-version symbol migration (Binary Diff)

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` - Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don’t guess the path
5. `ACT`: Enter the first step of the "workflow" and execute it, do not stop in the confirmation state

## Scope of application

Use this skill when the task falls into the following scenarios:

1. **Kernel/driver missing PDB** - There are symbols for the old version of ntoskrnl.exe. The new version of PDB was removed from the shelves by Microsoft. You need to use the old version symbols to deduce the new version of non-exported function addresses.
2. **Symbol migration after program update** — I have reverse engineered a program before, and the program has been updated. I don’t want to reverse engineer it again, so I can batch migrate the results with the old version.
3. **Protection mechanism update** — The old version has complete reverse results, and the new version needs to quickly locate new offsets of the same function
4. **Any binary comparison scenario of "old version symbols + new version unsigned"**

### Division of labor with other skills

| Scene | What to use |
|------|--------|
| Reverse a binary from scratch | `ida-reverse/` or `radare2/` |
| There are results from the old version, migrate to the new version | **This skill** |
| Two completely different binary comparisons | BinDiff / Diaphora (traditional tool) |

### Core Advantages

Compared to traditional solutions:

| Solution | 200 function costs | Time | Accuracy |
|------|--------------|------|--------|
| Manually open two IDA windows to compare | Free but time-consuming | Several hours | High |
| BinDiff automatic matching | Free | Fast | Medium (invalid when the structure changes greatly) |
| Completely handed over to Agent (CC/Codex) | 50-100 yuan | Slow | High |
| **This skill (LLM batch comparison)** | **~1 yuan** | **~10 seconds/function** | **High** |

## Core principles

```text
Old version of the function (signed) New version of the same function (unsigned)
    ↓                              ↓
Export disassembly + pseudocode Export disassembly + pseudocode
    ↓                              ↓
└──────── LLM structured comparison ─────────┘
                    ↓
Output YAML (symbol map)
                    ↓
Programmatic parsing → Batch application to new version of IDB
```

Key points:
- prompt is a fixed template, filled programmatically
- Input and output format determined, programmatic analysis
- LLM is only responsible for the step of "looking at two pieces of code and finding the corresponding relationship"
- Time cost and token cost are extremely low

## Prompt Template

### Standard comparison Prompt

```text
I have disassembly outputs and procedure code of the same function.

This is the function for reference:

**Disassembly for Reference**
```c
{disasm_for_reference}
```

**Procedure code for Reference**
```c
{procedure_for_reference}
```

This is the function you need to reverse-engineering:

**Disassembly to reverse-engineering**
```c
{disasm_code}
```

**Procedure code to reverse-engineering**
```c
{procedure}
```

What you need to do is to collect all references to "{symbol_name_list}" in the function you need to reverse-engineering and output those references as YAML.

Example:
```yaml
found_vcall: # This is for indirect call to virtual function or virtual function pointer fetching.
  - insn_va: '0x180777700' # Always be the instruction with displacement offset
    insn_disasm: call [rax+68h] # Always be the instruction with displacement offset
    vfunc_offset: '0x68'
    func_name: ILoopMode_OnLoopActivate
  - insn_va: '0x180777778' # Always be the instruction with displacement offset
    insn_disasm: mov rax, [rax+80h] # Always be the instruction with displacement offset
    vfunc_offset: '0x80'
    func_name: INetworkMessages_GetNetworkGroupCount

found_call: # This is for direct call to non-virtual regular function.
  - insn_va: '0x180888800'
    insn_disasm: call sub_180999900
    func_name: CLoopMode_RegisterEventMapInternal
  - insn_va: '0x180888880'
    insn_disasm: call sub_180555500
    func_name: CLoopMode_SetSystemState

found_funcptr: # This is for non-virtual regular function pointer.
  - insn_va: '0x180666600' # Must load/reference the function pointer target address
    insn_disasm: lea rdx, sub_15BC910 # Must load/reference the function pointer target address
    funcptr_name: CLoopMode_OnClientPollNetworking

found_gv: # This is for reference to global variable.
  - insn_va: '0x180444400'
    insn_disasm: mov rcx, cs:qword_180666600 # Must load/reference the global variable
    gv_name: g_pNetworkMessages
  - insn_va: '0x180333300'
    insn_disasm: lea rax, unk_180222200 # Must load/reference the global variable
    gv_name: s_EventManager

found_struct_offset: # This is for reference to struct offset. NOTE THAT virtual function pointer should not be here! virtual function pointer should ALWAYS be in found_vcall !
  - insn_va: '0x1801BA12A' # Always be the instruction with displacement offset
    insn_disasm: mov rcx, [r14+58h] # Always be the instruction with displacement offset
    offset: '0x58'
    size: 8
    struct_name: CResourceService
    member_name: m_pEntitySystem
```

If nothing found, output an empty YAML. DO NOT output anything other than the desired YAML. DO NOT collect unrelated symbols.
```

### Variable description

| Variable | Source | Description |
|------|------|------|
| `{disasm_for_reference}` | Legacy IDA export | Signed disassembly |
| `{procedure_for_reference}` | Legacy IDA export | Signed pseudocode |
| `{disasm_code}` | New version of IDA export | Unsigned disassembly |
| `{procedure}` | New version of IDA export | Unsigned pseudocode |
| `{symbol_name_list}` | Extracted from old version | List of symbols that need to be located in new version |

## Workflow

### Complete process

```text
Step 1: Prepare data
- Legacy binaries loaded into IDA (with PDB/symbols)
- New binary version loaded into IDA (unsigned)
- Find anchor functions (exported functions, string references, etc.) that are identical in both versions

Step 2: Batch export
- Export from old version: disassembly of anchor functions + pseudocode (with symbol names)
- Export from new version: disassembly + pseudocode (without symbolic name) of the same anchor function

Step 3: LLM comparison
- Fill data with prompt template
- Call LLM API (recommended: deepseek is large in quantity and cheap, and cuts gpt for very large functions)
- Parse the returned YAML

Step 4: Apply the results
- Batch apply symbol mapping in YAML to new version of IDB
- Batch rename using idapro_rename or IDAPython script

Step 5: Iterate
- The first round of migrated functions becomes the new anchor point
- Enter these functions and continue comparing internal calls
- Repeat until all objective functions are covered
```

### Anchor selection strategy

| Anchor Type | Reliability | Description |
|---------|--------|------|
| Export function | Highest | The name remains unchanged, but the address may change |
| String reference | High | The content of the string remains unchanged, but the reference position may change |
| Constant/magic number | Medium | Eigenvalues unchanged |
| Code mode | Medium | The function structure is similar but the address is completely changed |

### Batch processing suggestions

- Compare 1 function at a time (to avoid context explosion)
- Use deepseek for medium functions (<200 lines)
- Cut gpt-4o or claude for very large functions (>500 lines)
- Concurrent calls improve speed (10-20 concurrency)
- Result caching to avoid repeated calls

## Output format

### 5 symbol types output by YAML

| Type | Meaning | Key fields |
|------|------|---------|
| `found_vcall` | Virtual function call (indirect call) | `vfunc_offset`, `func_name` |
| `found_call` | Direct function call | `insn_va`, `func_name` |
| `found_funcptr` | Function pointer reference | `insn_va`, `funcptr_name` |
| `found_gv` | Global variable reference | `insn_va`, `gv_name` |
| `found_struct_offset` | Structure offset reference | `offset`, `struct_name`, `member_name` |

### Parsed application action

```text
found_call → idapro_rename(addr=call_target, name=func_name)
found_vcall → idapro_set_comments(addr=insn_va, comment="vcall: {func_name} @ +{offset}")
found_funcptr → idapro_rename(addr=funcptr_target, name=funcptr_name)
found_gv → idapro_rename(addr=gv_addr, name=gv_name)
found_struct_offset → idapro_set_comments(addr=insn_va, comment="{struct_name}.{member_name}")
```

## Typical scenario examples

### Scenario 1: ntoskrnl.exe is missing PDB

```text
Already have: ntoskrnl.exe 10.0.26100.2000 + full PDB
Target: ntoskrnl.exe 10.0.26100.2605 (PDB removed)
Requirement: Locate the new address of PspSetCreateProcessNotifyRoutine

step:
1. Load both versions into IDA
2. Find the exported function PsSetCreateProcessNotifyRoutine (both versions have it)
3. In the old version, it called PspSetCreateProcessNotifyRoutine (signed)
4. In the new version, it calls sub_140822108 (unsigned)
5. LLM at a glance: sub_140822108 = PspSetCreateProcessNotifyRoutine
6. Batch application
```

### Scenario 2: Migration after application update

```text
Already available: Complete reverse engineering results for target.exe v1.0 (200+ functions named)
Target: target.exe v1.1 (all symbols lost)
Requirement: Batch migration of 200 function names

step:
1. Export disassembly + pseudocode of all named functions from the old version
2. Find the corresponding anchor point by exporting functions/strings in the new version
3. Batch call LLM comparison
4. Parse YAML and rename in batches
5. Iterate and deepen
```

## LLM Selection Suggestions

| Model | Suitable Scenario | Cost | Speed |
|------|---------|------|------|
| DeepSeek V3 | Small and medium functions (<200 lines), batch processing | Extremely low | Fast |
| GPT-4o | Very large functions, complex control flow | Medium | Fast |
| Claude Sonnet | Medium to large functions, requiring reasoning | Medium | Fast |
| Claude Opus | Extremely complex functions that require deep understanding | High | Slow |

Recommended strategy: Default DeepSeek, automatically upgrade when context exceeds limits or results are inaccurate.

## Notes

- **Don't throw the entire binary to LLM** — compare only one function at a time
- **The anchor point must be reliable** — If the anchor point itself is right or wrong, all subsequent steps will be in vain.
- **Results require manual sampling** — LLM is not 100% accurate, key symbols need to be verified
- **Cache intermediate results** — avoid wasting tokens with repeated calls
- **Note context limitations** — Very large functions (>1000 lines of disassembly) need to be split or use a large context model

---

##On-Demand Bootstrap

### Tool dependencies

| Tools | Purpose | Automatic installation |
|------|------|-----------|
| IDA Pro | Export disassembly/pseudocode | ✗ (Commercial software) |
| Python | Script execution, API calling | ✓ |
| PyYAML | Parse the YAML returned by LLM | ✓ (pip install pyyaml) |
| LLM API | Perform comparison | API key required |

### illustrate

The core of this skill does not rely on heavy tool installation, but mainly relies on:
- IDA Pro already exists (managed with `ida-reverse/` skill)
- Python + requests/httpx (adjusting API)
- An LLM API endpoint

---

## Routing context

**Upstream entrance**: `references/README.md` (master control), `routing.md`
**Trigger condition**: There are old version symbols/reverse results and need to be migrated to the new version
**Downstream Export**:
- Need to open the binary first → `ida-reverse/`
- Requires quick recon to confirm version differences → `radare2/`

**Sibling association module**: `ida-reverse/` (data export and symbol application are both through IDA)


## Task completion self-test (MUST pass before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real toolpaths based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?