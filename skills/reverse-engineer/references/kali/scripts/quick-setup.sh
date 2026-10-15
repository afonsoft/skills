#!/usr/bin/env bash
# quick-setup.sh — Kali 2026.1 one-click initialization
# Run this script on a fresh Kali system to do it automatically:
# 1. System update
# 2. Install Kali 2026.1 new tools
# 3. Configure Kali native MCP
# 4. Install non-preinstalled reverse engineering tools
# 5. Refresh tool index
# 6. Output configuration report
#
# usage:
#   sudo bash kali/scripts/quick-setup.sh [--skip-update] [--minimal]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Parameters ──────────────────────────────────────────────────────────────────

SKIP_UPDATE=false
MINIMAL=false

for arg in "$@"; do
    case "$arg" in
        --skip-update) SKIP_UPDATE=true ;;
        --minimal) MINIMAL=true ;;
    esac
done

# ───Color ────────────────────────────────────────────────────────────────

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
BOLD='\033[1m'
RESET='\033[0m'

banner() { echo -e "\n${BOLD}${CYAN}═══ $* ═══${RESET}\n"; }
ok() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn() { echo -e "${YELLOW}[!]${RESET} $*"; }
info() { echo -e "${CYAN}[i]${RESET} $*"; }

# ─── Check permissions ───────────────────────────────────────────────────────────────

if [[ $EUID -ne 0 ]]; then
    echo "请使用 root 权限运行: sudo bash $0"
    exit 1
fi

# ─── Check Kali version ───────────────────────────────────────────────────────────

banner "检查系统版本"

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    info "系统: $PRETTY_NAME"
    info "版本: ${VERSION:-unknown}"
    info "内核: $(uname -r)"
else
    warn "无法检测系统版本，继续执行..."
fi

# ─── System update ───────────────────────────────────────────────────────────────

if [[ "$SKIP_UPDATE" != "true" ]]; then
    banner "系统更新"
    apt-get update -qq
    apt-get upgrade -y -qq
    ok "系统已更新"
else
    info "跳过系统更新 (--skip-update)"
fi

# ─── Install Kali 2026.1 new tools ──────────────────────────────────────────────────

banner "安装 Kali 2026.1 新工具"

NEW_TOOLS_2026_1=(
    "adaptixc2"
    "atomic-operator"
    "fluxion"
    "gef"
    "metasploitmcp"
    "sstimap"
    "wpprobe"
    "xsstrike"
)

NEW_TOOLS_2025_4=(
    "evil-winrm-py"
    "hexstrike-ai"
)

for tool in "${NEW_TOOLS_2026_1[@]}" "${NEW_TOOLS_2025_4[@]}"; do
    if dpkg -l "$tool" &>/dev/null 2>&1; then
        ok "$tool 已安装"
    else
        info "安装 $tool ..."
        apt-get install -y -qq "$tool" 2>/dev/null && ok "$tool 安装成功" || warn "$tool 安装失败（可能尚未在你的源中）"
    fi
done

# ─── Install Kali native MCP ──────────────────────────────────────────────────────

banner "配置 Kali 原生 MCP"

MCP_TOOLS=("mcp-kali-server" "metasploitmcp" "hexstrike-ai")

for tool in "${MCP_TOOLS[@]}"; do
    if dpkg -l "$tool" &>/dev/null 2>&1; then
        ok "$tool 已安装"
    else
        info "安装 $tool ..."
        apt-get install -y -qq "$tool" 2>/dev/null && ok "$tool 安装成功" || warn "$tool 安装失败"
    fi
done

# ─── Install AD/intranet penetration tools ────────────────────────────────────────────────────

if [[ "$MINIMAL" != "true" ]]; then
    banner "安装 AD/内网渗透工具"

    AD_TOOLS=("coercer" "netexec" "responder" "bloodhound" "certipy-ad")

    for tool in "${AD_TOOLS[@]}"; do
        if dpkg -l "$tool" &>/dev/null 2>&1; then
            ok "$tool 已安装"
        else
            info "安装 $tool ..."
            apt-get install -y -qq "$tool" 2>/dev/null && ok "$tool 安装成功" || warn "$tool 安装失败"
        fi
    done
fi

# ─── Install non-preinstalled reverse engineering tools ───────────────────────────────────────────────────────

banner "安装逆向分析工具"

# jadx (Kali is not pre-installed, download from GitHub)
if ! command -v jadx &>/dev/null; then
    info "安装 jadx（从 GitHub Release）..."
    bash "$SCRIPT_DIR/bootstrap-reverse.sh" jadx --skip-refresh 2>/dev/null && ok "jadx 安装成功" || warn "jadx 安装失败"
else
    ok "jadx 已可用"
fi

# Node.js (required for some MCPs)
if ! command -v node &>/dev/null; then
    info "安装 Node.js ..."
    apt-get install -y -qq nodejs npm && ok "Node.js 安装成功" || warn "Node.js 安装失败"
else
    ok "Node.js 已可用: $(node -v)"
fi

# frida-tools
if ! command -v frida &>/dev/null; then
    info "安装 frida-tools ..."
    pip3 install --break-system-packages frida-tools 2>/dev/null && ok "frida-tools 安装成功" || warn "frida-tools 安装失败"
else
    ok "frida 已可用"
fi

# ─── Configure MCP client ───────────────────────────────────────────────────────────

banner "配置 MCP 客户端"

# Detect the actual user ($HOME under sudo may be /root)
REAL_USER="${SUDO_USER:-root}"
REAL_HOME="$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6 || true)"
if [[ -z "$REAL_HOME" || ! -d "$REAL_HOME" ]]; then
    REAL_USER="root"
    REAL_HOME="$(getent passwd root 2>/dev/null | cut -d: -f6 || true)"
fi
if [[ -z "$REAL_HOME" || ! -d "$REAL_HOME" ]]; then
    REAL_HOME="/root"
fi

MCP_CONFIG_DIR="$REAL_HOME/.claude"
MCP_CONFIG="$MCP_CONFIG_DIR/mcp.json"

if command -v jq &>/dev/null; then
    mkdir -p "$MCP_CONFIG_DIR"

    if [[ ! -f "$MCP_CONFIG" ]]; then
        echo '{"mcpServers":{}}' > "$MCP_CONFIG"
    fi

    # Register kali-server
    jq '.mcpServers["kali-server"] = {"command": "kali-server-mcp", "args": ["--port", "5000"]}' "$MCP_CONFIG" > /tmp/mcp-tmp.json && mv /tmp/mcp-tmp.json "$MCP_CONFIG"

    # Register metasploit-mcp
    jq '.mcpServers["metasploit-mcp"] = {"command": "metasploitmcp", "args": ["--transport", "stdio"]}' "$MCP_CONFIG" > /tmp/mcp-tmp.json && mv /tmp/mcp-tmp.json "$MCP_CONFIG"

    # Register hexstrike
    jq '.mcpServers["hexstrike"] = {"command": "hexstrike-ai", "args": []}' "$MCP_CONFIG" > /tmp/mcp-tmp.json && mv /tmp/mcp-tmp.json "$MCP_CONFIG"

    # Register jshook
    jq '.mcpServers["jshook"] = {"command": "npx", "args": ["-y", "@jshookmcp/jshook@0.3.4"], "env": {"JSHOOK_BASE_PROFILE": "search"}}' "$MCP_CONFIG" > /tmp/mcp-tmp.json && mv /tmp/mcp-tmp.json "$MCP_CONFIG"

    chown "$REAL_USER:$REAL_USER" "$MCP_CONFIG" "$MCP_CONFIG_DIR"
    ok "MCP 配置已写入: $MCP_CONFIG"
else
    warn "未安装 jq，无法自动配置 MCP。请手动复制 kali/mcp-kali-example.json"
    info "安装 jq: apt install jq"
fi

# ─── Refresh tool index ─────────────────────────────────────────────────────────────

banner "刷新工具索引"

chmod +x "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR"/lib/*.sh
sudo -u "$REAL_USER" bash "$SCRIPT_DIR/refresh-tool-index.sh" 2>/dev/null || bash "$SCRIPT_DIR/refresh-tool-index.sh"
ok "工具索引已刷新"

# ─── Output report ───────────────────────────────────────────────────────────────

banner "配置完成"

echo -e "${BOLD}✅ Kali 2026.1 逆向技能路由包已配置完成${RESET}"
echo ""
echo "  安装路径: $(cd "$SCRIPT_DIR/../.." && pwd)"
echo "  MCP 配置: $MCP_CONFIG"
echo "  工具索引: $(cd "$SCRIPT_DIR/../.." && pwd)/tool-index.md"
echo ""
echo "Kali native MCP:"
command -v kali-server-mcp &>/dev/null && echo "    ✓ mcp-kali-server" || echo "    ✗ mcp-kali-server"
command -v metasploitmcp &>/dev/null && echo "    ✓ metasploitmcp" || echo "    ✗ metasploitmcp"
command -v hexstrike-ai &>/dev/null && echo "    ✓ hexstrike-ai" || echo "    ✗ hexstrike-ai"
echo ""
echo "2026.1 New tools:"
for tool in "${NEW_TOOLS_2026_1[@]}"; do
    if dpkg -l "$tool" &>/dev/null 2>&1; then
        echo "    ✓ $tool"
    else
        echo "    ✗ $tool"
    fi
done
echo ""
echo "Next step:"
echo "1. Tell your AI client to read kali/RULES-kali.md"
echo "2. Or ask AI directly: 'Read kali/RULES-kali.md and execute the configuration'"
echo "3. Security/reverse tasks will be automatically routed later."
echo ""
