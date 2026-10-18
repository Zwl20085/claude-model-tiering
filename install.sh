#!/usr/bin/env sh
# Installs the model-tiering skill and always-on rule into ~/.claude (macOS / Linux / Git Bash).
set -e
root="$(cd "$(dirname "$0")" && pwd)"
skill_dst="$HOME/.claude/skills/model-tiering"
rule_dst="$HOME/.claude/rules/common"
mkdir -p "$skill_dst" "$rule_dst"
cp "$root"/skills/model-tiering/* "$skill_dst"/
cp "$root"/rules/model-tiering.md "$rule_dst"/model-tiering.md
echo "Installed skill  -> $skill_dst"
echo "Installed rule   -> $rule_dst/model-tiering.md"
echo "Start a new Claude Code session; the rule loads automatically, the skill is /model-tiering."
