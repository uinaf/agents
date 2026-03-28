#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

echo "Pulling latest in $REPO_DIR..."
git -C "$REPO_DIR" pull --ff-only

# Symlink only for installed agents
SKILL_AGENTS=()

if command -v claude >/dev/null 2>&1; then
  mkdir -p "$HOME/.claude"
  ln -sf "$REPO_DIR/src/AGENTS.md" "$HOME/.claude/CLAUDE.md"
  echo "Linked: ~/.claude/CLAUDE.md -> src/AGENTS.md"
  SKILL_AGENTS+=(claude-code)
else
  echo "Skipping Claude Code setup: 'claude' is not installed"
fi

if command -v codex >/dev/null 2>&1; then
  mkdir -p "$HOME/.codex"
  ln -sf "$REPO_DIR/src/AGENTS.md" "$HOME/.codex/AGENTS.md"
  echo "Linked: ~/.codex/AGENTS.md -> src/AGENTS.md"
  SKILL_AGENTS+=(codex)
else
  echo "Skipping Codex setup: 'codex' is not installed"
fi

if command -v pi >/dev/null 2>&1; then
  mkdir -p "$HOME/.pi/agent"
  ln -sf "$REPO_DIR/src/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
  echo "Linked: ~/.pi/agent/AGENTS.md -> src/AGENTS.md"
  SKILL_AGENTS+=(pi)
else
  echo "Skipping pi setup: 'pi' is not installed"
fi

MANIFEST="$REPO_DIR/src/skills.json"

# Install skills only from stable manifest (portable across machines)
if [ -f "$MANIFEST" ]; then
  VERSION=$(jq -r '.version // "?"' "$MANIFEST")
  HASH=$(jq -r '.manifestHash // ""' "$MANIFEST")
  echo "Using skills manifest version=$VERSION hash=$HASH"

  if [ ${#SKILL_AGENTS[@]} -eq 0 ]; then
    echo "No supported agent installations found; skipping skill sync"
  else
    echo "Installing skills for agents: ${SKILL_AGENTS[*]}"

    MANIFEST_NAMES=$(jq -r '.skills[].name' "$MANIFEST")

    jq -r '.skills[] | "\(.name) \(.source)"' "$MANIFEST" |
    while read -r name source; do
      echo "Installing skill: $name from $source"
      npx skills add "$source" -g -y -a "${SKILL_AGENTS[@]}" -s "$name" </dev/null 2>/dev/null || echo "  Failed: $name"
    done

    # Remove installed skills no longer in the manifest
    SKILLS_DIR="$HOME/.agents/skills"
    if [ -d "$SKILLS_DIR" ]; then
      for skill_dir in "$SKILLS_DIR"/*/; do
        skill_name=$(basename "$skill_dir")
        if ! echo "$MANIFEST_NAMES" | grep -qx "$skill_name"; then
          echo "Removing stale skill: $skill_name"
          npx skills remove "$skill_name" -g -y -a "${SKILL_AGENTS[@]}" </dev/null 2>/dev/null || echo "  Failed to remove: $skill_name"
        fi
      done
    fi
  fi
else
  echo "No skills manifest found at $MANIFEST"
fi

echo "Done."
