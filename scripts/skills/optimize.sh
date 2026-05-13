#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

if [[ $# -lt 1 ]]; then
  echo "usage: ./scripts/skills/optimize.sh <skill-name> [extra tessl args...]"
  exit 1
fi

skill_name="$1"
shift
tessl_version="${TESSL_CLI_VERSION:-0.79.1}"

skill_dir="skills/$skill_name"

if [[ ! -d "$skill_dir" ]]; then
  echo "unknown skill: $skill_name"
  exit 1
fi

npx "tessl@$tessl_version" skill review --optimize --yes --max-iterations 1 "$skill_dir" "$@"
