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
ln -sf "$INSTALL_DIR/src/AGENTS.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$INSTALL_DIR/src/AGENTS.md" "$HOME/.codex/AGENTS.md"
echo "Linked: ~/.claude/CLAUDE.md -> src/AGENTS.md"
echo "Linked: ~/.codex/AGENTS.md -> src/AGENTS.md"

MANIFEST="$INSTALL_DIR/src/skills.json"

# Install skills only from stable manifest (portable across machines)
if [ -f "$MANIFEST" ]; then
  VERSION=$(jq -r '.version // "?"' "$MANIFEST")
  HASH=$(jq -r '.manifestHash // ""' "$MANIFEST")
  echo "Using skills manifest version=$VERSION hash=$HASH"

  jq -r '.skills[] | "\(.name) \(.source)"' "$MANIFEST" |
  while read -r name source; do
    echo "Installing skill: $name from $source"
    npx skills add "$source" -g -y -s "$name" </dev/null 2>/dev/null || echo "  Failed: $name"
  done
else
  echo "No skills manifest found at $MANIFEST"
fi

echo "Done."
