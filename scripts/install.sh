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
echo "Linked: ~/.claude/CLAUDE.md -> AGENTS.md"
echo "Linked: ~/.codex/AGENTS.md -> AGENTS.md"

# Install skills from lockfile
if [ -f "$INSTALL_DIR/src/.skill-lock.json" ]; then
  sources=$(python3 -c "
import json
with open('$INSTALL_DIR/src/.skill-lock.json') as f:
    data = json.load(f)
for skill in data.get('skills', {}).values():
    print(skill['source'])
")
  for source in $sources; do
    echo "Installing skill: $source"
    npx skills add "$source" -g -y 2>/dev/null || echo "  Failed: $source"
  done
fi

echo "Done."
