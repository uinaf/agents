#!/bin/bash
set -euo pipefail

INSTALL_DIR="${AGENTS_DIR:-$HOME/projects/agents}"
cd "$INSTALL_DIR"

# Sync lockfile from global skills
if [ -f "$HOME/.agents/.skill-lock.json" ]; then
  cp "$HOME/.agents/.skill-lock.json" "$INSTALL_DIR/skills/.skill-lock.json"
fi

if [ -z "$(git status --porcelain)" ]; then
  echo "Nothing to push."
  exit 0
fi

git add -A
git diff --cached --stat
echo ""
read -rp "Commit message: " msg
git commit -m "$msg"
git push
echo "Pushed."
