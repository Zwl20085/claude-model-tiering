#!/usr/bin/env sh
# Installs (or with --uninstall removes) the model-tiering skill, rule and tier agents.
# Target: $CLAUDE_CONFIG_DIR if set and non-empty, else ~/.claude. Safe to re-run.
set -eu

usage() { echo "usage: $0 [--uninstall]"; }

mode=install
case "${1:-}" in
  '') ;;
  --uninstall) mode=uninstall ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

root=$(cd "$(dirname "$0")" && pwd)
config=${CLAUDE_CONFIG_DIR:-$HOME/.claude}

skill_dst="$config/skills/model-tiering"
rule_dst="$config/rules/common/model-tiering.md"
agent_dst="$config/agents"

set -- "$root"/agents/tier-*.md
if [ ! -e "$1" ]; then
  echo "No agents/tier-*.md found in $root" >&2
  exit 1
fi

remove_if_present() {
  if [ -e "$1" ]; then
    rm -rf -- "$1"
    echo "Removed      $1"
  else
    echo "Not present  $1"
  fi
}

echo "Claude config dir: $config"

if [ "$mode" = uninstall ]; then
  remove_if_present "$skill_dst"
  remove_if_present "$rule_dst"
  for f in "$@"; do remove_if_present "$agent_dst/$(basename "$f")"; done
  echo "Uninstalled. Other files under the config dir were left alone."
  exit 0
fi

# Skill: replace the whole directory so files from an older install do not linger.
mkdir -p "$config/skills"
rm -rf -- "$skill_dst"
cp -R "$root/skills/model-tiering" "$skill_dst"
echo "Installed    $skill_dst"

mkdir -p "$config/rules/common"
cp "$root/rules/model-tiering.md" "$rule_dst"
echo "Installed    $rule_dst"

mkdir -p "$agent_dst"
for f in "$@"; do
  cp "$f" "$agent_dst/"
  echo "Installed    $agent_dst/$(basename "$f")"
done

echo "Start a new Claude Code session to pick up the rule, the skill (/model-tiering) and the agents."
