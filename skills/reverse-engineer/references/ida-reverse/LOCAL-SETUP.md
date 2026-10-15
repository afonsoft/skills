# IDA ↔ reverse-skill integration (portable)

This page contains general steps and does not include the absolute path of any specific machine. The readiness report for this machine is kept in the repository root directory `LOCAL-READINESS.md` (already gitignored).

## Target Form

| Item | Agreement |
|----|------|
| IDA installation directory | Environment variable `IDADIR` (contains `ida.exe` or `ida.dll` inside the directory) |
| HTTP MCP | `http://127.0.0.1:13337/mcp` |
| Client server name | Only keep **`idapro`** (do not register `ida-pro-mcp` at the same time) |
| Startup | `scripts/start.ps1` (`--unsafe`, no `?ext=dbg`) |
| Open library | Large files take priority `scripts/open.ps1`, do not directly access `idb_open` from some clients |

Two MCP names pointing to the same 13337 will register the tool twice and compete with the idalib worker for the port.

## Installation

```powershell
setx IDADIR "<你的 IDA 安装目录>"

# You must use mrexodia/ida-pro-mcp, do not install ida-mcp from PyPI
python -m pip install "git+https://github.com/mrexodia/ida-pro-mcp.git"

# Activate idalib (adjust the path according to your local IDA)
python "<IDADIR>\idalib\python\py-activate-idalib.py" -d "<IDADIR>"

# Install Plugins + Client Configuration
python -m ida_pro_mcp --install --transport streamable-http --scope global
```

## Startup and Keep-Alive

The MCP entry of `type: http` will not automatically start the process. When 13337 is not listening, all clients report an error.

| Script | Function |
|------|------|
| `scripts/start.ps1` | If healthy, `OK:<n>:reuse` and refresh last-healthy; port is listening but RPC timeout is considered busy, do not kill; only replace managed supervisor when no one is listening, `py_eval` is missing, or tools/list fails continuously for more than 3 minutes (and no `opening.lock`); never kill `ida.exe` |
| `scripts/watchdog.ps1` | Inspect every minute; healthy reuse; GUI / `open.ps1` Open library lock / last-healthy less than 3 minutes → reuse; **tools/list Continuous failure for more than 3 minutes only then `-Force`** |
| `scripts/recover.ps1` | Immediately `-Force` restart supervisor (without killing `ida.exe`). HTTP clients use this when marking `idapro` as error |
| `scripts/install-autostart.ps1` | Register scheduled task `reverse-skill-ida-mcp` (login + every minute) |
| `scripts/start-gui.ps1` | Open GUI plugin when idalib license fails |
| `scripts/open.ps1` | HTTP direct call `idb_open`, bypassing part of client schema validation |

Log: `%LOCALAPPDATA%\reverse-skill\ida-mcp\supervisor.log` and `watchdog.log`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "references\ida-reverse\scripts\start.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "references\ida-reverse\scripts\open.ps1" -Path "C:\path\to\target.exe" -TimeoutSeconds 600
powershell -NoProfile -ExecutionPolicy Bypass -File "references\ida-reverse\scripts\install-autostart.ps1"
```

When the GUI occupies 13337 but does not receive a response for a while, xKx0000xKx outputs xKx0001xKx and exits to avoid killing the IDA that is being analyzed.

## Client

All point to Streamable HTTP: xKx0002xKx, server name xKx0003xKx.

After changing the configuration, a new session must be started. If the cursor's port is not listening at startup, bringing up the service afterward **will not automatically reconnect**, and you need to manually refresh it in the MCP panel.

## Known Points to Note

1. System32 file: `open.ps1` will be copied to a temporary path (output with `(temp copy)`)
2. `idb_open` Do not go through some client MCP directly
3. `start.ps1` is preferred over `python -m ida_pro_mcp.idalib_supervisor`, and is more stable than `.cmd` packaging
4. When the official installation coexists with the portable desktop package, `IDADIR` shall prevail.
5. Do not add `?ext=dbg` (the debugger tool is not exposed by default)