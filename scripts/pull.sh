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

# Cursor User Rules are not filesystem-synced; copy from src/AGENTS.md in Settings if you want them.
if command -v cursor >/dev/null 2>&1; then
  SKILL_AGENTS+=(cursor)
else
  echo "Skipping Cursor skills: 'cursor' is not on PATH (install Shell Command from Cursor command palette)"
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

    # Remove installed skills no longer in the manifest. Use the lockfile for
    # canonical names and also scan the skill directories to catch orphaned
    # folders that are no longer tracked there.
    LOCKFILE="$HOME/.agents/.skill-lock.json"
    INSTALLED_SKILL_NAMES=""
    if [ -f "$LOCKFILE" ]; then
      INSTALLED_SKILL_NAMES=$(jq -r '(.skills // {}) | keys[]' "$LOCKFILE")
      INSTALLED_SKILL_NAMES+=$'\n'
    fi

    SKILLS_DIR="$HOME/.agents/skills"
    if [ -d "$SKILLS_DIR" ]; then
      for skill_dir in "$SKILLS_DIR"/*/; do
        [ -d "$skill_dir" ] || continue

        skill_name=""
        if [ -f "$skill_dir/SKILL.md" ]; then
          skill_name=$(awk -F': *' '/^name:/ {print $2; exit}' "$skill_dir/SKILL.md")
        fi
        if [ -z "$skill_name" ]; then
          skill_name=$(basename "$skill_dir")
        fi

        INSTALLED_SKILL_NAMES+="$skill_name"$'\n'
      done
    fi

    if [ -n "$INSTALLED_SKILL_NAMES" ]; then
      while IFS= read -r skill_name; do
        [ -n "$skill_name" ] || continue
        if ! echo "$MANIFEST_NAMES" | grep -qx "$skill_name"; then
          echo "Removing stale skill: $skill_name"
          npx skills remove "$skill_name" -g -y </dev/null 2>/dev/null || echo "  Failed to remove: $skill_name"
        fi
      done < <(printf '%s' "$INSTALLED_SKILL_NAMES" | sort -u)
    fi
  fi
else
  echo "No skills manifest found at $MANIFEST"
fi

echo "Done."
