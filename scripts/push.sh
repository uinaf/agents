#!/bin/bash
set -euo pipefail

INSTALL_DIR="${AGENTS_DIR:-$HOME/projects/agents}"
cd "$INSTALL_DIR"

GLOBAL_LOCK="$HOME/.agents/.skill-lock.json"
MANIFEST_PATH="$INSTALL_DIR/skills/skills.json"

if [ -f "$GLOBAL_LOCK" ]; then
  TMP_MANIFEST=$(mktemp)

  # Build stable skills array from global lock
  jq '{skills:(.skills | to_entries | map({name:.key, source:.value.source}) | sort_by(.name))}' "$GLOBAL_LOCK" > "$TMP_MANIFEST"

  NEW_HASH=$(jq -c '.skills' "$TMP_MANIFEST" | shasum -a 256 | awk '{print $1}')
  CURRENT_VERSION=$(jq -r '.version // 0' "$MANIFEST_PATH" 2>/dev/null || echo 0)
  CURRENT_HASH=$(jq -r '.manifestHash // ""' "$MANIFEST_PATH" 2>/dev/null || echo "")

  if [ "$NEW_HASH" != "$CURRENT_HASH" ]; then
    NEXT_VERSION=$((CURRENT_VERSION + 1))
  else
    NEXT_VERSION=$CURRENT_VERSION
  fi

  UPDATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  jq --argjson version "$NEXT_VERSION" \
     --arg manifestHash "$NEW_HASH" \
     --arg updatedAt "$UPDATED_AT" \
     '. + {version:$version, manifestHash:$manifestHash, updatedAt:$updatedAt}' \
     "$TMP_MANIFEST" > "$MANIFEST_PATH"

  rm -f "$TMP_MANIFEST"
  echo "Synced $MANIFEST_PATH (version=$NEXT_VERSION, hash=$NEW_HASH)"
fi

if [ -z "$(git status --porcelain)" ]; then
  echo "Nothing to push."
  exit 0
fi

git add -A
git diff --cached --stat

auto_version=$(jq -r '.version // 0' "$MANIFEST_PATH" 2>/dev/null || echo 0)
auto_hash=$(jq -r '.manifestHash // ""' "$MANIFEST_PATH" 2>/dev/null | cut -c1-8)
auto_msg="chore(skills): sync manifest v${auto_version} (${auto_hash})"

# Optional override: COMMIT_MSG="..." scripts/push.sh
msg="${COMMIT_MSG:-$auto_msg}"
echo "Auto-commit: $msg"
git commit -m "$msg"
git push
echo "Pushed."
