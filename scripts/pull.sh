#!/bin/bash
set -euo pipefail

REPO="git@github.com:uinaf/agents.git"
INSTALL_DIR="${AGENTS_DIR:-$HOME/projects/agents}"

# Clone or pull
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "Pulling latest..."
  cd "$INSTALL_DIR" && git pull --ff-only
else
  echo "Cloning..."
  git clone "$REPO" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

# Symlink for each agent
mkdir -p "$HOME/.claude" "$HOME/.codex"
ln -sf "$INSTALL_DIR/AGENTS.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$INSTALL_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"
echo "Linked: ~/.claude/CLAUDE.md -> AGENTS.md"
echo "Linked: ~/.codex/AGENTS.md -> AGENTS.md"

MANIFEST="$INSTALL_DIR/skills/skills.json"

# Install skills only from stable manifest (portable across machines)
if [ -f "$MANIFEST" ]; then
  jq -r '.skills[] | "\(.name) \(.source)"' "$MANIFEST" |
  while read -r name source; do
    echo "Installing skill: $name from $source"
    npx skills add "$source" -g -y -s "$name" </dev/null 2>/dev/null || echo "  Failed: $name"
  done
else
  echo "No skills manifest found at $MANIFEST"
fi

echo "Done."
