#!/usr/bin/env bash
# install-rea.sh — install, register and diagnose REA (rea-agents) for AI agents.
#
# REA is a local-only reverse-engineering CLI + MCP server (npm: rea-agents).
# This helper is a thin wrapper around the official commands:
#   npx -y rea-agents@latest setup      # interactive: pick agents, review plan, approve
#   npx -y rea-agents@latest doctor     # read-only readiness diagnosis
#   npm install --global rea-agents     # persistent `rea` CLI
#
# It never installs Node.js, npm, or analysis engines (Ghidra/IDA/Hopper/Binwalk).
# `setup` previews every file it will write and requires your approval.
#
# Usage:
#   install-rea.sh                       # interactive setup via npx (recommended)
#   install-rea.sh --client devin        # setup for one agent only
#   install-rea.sh --client devin --client cursor --yes   # non-interactive, explicit scope
#   install-rea.sh --dry-run             # preview the plan, change nothing
#   install-rea.sh --global              # npm i -g rea-agents (persistent `rea` CLI)
#   install-rea.sh --check               # doctor --json: full readiness report
#   install-rea.sh --check --client devin
#   install-rea.sh --check --provider ghidra   # or hopper | ida
#   install-rea.sh --print-manual        # show manual MCP registration snippets
#   install-rea.sh --version 6.5.0 ...   # pin the package version (default: latest)
#
# Supported --client IDs (REA registry): claude_code claude_desktop codex cursor
#   gemini_cli windsurf devin opencode antigravity copilot_cli commandcode
#   qwen_code kimi vscode grok_build omp pi hermes qoder droid trae workbuddy
#   zcode dsh
set -euo pipefail

PKG="rea-agents"
VERSION="latest"
MODE="setup"          # setup | doctor | global | manual
CLIENTS=()
PROVIDER=""
YES=0
DRY_RUN=0
SKILL_FLAG=""

usage() { sed -n '2,32p' "$0"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --client)      CLIENTS+=("${2:?--client needs an id}"); shift 2 ;;
    --provider)    PROVIDER="${2:?--provider needs a name}"; shift 2 ;;
    --version)     VERSION="${2:?--version needs a value}"; shift 2 ;;
    --check|--doctor) MODE="doctor"; shift ;;
    --global)      MODE="global"; shift ;;
    --print-manual|--manual) MODE="manual"; shift ;;
    --dry-run)     DRY_RUN=1; shift ;;
    --yes|-y)      YES=1; shift ;;
    --skill)       SKILL_FLAG="--skill"; shift ;;
    --no-skill)    SKILL_FLAG="--skill=false"; shift ;;
    -h|--help)     usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ "$MODE" == "manual" ]]; then
  cat <<'EOF'
Manual MCP registration (stdio server "rea"):

Claude Code:
  claude mcp add --scope local rea -- npx -y rea-agents@latest mcp

Generic mcpServers JSON entry (Cursor, VS Code, Gemini, Windsurf, ...):
  "rea": { "command": "npx", "args": ["-y", "rea-agents@latest", "mcp"] }

With a global install, replace the command/args with:
  "rea": { "command": "rea", "args": ["mcp"] }

Prefer `npx rea-agents setup --client <id>` — it writes this for you, with
backups, after showing the exact plan.
EOF
  exit 0
fi

# Preflight: Node.js/npm are prerequisites we deliberately do not install.
if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
  echo "ERROR: Node.js + npx are required but not on PATH." >&2
  echo "Install Node.js LTS from https://nodejs.org or your package manager," >&2
  echo "then re-run this script. REA never installs Node/npm on your behalf." >&2
  exit 2
fi

run_rea() {
  if command -v rea >/dev/null 2>&1; then
    rea "$@"
  else
    npx -y "${PKG}@${VERSION}" "$@"
  fi
}

case "$MODE" in
  global)
    echo "Installing global CLI: npm install --global ${PKG}@latest"
    npm install --global "${PKG}@latest"
    echo "Done. Next: rea setup   (register your agent)   |   rea doctor --json"
    ;;
  doctor)
    args=(doctor --json)
    for c in "${CLIENTS[@]:-}"; do [[ -n "$c" ]] && args+=(--client "$c"); done
    [[ -n "$PROVIDER" ]] && args+=(--provider "$PROVIDER")
    [[ -n "$SKILL_FLAG" ]] && args+=("$SKILL_FLAG")
    echo "Running: rea ${args[*]}"
    run_rea "${args[@]}"
    ;;
  setup)
    args=(setup)
    for c in "${CLIENTS[@]:-}"; do [[ -n "$c" ]] && args+=(--client "$c"); done
    [[ -n "$SKILL_FLAG" ]] && args+=("$SKILL_FLAG")
    if [[ "$DRY_RUN" -eq 1 ]]; then
      args+=(--dry-run --json)
    elif [[ "$YES" -eq 1 ]]; then
      if [[ "${#CLIENTS[@]}" -eq 0 ]]; then
        echo "ERROR: --yes requires an explicit scope such as --client <id>." >&2
        exit 2
      fi
      args+=(--yes)
    fi
    echo "Running: rea ${args[*]}"
    echo "(setup prints the exact paths and changes, then asks for approval)"
    run_rea "${args[@]}"
    echo
    echo "Restart the agent(s) named in the completion message, then verify with:"
    echo "  $0 --check${CLIENTS:+ --client ${CLIENTS[0]}}"
    ;;
esac
