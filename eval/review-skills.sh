#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

threshold="${TESSL_THRESHOLD:-90}"
args=()

has_threshold=false
has_json=false
for arg in "$@"; do
  if [[ "$arg" == "--threshold" ]] || [[ "$arg" == --threshold=* ]]; then
    has_threshold=true
  fi
  if [[ "$arg" == "--json" ]]; then
    has_json=true
  fi
done

if [[ "$has_json" == true ]]; then
  echo "batch review does not support --json; run npx tessl skill review --json skills/<name> per skill"
  exit 1
fi

if [[ "$has_threshold" == false ]]; then
  args+=(--threshold "$threshold")
fi

args+=("$@")

for skill_dir in skills/*; do
  if [[ -d "$skill_dir" ]]; then
    echo "== tessl review: ${skill_dir#skills/} =="
    npx tessl skill review "${args[@]}" "$skill_dir"
  fi
done
