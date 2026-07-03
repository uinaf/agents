#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

threshold="${TESSL_THRESHOLD:-90}"
tessl_version="${TESSL_CLI_VERSION:-0.80.0}"
args=()
use_lint=false

if [[ "${TESSL_REVIEW_MODE:-}" == "lint" ]]; then
  use_lint=true
elif [[ -n "${CI:-}" && -z "${TESSL_TOKEN:-}" ]]; then
  use_lint=true
fi

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

if [[ "$use_lint" == false && "$has_threshold" == false ]]; then
  args+=(--threshold "$threshold")
fi

args+=("$@")

if [[ "$use_lint" == true ]]; then
  echo "Tessl review requires authentication in CI; running tessl skill lint instead."
fi

for skill_dir in skills/*; do
  if [[ -d "$skill_dir" ]]; then
    if [[ "$use_lint" == true ]]; then
      echo "== tessl lint: ${skill_dir#skills/} =="
      npx "tessl@$tessl_version" skill lint "$skill_dir"
    else
      echo "== tessl review: ${skill_dir#skills/} =="
      npx "tessl@$tessl_version" skill review "${args[@]}" "$skill_dir"
    fi
  fi
done
