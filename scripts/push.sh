#!/bin/bash
set -euo pipefail

INSTALL_DIR="${AGENTS_DIR:-$HOME/projects/agents}"
cd "$INSTALL_DIR"

GLOBAL_LOCK="$HOME/.agents/.skill-lock.json"
MANIFEST_PATH="$INSTALL_DIR/skills/skills.json"

# Sync stable skills manifest from global lock (ignore machine-specific hash/timestamps)
if [ -f "$GLOBAL_LOCK" ]; then
  jq '{version:1, skills:(.skills | to_entries | map({name:.key, source:.value.source}) | sort_by(.name))}' "$GLOBAL_LOCK" > "$MANIFEST_PATH"
  echo "Synced $MANIFEST_PATH from global skill lock"
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
