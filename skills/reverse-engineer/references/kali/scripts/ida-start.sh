#!/usr/bin/env bash
# ida-start.sh — Starts the IDA Pro MCP HTTP service (Linux version)
# Equivalent to Windows version of ida-reverse/scripts/start.ps1

set -euo pipefail

# ───Configuration (modify according to your actual installation) ────────────────────────────────────────────────

IDADIR="${IDADIR:-/opt/idapro}"
MCP_PORT="${IDA_MCP_PORT:-13337}"

# idalib-mcp executable file path (usually in PATH after pip install)
MCP_SERVER_CMD="${IDA_MCP_SERVER:-ida-pro-mcp}"

# ─── Inspection ─────────────────────────────────────────────────────────────────

if [[ ! -d "$IDADIR" ]]; then
    echo "ERR: IDADIR 不存在: $IDADIR"
    echo "Please set the environment variable IDADIR to point to the IDA Pro installation directory"
    exit 1
fi

if ! command -v "$MCP_SERVER_CMD" &>/dev/null; then
    echo "ERR: $MCP_SERVER_CMD 未找到"
    echo "Please run first: pip3 install git+https://github.com/mrexodia/ida-pro-mcp.git"
    exit 1
fi

# ─── Kill the old process ─────────────────────────────────────────────────────────────

pkill -f "ida-pro-mcp" 2>/dev/null || true
sleep 1

# ─── Start the service ────────────────────────────────────────────────────────────────

echo "INFO: 启动 IDA MCP HTTP 服务 (port $MCP_PORT) ..."
export IDADIR

nohup "$MCP_SERVER_CMD" --port "$MCP_PORT" > /tmp/ida-mcp.log 2>&1 &
MCP_PID=$!

# ─── Waiting for ready ──────────────────────────────────────────────────────────────

TIMEOUT=45
ELAPSED=0

while [[ $ELAPSED -lt $TIMEOUT ]]; do
    if nc -z 127.0.0.1 "$MCP_PORT" 2>/dev/null; then
        echo "OK: IDA MCP 服务已就绪 (PID=$MCP_PID, port=$MCP_PORT)"
        exit 0
    fi
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

echo "ERR: 超时 ${TIMEOUT}s，服务未就绪"
echo "Check the log: /tmp/ida-mcp.log"
exit 1
