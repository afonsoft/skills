#!/usr/bin/env bash
# validate-harness.sh — Validate a Claude Code harness after migration/creation.
# Run from the repository root.

set -euo pipefail

fail=0

echo "=== 4.1 Migration validation ==="
# No legacy artifact may remain
if [[ -n $(ls -d .agents .windsurf .devin/agents 2>/dev/null) ]]; then
  echo "FAIL: legacy harness directories remain"
  fail=1
fi

if [[ -n $(ls AGENTS.md DEVIN.md GEMINI.md copilot-instructions.md \
           .cursorrules .cursorignore .aiignore \
           .claudeignore .devinignore .windsurfignore SESSION_STATE.md 2>/dev/null) ]]; then
  echo "FAIL: legacy root harness files remain"
  fail=1
fi

# No harness directory loose at the root
if [[ -n $(ls -d skills rules knowledge memory 2>/dev/null) ]]; then
  echo "FAIL: loose harness directories at root"
  fail=1
fi

# No legacy frontmatter left to convert
if grep -rl "applyTo" --include="*.md" . 2>/dev/null | grep -q .; then
  echo "FAIL: applyTo frontmatter remains"
  fail=1
fi

if grep -rl "allowed-tools" --include="*.md" . 2>/dev/null | grep -q .; then
  echo "FAIL: allowed-tools frontmatter remains"
  fail=1
fi

echo "=== 4.2 Target structure validation ==="
test -f CLAUDE.md && echo "  CLAUDE.md OK" || { echo "  MISSING CLAUDE.md"; fail=1; }
test -f AGENTS.md && echo "  AGENTS.md OK" || { echo "  MISSING AGENTS.md"; fail=1; }
test -f .claude/settings.json && echo "  .claude/settings.json OK" || { echo "  MISSING .claude/settings.json"; fail=1; }
test -f .claude/rules/global-rules.md && echo "  .claude/rules/global-rules.md OK" || { echo "  MISSING .claude/rules/global-rules.md"; fail=1; }

for a in review plan test; do
  if test -f ".claude/agents/$a.md"; then
    echo "  .claude/agents/$a.md OK"
  else
    echo "  MISSING .claude/agents/$a.md"
    fail=1
  fi
done

if grep -qiE 'SPEC.*SDD|SDD.*SPEC|\.specs/' .claude/agents/plan.md 2>/dev/null; then
  echo "  plan.md references SPEC SDD"
  if [ -d .specs ]; then
    echo "  .specs/ directory OK"
  else
    echo "  MISSING .specs/ directory"
    fail=1
  fi
else
  echo "  plan.md does not reference SPEC SDD"
  fail=1
fi

for f in .claude/CONTEXT.md .claude/RULES.md .claude/MEMORY.md .claude/TOOLS.md .claude/WORKFLOWS.md .claude/README.md; do
  if test -f "$f"; then
    echo "  $f OK"
  else
    echo "  MISSING $f"
    fail=1
  fi
done

if python3 -c "import json; json.load(open('.claude/settings.json')); print('  settings.json is valid JSON')" 2>/dev/null; then
  :
else
  echo "  .claude/settings.json is invalid JSON"
  fail=1
fi

lines=$(wc -l < CLAUDE.md)
if [ "$lines" -le 1000 ]; then
  echo "  CLAUDE.md within 1000 lines ($lines)"
else
  echo "  CLAUDE.md EXCEEDS 1000 lines ($lines)"
  fail=1
fi

grep -q 'global-rules.md' CLAUDE.md && echo "  CLAUDE.md references global-rules" || { echo "  CLAUDE.md missing global-rules reference"; fail=1; }
! grep -q '^paths:' .claude/rules/global-rules.md && echo "  global-rules has no paths:" || { echo "  global-rules has paths: (not always-on)"; fail=1; }
grep -q '.claude/memory/memory.md' CLAUDE.md && echo "  CLAUDE.md references memory.md" || { echo "  CLAUDE.md missing memory.md reference"; fail=1; }
grep -q '.claude/CONTEXT.md' CLAUDE.md && echo "  CLAUDE.md references CONTEXT.md" || { echo "  CLAUDE.md missing CONTEXT.md reference"; fail=1; }
grep -q '.claude/RULES.md' CLAUDE.md && echo "  CLAUDE.md references RULES.md" || { echo "  CLAUDE.md missing RULES.md reference"; fail=1; }

echo "=== 4.3 Memory validation ==="
test -f .claude/memory/memory.md && echo "  .claude/memory/memory.md OK" || { echo "  MISSING .claude/memory/memory.md"; fail=1; }
if ls .claude/memory/[0-9]*-memory.md >/dev/null 2>&1; then
  echo "  long-term memory files OK"
else
  echo "  MISSING long-term memory files"
  fail=1
fi

m_lines=$(wc -l < .claude/memory/memory.md)
if [ "$m_lines" -le 100 ]; then
  echo "  memory.md within 100 lines ($m_lines)"
else
  echo "  memory.md EXCEEDS 100 lines ($m_lines)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo ""
  echo "PASS: harness validation succeeded"
  exit 0
else
  echo ""
  echo "FAIL: harness validation failed"
  exit 1
fi
