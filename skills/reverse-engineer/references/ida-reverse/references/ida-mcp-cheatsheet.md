#IDA Pro MCP tool quick review

> ida-pro-mcp 2.x tools are classified by function, with common parameters and typical usage.
> Server name: `idapro`, tool prefix: `idapro_*`, running in HTTP mode. Number of tools varies with version (~66 including `py_eval`).

---

## Startup and session management

### Server startup

```powershell
# Start the MCP HTTP server (background silent; healthy if OK:<n>:reuse)
powershell -File "scripts/start.ps1"
# Output OK:<number of tools> indicates ready (about 66, including py_eval)

# Open the target file (bypass schema validation)
powershell -File "scripts/open.ps1" -Path "C:\target.exe"
# Output OK:filename:session_id

# It is recommended to add a timeout for large files/GUI programs
powershell -File "scripts/open.ps1" -Path "C:\big.exe" -TimeoutSeconds 600

# Skip automatic analysis (quick open)
powershell -File "scripts/open.ps1" -Path "C:\huge.sys" -NoAutoAnalysis
```

### Conversation Tools

| Tools | Usage | Examples |
|------|------|------|
| `idapro_idb_list()` / HTTP `idb_list` | List all sessions | — |
| `idapro_idb_open()` / HTTP `idb_open` | Open the database (`open.ps1` is preferred) | script for large files |
| `idapro_idb_save(path)` / HTTP `idb_save` | Save database | Save analysis progress |
| `idapro_idb_current()` | The currently bound session (if provided by the version) | — |
| `idapro_idb_switch(session_id)` | Switch session | When comparing multiple files |
| `idapro_idb_close(session_id)` | Close session | Release resources |
| `idapro_server_health()` | Server health check | — |
| `idapro_server_warmup()` | Preheating subsystem | Before first use |

---

## Step One: Global Overview

### survey_binary — quick overview

```
idapro_survey_binary(detail_level="minimal")
```

return:
- Architecture (x86/x64/ARM/MIPS)
- entry point
-Total number of functions
- String statistics
- Segment information
- Import categories (encryption/network/file IO/registry)
- High xref popular functions

**detail_level option**:
- `"minimal"` — Quick overview (recommended first choice)
- `"standard"` — contains more details
- `"full"` — full information

### Function list

```
# List all functions (paginated)
idapro_list_funcs(queries=[{"offset": 0, "limit": 50}])

# Filter by name
idapro_list_funcs(queries=[{"filter": "crypt", "offset": 0, "limit": 20}])
idapro_list_funcs(queries=[{"filter": "main", "offset": 0, "limit": 10}])
```

### Unified query

```
# Query imported functions
idapro_entity_query(kind="imports", filter="Create")

# Query string
idapro_entity_query(kind="strings", filter="http")

# Query all named symbols
idapro_entity_query(kind="names", filter="")
```

---

## Decompilation and disassembly

### Decompile (pseudocode)

```
# By function name
idapro_decompile(addr="main")
idapro_decompile(addr="sub_140001000")

# By address
idapro_decompile(addr="0x140001000")
```

### Disassembly

```
#Default number of instructions
idapro_disasm(addr="main")

# Specify the number of instructions
idapro_disasm(addr="0x401000", max_instructions=100)
```

### Comprehensive analysis (recommended)

```
# One-time acquisition: pseudocode + string + constant + caller + callee + basic block
idapro_analyze_function(addr="main", include_asm=false)

# Contains assembly
idapro_analyze_function(addr="sub_401000", include_asm=true)
```

### Function Summary

```
# Get function indicators in batches (size, number of blocks, number of xrefs)
idapro_func_profile(queries=["main", "sub_401000", "sub_402000"])
```

---

## Cross-reference and call graph

### Who cited the target

```
# Check who called a function
idapro_xrefs_to(addrs=["sub_401000"])

# Check who quoted a certain string/data
idapro_xrefs_to(addrs=["0x404000"])

# Batch query
idapro_xrefs_to(addrs=["CreateFileW", "ReadFile", "WriteFile"])
```

### Advanced xref query

```
# Specify direction and type
idapro_xref_query(addr="0x401000", direction="to") # Who quotes me
idapro_xref_query(addr="0x401000", direction="from") # Who do I quote?
```

### List of called functions

```
idapro_callees(addrs=["main"])
```

### Call graph

```
# Start at main, depth 3
idapro_callgraph(roots=["main"], max_depth=3)

# Multiple starting points
idapro_callgraph(roots=["sub_401000", "sub_402000"], max_depth=2)
```

### Data flow tracking

```
# Trace backward: where does this value come from?
idapro_trace_data_flow(addr="0x401050", direction="backward", max_depth=5)

# Trace forward: where does this value flow?
idapro_trace_data_flow(addr="0x401050", direction="forward", max_depth=5)
```

---

## search

### String search (regular)

```
# Search URL
idapro_find_regex(pattern="https?://", limit=20)

# Search file path
idapro_find_regex(pattern="C:\\\\", limit=20)

#Search for error messages
idapro_find_regex(pattern="error|fail|invalid", limit=30)

# Search key/password related
idapro_find_regex(pattern="key|password|secret|token", limit=20)
```

### Disassembly text search

```
# Search in the disassembly list
idapro_search_text(pattern="call    sub_")
idapro_search_text(pattern="xor     eax, eax")
```

### Byte pattern search

```
# Exact bytes
idapro_find_bytes(patterns=["48 8B 05"], limit=10)

# with wildcards
idapro_find_bytes(patterns=["48 89 ?? 24 ??"], limit=10)

#Multiple modes
idapro_find_bytes(patterns=["CC CC CC CC", "90 90 90 90"], limit=5)
```

### Advanced Search

```
#Search for immediate data
idapro_find(type="immediate", targets=["0xDEADBEEF"])

# Search string reference
idapro_find(type="string", targets=["password"])
```

---

## Memory and data reading

### Read raw bytes

```
idapro_get_bytes(addrs=[{"addr": "0x401000", "size": 64}])
```

### Read string

```
idapro_get_string(addrs=["0x404000", "0x404100"])
```

### Read integer

```
idapro_get_int(queries=[{"addr": "0x405000", "size": 4}])
```

### Read global variables

```
idapro_get_global_value(queries=["g_flag", "g_key_size"])
```

### Read structure

```
idapro_read_struct(queries=[{"addr": "0x405000", "type": "HEADER"}])
```

### Search structure

```
idapro_search_structs(filter="FILE")
```

---

## Modification operation

### Add comment

```
#Single comment
idapro_set_comments(items=[{"addr": "0x401000", "comment": "Decryption function entry"}])

# Batch comments
idapro_set_comments(items=[
{"addr": "0x401000", "comment": "XOR decryption loop"},
{"addr": "0x401050", "comment": "Key initialization"},
{"addr": "0x4010A0", "comment": "Result verification"}
])

#Append comments (do not overwrite existing ones)
idapro_append_comments(items=[{"addr": "0x401000", "comment": "Supplement: Key length 16"}])
```

### Rename

```
# Rename function
idapro_rename(batch={"func": [
    {"addr": "sub_401000", "name": "decrypt_payload"},
    {"addr": "sub_402000", "name": "verify_license"}
]})

# Rename global variables
idapro_rename(batch={"global": [
    {"addr": "0x405000", "name": "g_encryption_key"}
]})

# Rename local variables
idapro_rename(batch={"local": [
    {"func": "decrypt_payload", "old": "v1", "name": "plaintext_buf"}
]})
```

### Patch compilation

```
# NOP remove detection code
idapro_patch_asm(items=[{"addr": "0x401050", "asm": "nop"}])

#Modify jump
idapro_patch_asm(items=[{"addr": "0x401060", "asm": "jmp 0x401080"}])

# Force return true
idapro_patch_asm(items=[
    {"addr": "0x401000", "asm": "mov eax, 1"},
    {"addr": "0x401005", "asm": "ret"}
])
```

### Patch bytes

```
# Write bytes directly
idapro_patch(patches=[{"addr": "0x401050", "bytes": "9090909090"}])
```

---

## Type system

### Declare structure

```
idapro_declare_type(decls=[{
    "name": "PacketHeader",
    "decl": "struct PacketHeader { uint32_t magic; uint16_t type; uint16_t length; uint8_t data[0]; };"
}])
```

### Application type

```
# Set prototype for function
idapro_set_type(edits=[{
    "addr": "sub_401000",
    "type": "int __fastcall decrypt(void *buf, int size, const char *key)"
}])

# Set the type for global variables
idapro_set_type(edits=[{
    "addr": "0x405000",
    "type": "PacketHeader"
}])
```

### Inferred type

```
idapro_infer_types(addrs=["sub_401000", "sub_402000"])
```

### Query/View Type

```
idapro_type_query(queries=["Packet"])
idapro_type_inspect(queries=["PacketHeader"])
```

---

## Stack frame analysis

```
# View function stack frame
idapro_stack_frame(addrs=["main", "sub_401000"])

# Declare stack variables
idapro_declare_stack(items=[{
    "func": "sub_401000",
    "offset": -0x20,
    "name": "local_buf",
    "type": "char [32]"
}])
```

---

## Signature generation

```
# Generate a unique byte signature for the address
idapro_make_signature(addrs=["0x401000"])

# Generate a signature for the entire function
idapro_make_signature_for_function(addrs=["decrypt_payload"])

# Generate a signature for code that references an address
idapro_find_xref_signatures(addrs=["0x405000"])
```

---

## Base conversion

```
# hexadecimal → decimal
idapro_int_convert(inputs=["0x401000"])

# decimal → hexadecimal
idapro_int_convert(inputs=["4198400"])

# Batch conversion
idapro_int_convert(inputs=["0xDEAD", "0xBEEF", "12345"])
```

> ⚠️ **Always use this tool for base conversion, don’t do the math yourself! **

---

## Export and script

### Export function

```
# JSON format
idapro_export_funcs(addrs=["main", "sub_401000"], format="json")

# C header file
idapro_export_funcs(addrs=["main", "sub_401000"], format="c_header")

# Function prototype
idapro_export_funcs(addrs=["main", "sub_401000"], format="prototypes")
```

### Execute Python script

```
# Execute Python in IDA context
idapro_py_eval(code="import idautils; print(list(idautils.Functions())[:10])")

# Get segment information
idapro_py_eval(code="import idc; print(idc.get_segm_name(0x401000))")

# Batch operations
idapro_py_eval(code="import ida_funcs; f=ida_funcs.get_func(0x401000); print(f.size())")
```

---

## Typical analysis process

### Malware Analysis

```text
1. survey_binary → see import (network API? encryption? registry?)
2. find_regex("http|socket|connect") → Find network-related strings
3. xrefs_to (network string address) → find reference function
4. decompile (reference function) → see communication logic
5. trace_data_flow(encryption parameter, "backward") → trace the source of the key
6. set_comments + rename → mark discovery
```

### Registration verification crack

```text
1. find_regex("serial|license|register|valid") → Find verification related strings
2. xrefs_to(verification string) → locate verification function
3. analyze_function (verification function) → understand the logic
4. callgraph(verification function, 2) → see call chain
5. patch_asm(conditional jump address, "jmp always_pass") → patch
```

### CTF reverse

```text
1. survey_binary → Confirm structure and entry
2. decompile("main") → look at the main logic
3. find_regex("flag|correct|wrong") → Find the judgment point
4. trace_data_flow(judgment point, "backward") → trace input transformation
5. Use Python to assist calculation/decryption → get flag
```

### Vulnerability Analysis

```text
1. entity_query(kind="imports", filter="strcpy|sprintf|gets") → Find dangerous functions
2. xrefs_to (dangerous function) → find the call point
3. analyze_function (function where the call point is located) → see context
4. stack_frame(function) → confirm buffer size
5. trace_data_flow(danger parameter, "backward") → Confirm user control
```

---

## Common errors and solutions

| Error | Cause | Solution |
|------|------|------|
| "No database bound" | No file opened | Execute `open.ps1` |
| "Failed to open database" | The old database is locked | `open.ps1` automatically downgraded to Temp |
| Schema verification failed | MCP client BUG | Use `open.ps1` instead of `idb_open` |
| Tool timeout | Large file analysis | Add `-TimeoutSeconds 600` |
| "ERR:timeout" (start.ps1) | Server startup failed | Check Python/idalib-mcp installation |
| Base conversion error | Manual calculation error | Use `idapro_int_convert` |
| Function name not found | Name is inaccurate | Use `list_funcs` + filter to search first |