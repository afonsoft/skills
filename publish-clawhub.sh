#!/usr/bin/env bash
# Publish all skills in this repo to ClawHub (the public OpenClaw skill registry).
#
# ClawHub CLI: https://docs.openclaw.ai/tools/clawhub
#
# Prerequisites (one-time, per machine):
#   1. Node.js 18+ and npm/pnpm
#   2. npm i -g clawhub  (or pnpm add -g clawhub)
#   3. clawhub login
#
# Usage:
#   ./publish-clawhub.sh            # publish all new/changed skills
#   ./publish-clawhub.sh --dry-run  # preview the publish plan
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
OWNER="afonsoft"
DRY_RUN=false

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

if ! command -v clawhub >/dev/null 2>&1; then
  echo "ERROR: clawhub CLI not found. Install it first:" >&2
  echo "  npm i -g clawhub" >&2
  exit 1
fi

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "ERROR: skills/ directory not found at $SKILLS_DIR" >&2
  exit 1
fi

if ! $DRY_RUN; then
  echo "=== Checking ClawHub auth ==="
  if ! clawhub whoami >/dev/null 2>&1; then
    echo "ERROR: Not authenticated. Run:" >&2
    echo "  clawhub login" >&2
    exit 1
  fi
  echo "Authenticated. Proceeding..."
  echo
fi

SYNC_ARGS=(
  sync
  --root "$SKILLS_DIR"
  --owner "$OWNER"
  --all
)

if $DRY_RUN; then
  SYNC_ARGS+=(--dry-run)
  echo "=== Dry-run publish plan ==="
else
  echo "=== Publishing skills to ClawHub ==="
fi

clawhub "${SYNC_ARGS[@]}"
