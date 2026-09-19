#!/usr/bin/env bash
# Installer for afonsoft/skills with support for automatic slash command shims
#
# Slash command conventions differ per CLI:
#   - Claude Code / OpenCode / Devin accept ':' in the command file name
#     -> commands/spec-driven:<skill>.md   => /spec-driven:<skill>
#   - Qwen Code derives the namespace from a subdirectory
#     -> commands/spec-driven/<skill>.md   => /spec-driven:<skill>
#   - Codex, Cline, Continue and Grok do not accept ':' in command names
#     -> <commands>/spec-driven-<skill>.md => /spec-driven-<skill>
#   - agy / Kimi / Kiro expose installed skills as slash commands natively
#   - Aider has no file-based commands; an index file is generated instead
#
# Usage:
#   ./install.sh --all            Install for all IDEs/CLIs + slash commands
#   ./install.sh --claude         Install for Claude Code
#   ./install.sh --opencode       Install for OpenCode
#   ./install.sh --devin          Install for Devin
#   ./install.sh --cursor         Install for Cursor
#   ./install.sh --codex          Install for OpenAI Codex CLI
#   ./install.sh --agy            Install for Google Antigravity CLI (agy)
#   ./install.sh --aider          Install for Aider
#   ./install.sh --cline          Install for Cline
#   ./install.sh --continue       Install for Continue
#   ./install.sh --grok           Install for Grok CLI
#   ./install.sh --kimi           Install for Kimi Code CLI
#   ./install.sh --kiro           Install for Kiro CLI
#   ./install.sh --qwen           Install for Qwen Code
#   ./install.sh --dry-run        Preview installation

set -e

INSTALL_ALL=false
INSTALL_CLAUDE=false
INSTALL_OPENCODE=false
INSTALL_DEVIN=false
INSTALL_CURSOR=false
INSTALL_CODEX=false
INSTALL_AGY=false
INSTALL_AIDER=false
INSTALL_CLINE=false
INSTALL_CONTINUE=false
INSTALL_GROK=false
INSTALL_KIMI=false
INSTALL_KIRO=false
INSTALL_QWEN=false
TARGET_SELECTED=false
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [target flags] [--dry-run]

Targets:
  --all, -a        Install for every supported IDE/CLI
  --claude, -c     Claude Code            (~/.claude, ~/.agents)
  --opencode, -o   OpenCode               (~/.opencode, ~/.config/opencode)
  --devin, -d      Devin                  (~/.devin)
  --cursor         Cursor                 (~/.cursor)
  --codex          OpenAI Codex CLI       (~/.codex)
  --agy            Antigravity CLI (agy)  (~/.gemini/antigravity-cli)
  --aider          Aider                  (~/.aider)
  --cline          Cline                  (~/.cline)
  --continue       Continue               (~/.continue)
  --grok           Grok CLI               (~/.grok, ~/.agents/commands)
  --kimi           Kimi Code CLI          (~/.kimi)
  --kiro           Kiro CLI               (~/.kiro)
  --qwen           Qwen Code              (~/.qwen)

Options:
  --dry-run        Preview changes without writing anything
  --help, -h       Show this message

With no target flag, installs for all targets.
EOF
}

for arg in "$@"; do
  case $arg in
    --all|-a) INSTALL_ALL=true ;;
    --claude|-c) INSTALL_CLAUDE=true; TARGET_SELECTED=true ;;
    --opencode|-o) INSTALL_OPENCODE=true; TARGET_SELECTED=true ;;
    --devin|-d) INSTALL_DEVIN=true; TARGET_SELECTED=true ;;
    --cursor) INSTALL_CURSOR=true; TARGET_SELECTED=true ;;
    --codex) INSTALL_CODEX=true; TARGET_SELECTED=true ;;
    --agy|--antigravity) INSTALL_AGY=true; TARGET_SELECTED=true ;;
    --aider) INSTALL_AIDER=true; TARGET_SELECTED=true ;;
    --cline) INSTALL_CLINE=true; TARGET_SELECTED=true ;;
    --continue|--continue-dev) INSTALL_CONTINUE=true; TARGET_SELECTED=true ;;
    --grok) INSTALL_GROK=true; TARGET_SELECTED=true ;;
    --kimi) INSTALL_KIMI=true; TARGET_SELECTED=true ;;
    --kiro) INSTALL_KIRO=true; TARGET_SELECTED=true ;;
    --qwen) INSTALL_QWEN=true; TARGET_SELECTED=true ;;
    --dry-run) DRY_RUN=true ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

if [ "$INSTALL_ALL" = true ] || [ "$TARGET_SELECTED" = false ]; then
  INSTALL_CLAUDE=true
  INSTALL_OPENCODE=true
  INSTALL_DEVIN=true
  INSTALL_CURSOR=true
  INSTALL_CODEX=true
  INSTALL_AGY=true
  INSTALL_AIDER=true
  INSTALL_CLINE=true
  INSTALL_CONTINUE=true
  INSTALL_GROK=true
  INSTALL_KIMI=true
  INSTALL_KIRO=true
  INSTALL_QWEN=true
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SRC_DIR/skills"

echo "=== Installing afonsoft/skills ==="

# Run a command, or just print it under --dry-run
run() {
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] $*"
  else
    "$@"
  fi
}

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

# Write a markdown slash-command shim.
# $1 = destination file, $2 = skill name,
# $3 = args placeholder (default: $ARGUMENTS), $4 = extra frontmatter lines
write_command() {
  local dest="$1" skill_name="$2" extra_frontmatter="${4:-}"
  local args_placeholder='$ARGUMENTS'
  [ -n "${3:-}" ] && args_placeholder="$3"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] mkdir -p $dest_dir && write $dest"
    return
  fi
  mkdir -p "$dest_dir"
  {
    echo "---"
    echo "description: \"Execute spec-driven skill: $skill_name\""
    [ -n "$extra_frontmatter" ] && echo "$extra_frontmatter"
    echo "---"
    echo "Load and execute the skill '$skill_name' to handle the request: $args_placeholder"
  } > "$dest"
}

# Write the root /spec-driven command -> orchestrator skill.
# $1 = destination file, $2 = args placeholder (default: $ARGUMENTS),
# $3 = extra frontmatter lines
write_root_command() {
  local dest="$1" extra_frontmatter="${3:-}"
  local args_placeholder='$ARGUMENTS'
  [ -n "${2:-}" ] && args_placeholder="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] mkdir -p $dest_dir && write $dest"
    return
  fi
  mkdir -p "$dest_dir"
  {
    echo "---"
    echo 'description: "Run the spec-driven pipeline via the orchestrator skill"'
    [ -n "$extra_frontmatter" ] && echo "$extra_frontmatter"
    echo "---"
    echo "Load and execute the skill 'orchestrator' to handle the request: $args_placeholder"
  } > "$dest"
}

# 2. Generate slash command shims (naming follows each CLI's own convention)
generate_slash_commands() {
  echo "-> Generating slash command shims..."

  for skill_path in "$SKILLS_DIR"/*/; do
    [ -d "$skill_path" ] || continue
    local skill_name
    skill_name=$(basename "$skill_path")

    # Claude Code: /spec-driven:<skill> (':' allowed in the file name)
    if [ "$INSTALL_CLAUDE" = true ]; then
      run rm -f "$HOME/.claude/commands/architecture:$skill_name.md"
      write_command "$HOME/.claude/commands/spec-driven:$skill_name.md" "$skill_name"
    fi

    # OpenCode: /spec-driven:<skill>
    if [ "$INSTALL_OPENCODE" = true ]; then
      run rm -f "$HOME/.config/opencode/commands/architecture:$skill_name.md"
      write_command "$HOME/.config/opencode/commands/spec-driven:$skill_name.md" "$skill_name"
    fi

    # Devin: /spec-driven:<skill>
    if [ "$INSTALL_DEVIN" = true ]; then
      run rm -f "$HOME/.devin/commands/architecture:$skill_name.md"
      write_command "$HOME/.devin/commands/spec-driven:$skill_name.md" "$skill_name"
    fi

    # Qwen Code: ':' is not allowed in file names; a spec-driven/ subdirectory
    # produces the namespaced command /spec-driven:<skill>. Args use {{args}}.
    if [ "$INSTALL_QWEN" = true ]; then
      write_command "$HOME/.qwen/commands/spec-driven/$skill_name.md" "$skill_name" '{{args}}'
    fi

    # Codex CLI: custom prompts are flat files in ~/.codex/prompts, invoked as
    # /prompts:<name>; ':' not allowed -> /prompts:spec-driven-<skill>
    if [ "$INSTALL_CODEX" = true ]; then
      write_command "$HOME/.codex/prompts/spec-driven-$skill_name.md" "$skill_name"
    fi

    # Cline: global workflows are slash commands -> /spec-driven-<skill>
    if [ "$INSTALL_CLINE" = true ]; then
      write_command "$HOME/.cline/data/workflows/spec-driven-$skill_name.md" "$skill_name"
    fi

    # Continue: invokable prompts -> /spec-driven-<skill>
    if [ "$INSTALL_CONTINUE" = true ]; then
      write_command "$HOME/.continue/prompts/spec-driven-$skill_name.md" "$skill_name" '$ARGUMENTS' "name: spec-driven-$skill_name
invokable: true"
    fi

    # Grok CLI: user-level commands in ~/.agents/commands -> /spec-driven-<skill>
    if [ "$INSTALL_GROK" = true ]; then
      write_command "$HOME/.agents/commands/spec-driven-$skill_name.md" "$skill_name"
    fi
  done

  # Root /spec-driven command -> orchestrator skill (same as /spec-driven:orchestrator)
  if [ "$INSTALL_CLAUDE" = true ]; then
    write_root_command "$HOME/.claude/commands/spec-driven.md"
  fi
  if [ "$INSTALL_OPENCODE" = true ]; then
    write_root_command "$HOME/.config/opencode/commands/spec-driven.md"
  fi
  if [ "$INSTALL_DEVIN" = true ]; then
    write_root_command "$HOME/.devin/commands/spec-driven.md"
  fi
  if [ "$INSTALL_QWEN" = true ]; then
    write_root_command "$HOME/.qwen/commands/spec-driven.md" '{{args}}'
  fi
  if [ "$INSTALL_CODEX" = true ]; then
    write_root_command "$HOME/.codex/prompts/spec-driven.md"
  fi
  if [ "$INSTALL_CLINE" = true ]; then
    write_root_command "$HOME/.cline/data/workflows/spec-driven.md"
  fi
  if [ "$INSTALL_CONTINUE" = true ]; then
    write_root_command "$HOME/.continue/prompts/spec-driven.md" '$ARGUMENTS' "name: spec-driven
invokable: true"
  fi
  if [ "$INSTALL_GROK" = true ]; then
    write_root_command "$HOME/.agents/commands/spec-driven.md"
  fi
}

# 3. Aider index: Aider has no file-based slash commands, so generate an index
#    the user can load via /read or `read:` in .aider.conf.yml
generate_aider_index() {
  local index_file="$HOME/.aider/spec-driven-skills.md"
  echo "-> Generating Aider skills index ($index_file)"
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] mkdir -p $HOME/.aider && write $index_file"
    return
  fi
  mkdir -p "$HOME/.aider"
  {
    echo "# Spec-driven skills (afonsoft/skills)"
    echo ""
    echo "Skills are installed under \`~/.aider/skills/<name>/SKILL.md\`."
    echo "Aider has no file-based slash commands; load a skill into the chat with"
    echo "\`/read ~/.aider/skills/<name>/SKILL.md\`, or always load this index via"
    echo "\`read: [~/.aider/spec-driven-skills.md]\` in \`.aider.conf.yml\`."
    echo ""
    echo "Available skills:"
    for skill_path in "$SKILLS_DIR"/*/; do
      [ -d "$skill_path" ] || continue
      local skill_name
      skill_name=$(basename "$skill_path")
      echo "- \`$skill_name\` — \`~/.aider/skills/$skill_name/SKILL.md\`"
    done
  } > "$index_file"
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

if [ "$INSTALL_CODEX" = true ]; then
  install_skills "$HOME/.codex/skills"
fi

if [ "$INSTALL_AGY" = true ]; then
  install_skills "$HOME/.gemini/antigravity-cli/skills"
fi

if [ "$INSTALL_AIDER" = true ]; then
  install_skills "$HOME/.aider/skills"
fi

if [ "$INSTALL_CLINE" = true ]; then
  install_skills "$HOME/.cline/skills"
fi

if [ "$INSTALL_CONTINUE" = true ]; then
  install_skills "$HOME/.continue/skills"
fi

if [ "$INSTALL_GROK" = true ]; then
  install_skills "$HOME/.grok/skills"
fi

if [ "$INSTALL_KIMI" = true ]; then
  install_skills "$HOME/.kimi/skills"
fi

if [ "$INSTALL_KIRO" = true ]; then
  install_skills "$HOME/.kiro/skills"
fi

if [ "$INSTALL_QWEN" = true ]; then
  install_skills "$HOME/.qwen/skills"
fi

generate_slash_commands

if [ "$INSTALL_AIDER" = true ]; then
  generate_aider_index
fi

echo "=== Installation complete successfully! ==="
echo ""
echo "Slash command usage per CLI:"
if [ "$INSTALL_CLAUDE" = true ]; then echo "   Claude Code : /spec-driven:<skill>"; fi
if [ "$INSTALL_OPENCODE" = true ]; then echo "   OpenCode    : /spec-driven:<skill>"; fi
if [ "$INSTALL_DEVIN" = true ]; then echo "   Devin       : /spec-driven:<skill>"; fi
if [ "$INSTALL_QWEN" = true ]; then echo "   Qwen Code   : /spec-driven:<skill>"; fi
if [ "$INSTALL_CODEX" = true ]; then echo "   Codex CLI   : /prompts:spec-driven-<skill> (deprecated prompts; prefer \$<skill> or /skills)"; fi
if [ "$INSTALL_CLINE" = true ]; then echo "   Cline       : /spec-driven-<skill>"; fi
if [ "$INSTALL_CONTINUE" = true ]; then echo "   Continue    : /spec-driven-<skill>"; fi
if [ "$INSTALL_GROK" = true ]; then echo "   Grok CLI    : /spec-driven-<skill> (skills also available as /<skill>)"; fi
if [ "$INSTALL_AGY" = true ]; then echo "   agy         : /<skill> (skills are native slash commands)"; fi
if [ "$INSTALL_KIMI" = true ]; then echo "   Kimi Code   : /skill:<skill>"; fi
if [ "$INSTALL_KIRO" = true ]; then echo "   Kiro CLI    : /<skill>"; fi
if [ "$INSTALL_AIDER" = true ]; then echo "   Aider       : /read ~/.aider/skills/<skill>/SKILL.md (index: ~/.aider/spec-driven-skills.md)"; fi
exit 0
