#!/usr/bin/env bash
# Installer for afonsoft/skills with support for automatic /architecture:<skill> slash command shims
#
# Usage:
#   ./install.sh --all            Install for all IDEs/CLIs + slash commands
#   ./install.sh --claude         Install for Claude Code
#   ./install.sh --opencode       Install for OpenCode
#   ./install.sh --devin          Install for Devin
#   ./install.sh --cursor         Install for Cursor
#   ./install.sh --dry-run        Preview installation

set -e

INSTALL_ALL=false
INSTALL_CLAUDE=false
INSTALL_OPENCODE=false
INSTALL_DEVIN=false
INSTALL_CURSOR=false
DRY_RUN=false

for arg in "$@"; do
  case $arg in
    --all|-a) INSTALL_ALL=true ;;
    --claude|-c) INSTALL_CLAUDE=true ;;
    --opencode|-o) INSTALL_OPENCODE=true ;;
    --devin|-d) INSTALL_DEVIN=true ;;
    --cursor) INSTALL_CURSOR=true ;;
    --dry-run) DRY_RUN=true ;;
    --help|-h)
      echo "Usage: ./install.sh [--all | --claude | --opencode | --devin | --cursor] [--dry-run]"
      exit 0
      ;;
  esac
done

if [ "$INSTALL_ALL" = true ]; then
  INSTALL_CLAUDE=true
  INSTALL_OPENCODE=true
  INSTALL_DEVIN=true
  INSTALL_CURSOR=true
fi

if [ "$INSTALL_CLAUDE" = false ] && [ "$INSTALL_OPENCODE" = false ] && [ "$INSTALL_DEVIN" = false ] && [ "$INSTALL_CURSOR" = false ]; then
  INSTALL_ALL=true
  INSTALL_CLAUDE=true
  INSTALL_OPENCODE=true
  INSTALL_DEVIN=true
  INSTALL_CURSOR=true
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SRC_DIR/skills"

echo "=== Installing afonsoft/skills ==="

# 1. Install skills directories
install_skills() {
  local target_dir="$1"
  echo "-> Installing skills to $target_dir"
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] mkdir -p $target_dir"
  else
    mkdir -p "$target_dir"
  fi

  for skill_path in "$SKILLS_DIR"/*/; do
    [ -d "$skill_path" ] || continue
    local skill_name
    skill_name=$(basename "$skill_path")
    if [ "$DRY_RUN" = true ]; then
      echo "[DRY-RUN] cp -r $skill_path $target_dir/$skill_name"
    else
      if [ -n "$target_dir" ] && [ -n "$skill_name" ]; then
        rm -rf "${target_dir:?}/${skill_name:?}"
      fi
      cp -r "$skill_path" "$target_dir/$skill_name"
    fi
  done
}

# 2. Generate slash command shims for /architecture:<skill>
generate_slash_commands() {
  echo "-> Generating /architecture:<skill> slash command shims..."
  
  for skill_path in "$SKILLS_DIR"/*/; do
    [ -d "$skill_path" ] || continue
    local skill_name
    skill_name=$(basename "$skill_path")

    # Claude Code commands (.claude/commands/architecture:<skill>.md)
    if [ "$INSTALL_CLAUDE" = true ]; then
      local claude_cmd_dir="$HOME/.claude/commands"
      if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] mkdir -p $claude_cmd_dir && echo '...' > $claude_cmd_dir/architecture:$skill_name.md"
      else
        mkdir -p "$claude_cmd_dir"
        cat <<EOF > "$claude_cmd_dir/architecture:$skill_name.md"
---
description: "Execute architecture skill: $skill_name"
---
Load and execute the skill '$skill_name' to handle the request: \$ARGUMENTS
EOF
      fi
    fi

    # OpenCode commands (.config/opencode/commands/architecture:<skill>.md)
    if [ "$INSTALL_OPENCODE" = true ]; then
      local opencode_cmd_dir="$HOME/.config/opencode/commands"
      if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] mkdir -p $opencode_cmd_dir && echo '...' > $opencode_cmd_dir/architecture:$skill_name.md"
      else
        mkdir -p "$opencode_cmd_dir"
        cat <<EOF > "$opencode_cmd_dir/architecture:$skill_name.md"
---
description: "Execute architecture skill: $skill_name"
---
Load and execute the skill '$skill_name' to handle the request: \$ARGUMENTS
EOF
      fi
    fi

    # Devin commands (.devin/commands/architecture:<skill>.md)
    if [ "$INSTALL_DEVIN" = true ]; then
      local devin_cmd_dir="$HOME/.devin/commands"
      if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] mkdir -p $devin_cmd_dir && echo '...' > $devin_cmd_dir/architecture:$skill_name.md"
      else
        mkdir -p "$devin_cmd_dir"
        cat <<EOF > "$devin_cmd_dir/architecture:$skill_name.md"
---
description: "Execute architecture skill: $skill_name"
---
Load and execute the skill '$skill_name' to handle the request: \$ARGUMENTS
EOF
      fi
    fi
  done
}

if [ "$INSTALL_CLAUDE" = true ]; then
  install_skills "$HOME/.claude/skills"
  install_skills "$HOME/.agents/skills"
fi

if [ "$INSTALL_OPENCODE" = true ]; then
  install_skills "$HOME/.opencode/skills"
  install_skills "$HOME/.config/opencode/skills"
fi

if [ "$INSTALL_DEVIN" = true ]; then
  install_skills "$HOME/.devin/skills"
fi

if [ "$INSTALL_CURSOR" = true ]; then
  install_skills "$HOME/.cursor/skills"
fi

generate_slash_commands

echo "=== Installation complete successfully! ==="
