#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

threshold="${TESSL_THRESHOLD:-90}"
tessl_version="${TESSL_CLI_VERSION:-0.90.0}"
workspace="${TESSL_WORKSPACE:-uinaf}"
args=()
use_lint=false

if [[ "${TESSL_REVIEW_MODE:-}" == "lint" ]]; then
  use_lint=true
elif [[ -n "${CI:-}" && -z "${TESSL_TOKEN:-}" ]]; then
  use_lint=true
fi

has_threshold=false
has_json=false
has_workspace=false
for arg in "$@"; do
  if [[ "$arg" == "--threshold" ]] || [[ "$arg" == --threshold=* ]]; then
    has_threshold=true
  fi
  if [[ "$arg" == "--json" ]]; then
    has_json=true
  fi
  if [[ "$arg" == "--workspace" ]] || [[ "$arg" == -w ]] || [[ "$arg" == --workspace=* ]]; then
    has_workspace=true
  fi
done

if [[ "$has_json" == true ]]; then
  echo "batch review does not support --json; run npx tessl review run --json skills/<name> per skill"
  exit 1
fi

if [[ "$use_lint" == false && "$has_workspace" == false ]]; then
  args+=(--workspace "$workspace")
fi

if [[ "$use_lint" == false && "$has_threshold" == false ]]; then
  args+=(--threshold "$threshold")
fi

args+=("$@")

if [[ "$use_lint" == true && "${TESSL_REVIEW_MODE:-}" == "lint" ]]; then
  echo "Running tessl plugin lint because TESSL_REVIEW_MODE=lint."
elif [[ "$use_lint" == true ]]; then
  echo "Tessl review requires authentication in CI; running tessl plugin lint instead."
fi

for skill_dir in skills/*; do
  if [[ -d "$skill_dir" ]]; then
    echo "== tessl plugin lint: ${skill_dir#skills/} =="
    npx "tessl@$tessl_version" plugin lint "$skill_dir"

    if [[ "$use_lint" == true ]]; then
      continue
    else
      echo "== tessl review: ${skill_dir#skills/} =="
      npx "tessl@$tessl_version" review run "${args[@]}" "$skill_dir"
    fi
  fi
done
