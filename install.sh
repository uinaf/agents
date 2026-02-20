#!/bin/bash
set -euo pipefail

REPO="git@github.com:uinaf/agents.git"
INSTALL_DIR="${AGENTS_DIR:-$HOME/projects/agents}"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

# Clone or pull
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "Pulling latest..."
  cd "$INSTALL_DIR" && git pull --ff-only
else
  echo "Cloning..."
  git clone "$REPO" "$INSTALL_DIR"
fi

# Symlink global CLAUDE.md
mkdir -p "$CLAUDE_DIR"
ln -sf "$INSTALL_DIR/AGENTS.md" "$CLAUDE_DIR/CLAUDE.md"
echo "Linked: ~/.claude/CLAUDE.md -> AGENTS.md"

# Install skills
if [ -d "$INSTALL_DIR/skills" ]; then
  mkdir -p "$SKILLS_DIR"
  for skill in "$INSTALL_DIR/skills"/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    ln -sfn "$skill" "$SKILLS_DIR/$name"
    echo "Linked skill: $name"
  done
fi

echo "Done."
