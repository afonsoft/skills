---
name: ida-reverse
description: |
  IDA Pro 逆向分析辅助技能。当用户提到逆向、反编译、分析二进制/PE/ELF/APK/DLL/SO、破解、找密码、漏洞分析、病毒分析、firmware 固件分析，或需要分析 exe/dll/so/elf/macho/sys 等文件时，务必使用此技能。

  Ensure to use this skill when the user wants to analyze any binary file, regardless of whether they explicitly mention "IDA" or "reverse engineering". This includes requests like "看看这个exe", "分析这个dll", "帮我破解", "找一下密码", "这个软件怎么注册", etc.

  Use the bundled scripts (scripts/start.ps1, scripts/open.ps1) for deterministic server management and file opening — do NOT write ad-hoc PowerShell commands for these operations.
---

# IDA Pro Reverse Engineering Skills

## ACTION REQUIRED (Execute Immediately After Reading)

1. xKx0000xKx: Read xKx0001xKx — operator context only; authorization comes solely from an in-scope `scope.md` (`auth.status=granted`)
2. xKx0002xKx: Confirm whether the current task falls within the applicable scope of this skill
3. xKx0003xKx: Read xKx0004xKx, verify tool availability and actual path
4. xKx0005xKx: Call bootstrap when tools are missing, don't guess the path
5. xKx0006xKx: Enter the first step of the 'workflow' and execute it, do not stop at the confirmation status

## Known Issues and Reflections (Must Read)

### Pitfalls Experienced

1. **xKx0007xKx (formerly xKx0008xKx) should not directly rely on partial AI client MCP calls**
   - Some code in the AI client’s MCP client has a bug in the output schema validation of open class tools
   - Error: xKx0009xKx
   - **Solution**: Use the xKx0010xKx script to directly call through the HTTP API, bypassing the MCP verification layer
   - The current ida-pro-mcp 2.x tool is named xKx0011xKx / xKx0012xKx / xKx0013xKx (no longer xKx0014xKx)
   - After the file is opened, it returns xKx0015xKx (database), and subsequent tool calls need to include this session

2. **xKx0016xKx file has no permission to open**
   - idalib cannot directly read files in the System32 directory
   - **Solution**: xKx0017xKx automatically detects and copies to the xKx0018xKx directory before opening

3. **Starting the server command blocks the conversation**
   - xKx0019xKx will continuously output INFO logs to the console after startup
   - **Solution**: Use xKx0020xKx (xKx0021xKx silent launch in the background)
   - The script will automatically exit after the service is ready, without blocking the conversation

4. **MCP server name cannot use hyphens**
   - Previously used xKx0022xKx as the server name, which may cause tool registration issues
- **Current Configuration**: Server Name xKx0023xKx, Tool Prefix xKx0024xKx

5. **Remote HTTP vs Local Stdio**
   - xKx0025xKx (stdio) mode: xKx0026xKx also has schema validation issues
   - xKx0027xKx (HTTP) mode: You can first open the file directly with a script, and then use the MCP tool
- **Current Plan**: Remote HTTP Mode

6. **PR #389 fixed some schema issues**
   - The author mrexodia merged the fix through PR #389 after issue #388
   - Fixed the structuredContent schema in HTTP mode, but some code still has validation issues on the AI client side
   - The latest xKx0028xKx branch version has been installed

7. **idalib timeout leaves orphaned worker process lock file**
   - After the first xKx0029xKx timeout, the Python worker subprocess of idalib may become an orphan, holding on to xKx0030xKx/xKx0031xKx/xKx0032xKx without letting go
   - Any subsequent tools or manual dragging into the IDA GUI will report 'Insufficient permissions'
   - **Prohibited** xKx0033xKx killing the process tree——xKx0034xKx will also take down the GUI xKx0035xKx subprocesses
   - **Solution**: xKx0036xKx only replaces the managed supervisor when no one is listening on the port, or when xKx0037xKx returns quickly but lacks xKx0038xKx (old supervisor); if RPC times out and 13337 is still listening, consider it busy and do not kill it. When opening the database, xKx0039xKx writes xKx0040xKx, and the watchdog must not xKx0041xKx
   - **Deadlock Exception**: xKx0042xKx **fails continuously for more than 3 minutes** (according to the last-healthy timestamp, not the process creation time), and only when there are no in-flight xKx0043xKx and it is not a GUI occupying the port, then xKx0044xKx replaces the supervisor, and still does not kill xKx0045xKx
- **Fallback**: xKx0046xKx detects that the old library is locked, automatically copies it to Temp, and adds a GUID prefix

8. **Opening with automatic analysis seems to freeze**
   - xKx0047xKx may not respond for a long time, but the backend is actually still running and analyzing
   - Previously, users saw 'PowerShell has no output,' which can easily be misinterpreted as the script being stuck
   - **Current solution**: xKx0048xKx added xKx0049xKx, and changed to backend request + frontend polling + periodic progress output
   - When polling, if the session is ready, it will return xKx0050xKx in advance; if it times out, it will return xKx0051xKx

9. **HTTP MCP will silently log out after login**
   - xKx0052xKx's xKx0053xKx will not start the process on its behalf; the old scheduled task only runs once at login
   - xKx0054xKx No console, and the Application log is empty when it crashes
   - **Solution**: xKx0055xKx reuse if healthy by default; xKx0056xKx inspect every minute; logs are in xKx0057xKx
   - Installation: xKx0058xKx. If the HTTP client starts before the port is up, you still need to manually refresh once in the MCP panel

10. **Streamable HTTP GET xKx0059xKx may hang the single-thread supervisor**
   - Some HTTP MCP clients will send long connection GET (SSE) requests to xKx0060xKx. Stock xKx0061xKx uses xKx0062xKx's xKx0063xKx, processing only one request at a time.
   - Result: xKx0064xKx timed out, the client marked xKx0065xKx as error
   - **Solution**: xKx0066xKx change HTTP to xKx0067xKx and accept GET xKx0068xKx; if the patch fails, skip and still start supervisor. When stuck, use xKx0069xKx (immediately xKx0070xKx)

### Workflow Principles

| Step | What to do | With what |
|------|--------|--------|
| 1 | Ensure the HTTP server is running | xKx0071xKx (no parameters) |
| 2 | Open the target binary file | xKx0072xKx |
| 3 | Use MCP analysis tool | Directly call xKx0073xKx / HTTP tools (about 65, depending on the version) |
| 4 | Analysis complete | Tool automatically available |

## Script Resources

### start.ps1 — Start MCP HTTP Server

Path: xKx0074xKx

- Automatically parse xKx0075xKx (environment variables / portable desktop path / common installation paths)
- Prefer using IDA's built-in xKx0076xKx
- By default, first probe xKx0077xKx, if healthy then output xKx0078xKx and exit
- 13337 Listening but xKx0079xKx timed out → xKx0080xKx / xKx0081xKx, **do not kill** (cannot respond when opening the library or GUI is occupied)
- xKx0082xKx **has failed continuously for more than 3 minutes** (last-healthy timestamp) and no xKx0083xKx → considered a deadlock, output xKx0084xKx and xKx0085xKx replaces supervisor. Ongoing xKx0086xKx and GUI will not follow this path
- Replace the managed supervisor only when the port is unmonitored, xKx0087xKx is missing, or in the deadlock situations mentioned above; **never kill xKx0088xKx, do not use xKx0089xKx**
- When the GUI occupies 13337, it outputs xKx0090xKx and exits, without starting another supervisor
- Output xKx0091xKx on success (currently about 66), output xKx0092xKx on failure
- supervisor log: xKx0093xKx
- The server runs in the background and does not block conversations

**Usage**:xKx0094xKx`
powershell -File "xKx0095xKx\xKx0096xKx"
```

### watchdog.ps1 / recover.ps1 / install-autostart.ps1 — Keep Alive

- `watchdog.ps1`: Detect 13337; health check reuse (and refresh last-healthy); GUI / `open.ps1` open library lock / busy of less than 3 minutes in last-healthy → reuse; only `tools/list` consecutive failures exceeding 3 minutes will `start.ps1 -Force`
- `recover.ps1`: immediately `start.ps1 -Force` (do not kill `ida.exe`). The HTTP client uses this when marking `idapro` as an error
- `install-autostart.ps1`: Register scheduled task `reverse-skill-ida-mcp` (login + every minute)
- Log: `%LOCALAPPDATA%\reverse-skill\ida-mcp\watchdog.log`

### open.ps1 — Open binary file

Path: `scripts/open.ps1`

- Directly call `idb_open` through the HTTP API, bypassing the MCP schema validation
- Automatically detect the System32 path and copy it to the temporary directory
- Automatically clean up old database files with the same name (`.id0`/`.id1`/`.nam`/`.til`/`.i64`)
- Automatic downgrade when the old library is locked: copy to Temp with a GUID prefix before opening, no error reported
- Execute the open request in the background to avoid script unresponsiveness caused by long synchronous waits
- Supports `-TimeoutSeconds`, returns `ERR:open_timeout_xxs` after a timeout, will not hang indefinitely
- Output `INFO:opening:已用时/超时秒数` every 10 seconds to facilitate determining if the analysis is still ongoing
- Successfully output `OK:文件名:session_id`, add `(temp copy)` marker during downgrade
- Automatically retry using the Temp copy on failure

**Usage**:```
powershell -File "<skill-root>\ida-reverse\scripts\open.ps1" -Path "C:\path\to\file.exe"
```

**Optional parameter**:```
# Specify SessionId
powershell -File "scripts\open.ps1" -Path "file.exe" -SessionId "my_session"

# Skip automatic analysis (recommended for large files)
powershell -File "scripts\open.ps1" -Path "large.exe" -NoAutoAnalysis

# Set a timeout to avoid long periods with no response during automatic analysis
powershell -File "scripts\open.ps1" -Path "file.exe" -TimeoutSeconds 600
```

**Output Convention**:```
# Analysis in progress (output every 10 seconds)
INFO:opening:11/600s

# Successfully Opened
OK:sample.exe:abcd1234

# Successfully opened, but downgraded to a Temp copy due to lock file
OK:1234abcd-sample.exe:abcd1234 (temp copy)

# Reached timeout limit
ERR:open_timeout_600s
```

**Test Results Explanation**:
- `Snipaste.exe` takes an actual measured time of about `324s` with automatic analysis to return successfully; it belongs to 'analysis takes a long time' rather than 'script deadlock'
- Therefore, when encountering GUI programs or more complex samples, it is recommended to explicitly set `-TimeoutSeconds 600` first.

## Core Tools List

### Overview Analysis (Step One)
- `idapro_survey_binary(detail_level="minimal")` — Quick Overview: Number of functions, strings, sections, entry points, import categories (Encryption/Network/File IO)
- `idapro_list_funcs(queries)` — List functions (pagination, filter by name)
- `idapro_list_globals(queries)` — List global variables
- `idapro_entity_query(kind, filter)` — Unified Query: functions/globals/imports/strings/names

### Decompilation and Disassembly
- `idapro_decompile(addr)` — Decompile to pseudocode
- `idapro_disasm(addr, max_instructions=N)` — Disassembly
- `idapro_analyze_function(addr, include_asm=false)` — Comprehensive Analysis (pseudocode + string + constants + caller + callee + block)
- `idapro_func_profile(queries)` — Function Summary Metrics

### Cross-References and Data Flow
- `idapro_xrefs_to(addrs)` — Check who referenced the target address
- `idapro_xref_query(addr, direction)` — Advanced xref query (direction/type filtering)
- `idapro_callees(addrs)` — List of subfunctions
- `idapro_callgraph(roots, max_depth)` — Call Diagram
- `idapro_trace_data_flow(addr, direction, max_depth)` — Data Flow Tracking (forward/backward)

### Search
- `idapro_find_regex(pattern, limit)` — Regular expression search string
- `idapro_search_text(pattern)` — Search text in the disassembly list
- `idapro_find_bytes(patterns, limit)` — Byte pattern search (supports ?? wildcard)
- `idapro_find(type, targets)` — Advanced Search (Immediate Value/String/Reference)

### Memory and Data
- `idapro_get_bytes(addrs)` — Read original bytes
- `idapro_get_string(addrs)` — Read String
- `idapro_get_int(queries)` — Read integer value
- `idapro_get_global_value(queries)` — Read global variable value
- `idapro_read_struct(queries)` — Reading struct field values
- `idapro_search_structs(filter)` — Search Struct

### Edit Operation
- `idapro_set_comments(items)` — Add comments (bi-directional synchronization of disassembly and decompilation)
- `idapro_append_comments(items)` — Add comment
- `idapro_rename(batch)` — Batch Rename (Functions/Global/Local/Stack Variables)
- `idapro_patch_asm(items)` — Patch Assembly Instruction
- `idapro_patch(patches)` — Patch Byte
- `idapro_define_func(items)` — Define function
- `idapro_undefine(items)` — Undefined
- `idapro_define_code(items)` — Convert bytes to code

### Type System
- `idapro_declare_type(decls)` — Declare C struct/enum/union
- `idapro_set_type(edits)` — Apply type to function/global/local
- `idapro_infer_types(addrs)` — Inferred Type
- `idapro_type_query(queries)` — Query Declared Type
- `idapro_type_inspect(queries)` — View type details

### Stack Frame
- `idapro_stack_frame(addrs)` — View stack frame variables
- `idapro_declare_stack(items)` — Declare stack variable
- `idapro_delete_stack(items)` — Delete stack variable

### Signature
- `idapro_make_signature(addrs)` — Generate a unique byte signature for the address
- `idapro_make_signature_for_function(addrs)` — Generate a signature for a function
- `idapro_find_xref_signatures(addrs)` — Generate a signature for the referenced address code

### Debugger (requires ?ext=dbg)
- `idapro_open_file(file_path)` — Open file in GUI IDA instance
- The debugger tool is hidden by default and can be enabled via the URL parameter `?ext=dbg`

### Session Management (ida-pro-mcp 2.x)
- `idapro_idb_open` / HTTP `idb_open` — ⚠️ It is recommended to open with `open.ps1`
- `idapro_idb_list` / HTTP `idb_list` — List all sessions
- `idapro_idb_save` / HTTP `idb_save` — Save database
- Most analysis tools require the `database=<session_id>` parameter (the session output by open.ps1)

### Others
- `idapro_int_convert(inputs)` — Base conversion (**You must use this, do not calculate the base yourself!**)
- `idapro_export_funcs(addrs, format)` — export function (json/c_header/prototypes)
- `idapro_py_eval(code)` — Execute Python in the context of IDA
- `idapro_server_health()` — Server Health Check
- `idapro_server_warmup()` — Preheating subsystem (string cache, Hex-Rays, etc.)

## Complete Workflow of Reverse Analysis

### Step 1: Start the server

**Path A — Headless idalib (requires a valid license)**```
powershell -File "scripts/start.ps1"
```Output `OK:<工具数>` (currently about 65) indicates readiness.

**Path B — GUI + Plugin (when idalib license fails or interactive analysis is needed)**```
powershell -File "scripts/start-gui.ps1" -Path "C:\目标.exe"
```Or double-click the portable version `Launch-IDA-Pro.cmd` to open the sample in IDA.

Once '`[MCP] ... port=13337`' appears in the Output window, the MCP tool is ready to use.

The general docking steps can be found in `LOCAL-SETUP.md`.

### Step 2: Open the file

Headless：
```
powershell -File "scripts/open.ps1" -Path "C:\目标.exe" -TimeoutSeconds 600
```Output `OK: Filename: session_id` indicates success (followed by ` (temp copy)` indicating automatic fallback to a temporary copy).

If `ERR:idalib_license:...` appears, switch to path B (GUI mode), and do not repeatedly retry open.ps1.

GUI mode: You can directly open the sample in IDA, no need for open.ps1.

### Step 3: Global Overview (Including Import Table Hard Gate)```
idapro_survey_binary(detail_level="minimal")
```Follow:
- Architecture (x86/x64/ARM)
- Entry point (main/WinMain/DllMain)
- Interesting strings (URL, path, error messages)
- **Import Categories (MUST)**: encryption functions / network APIs / file operations / process injection / registry — must be supported by Evidence (recommended id: `E-imports`), can use `idapro_entity_query(kind="imports")` or the imports section from the survey output
- **DLL/SYS**: The export table and the import table are listed side by side (Evidence `E-exports`)
- **.NET**: When there is no traditional IAT, use module/metadata/managed reference summaries as equivalent anchors to write into E-imports semantic slots
- **Clean import table**: indicate suspicion of dynamic loading and facilitate dynamic API breakpoint verification
- Hot functions (functions with high xref counts are usually key logic)

**Hard Access Control**: Before writing the imports view/category summary (or a legally equivalent anchor) into Evidence, you MUST NOT proceed to Step 4 to further analyze conclusions, and MUST NOT claim that the survey is complete. When the import table is empty or the query fails, you still MUST record the failure phenomena. When shell-wrapped IAT repair fails, you MUST record `E-iat-repair-fail` and switch to dynamic debugging to capture the API; static stubborn attempts are prohibited. When the user requests to redo the import table/IAT check, you MUST redo the specified steps (if blocked, feasibility latch: explanation + confirmation; if forced, mark quality=unreadable), and changing to unrelated steps is prohibited.

### Step 4: Dive Into Key Functions```
idapro_analyze_function(addr="key function name")
```Or:```
idapro_decompile(addr="function_name")
idapro_disasm(addr="function_name", max_instructions=50)
```

### Step 5: Data Flow and Cross-References```
idapro_xrefs_to(addrs="key address/string")
idapro_callgraph(roots=["key functions"], max_depth=3)
idapro_trace_data_flow(addr="key address", direction="backward", max_depth=5)
```

### Step 6: Record and Optimize```
idapro_set_comments(items=[{"addr": "0x140001000", "comment": "Your understanding"}])
idapro_rename(batch={"func": [{"addr": "function address", "name": "meaningful name"}]})
```

### Step 7: Output Report
After the analysis is complete, generate `report.md` records of findings and steps.

## Prompt Engineering Guidelines

1. **Do not manually calculate bases** — Whenever you need to convert numbers, use `idapro_int_convert`
2. **Survey first, then delve deeper** — look at the overview first, then conduct targeted analysis
3. **Continuously add comments and rename** — Continuously update function names and variable names during the analysis process to improve the accuracy of subsequent analysis
4. **Track Cross-References** — When you find interesting data/strings, use `xrefs_to` to see who referenced it
5. **When encountering obfuscated code** — first perform string decryption, hash removal import, control flow flattening removal, and other preprocessing
6. **C++ STL Code** — After identifying library functions with FLIRT/Lumina, analyze the business logic
7. **Do not crack violently** — Analysis should derive the solution from disassembly, using simple Python for auxiliary calculations
8. **Encountering 'No database bound'** — No binary file has been opened yet, execute `open.ps1` first
9. **Encountering 'Failed to open database'** — it may be that the old database file is locked. `open.ps1` will automatically downgrade to a Temp copy (output contains `(temp copy)` marker)
10. **When opening GUI/complex samples with automatic analysis** — by default add `-TimeoutSeconds 600`, do not mistakenly judge long `INFO:opening:...` as a script freeze

---

## Routing Context

**Upstream Input**: `references/README.md` (Main Control), `routing.md`
**Upstream Candidate**: `radare2/` (if you don't want to open IDA, you can quickly scout with r2 first)
**Downstream Exports**:
- Requires Frida dynamic verification → `reverse-engineering/tools-dynamic.md`
- Requires symbolic execution/angr → `reverse-engineering/tools-dynamic.md`
- A general reverse engineering methodology is required → `reverse-engineering/README.md`

**Peer-related module**: `radare2/` (alternative when IDA is unavailable)

---

## On-Demand Bootstrap

The entry script of this skill has been integrated into the unified bootstrap system.

### Automation Capability Boundaries

| Tool | Can be installed automatically | Installation method | Description |
|------|-----------|---------|------|
| idalib-mcp | ✓ | pip install (from GitHub) | Automatically install when `start.ps1` is missing |
| IDA Pro | ✗ | Commercial software, requires manual installation | Set the `IDADIR` environment variable to point to the installation directory |

### Installation Steps (Verified)

```cmd# 1. Set the IDA path (replace with your actual IDA installation directory)
setx IDADIR "<Your IDA installation directory>"

# 2. Install ida-pro-mcp from GitHub (ida-mcp on PyPI is another project, don’t install the wrong one!)
pip install git+xKx0000xKx

# 3. Install the IDA plugin (select Streamable HTTP + Global + select all clients)
ida-pro-mcp --install

# 4. Restart IDA Pro and open the target file
# Plugin automatically listens on 127.0.0.1:13337

# 5. Verification
ida-pro-mcp --config
```

> ⚠️ **Note**: The `ida-mcp` package on PyPI (author jtsylve) is another project, not the one we need.
> `mrexodia/ida-pro-mcp` must be installed from GitHub.

### Bootstrap Trigger Point

- `scripts/start.ps1`: Automatically call `bootstrap-reverse.ps1` when `idalib-mcp` is missing
- MCP Registration: bootstrap will automatically write `idapro` into the Claude MCP configuration

### Prerequisites

- IDA Pro is installed and the `IDADIR` environment variable is set (or the default path in the script is correct)
- It is recommended to use `ida-pro-mcp` from Python314 included with IDA (portable version is already built-in)
- Common native configuration:
  - User env `IDADIR` → IDA installation directory (including `ida.exe`)
  - Optional `~\Tools\bin\idalib-mcp.cmd` / `ida-pro-mcp.cmd` Wrapper
  - Client MCP server name changed from `idapro` to `http://127.0.0.1:13337/mcp`


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I carry out every step in the workflow (rather than just reading)?
- [ ] Has survey/imports been entered into Evidence (E-imports or equivalent)? DLL/SYS does it contain E-exports? Does IAT failure record E-iat-repair-fail?
- [ ] If the user requests to redo the import table/IAT, is the same step redone?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?