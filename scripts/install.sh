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

# Install skills from lockfile
if [ -f "$INSTALL_DIR/skills/.skill-lock.json" ]; then
  python3 -c "
import json
with open('$INSTALL_DIR/skills/.skill-lock.json') as f:
    data = json.load(f)
for name, info in data.get('skills', {}).items():
    print(name + ' ' + info['source'])
" | while read -r name source; do
    echo "Installing skill: $name from $source"
    npx skills add "$source" -g -y -s "$name" 2>/dev/null || echo "  Failed: $name"
  done
fi

echo "Done."
