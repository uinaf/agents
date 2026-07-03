#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

tessl_version="${TESSL_CLI_VERSION:-0.80.0}"
workspace="${TESSL_WORKSPACE:-uinaf}"
bump="${TESSL_PUBLISH_BUMP:-patch}"
publish_all="${TESSL_PUBLISH_ALL:-false}"
dry_run="${TESSL_DRY_RUN:-false}"
scenario_quality_check="${TESSL_SCENARIO_QUALITY_CHECK:-false}"

publish_args=(--workspace "$workspace" --bump "$bump")
if [[ "$dry_run" == "true" ]]; then
  publish_args=(--dry-run "${publish_args[@]}")
fi
if [[ "$scenario_quality_check" == "true" ]]; then
  publish_args+=(--with-scenario-quality-check)
fi

declare -a plugin_dirs=()

if [[ "$#" -gt 0 ]]; then
  plugin_dirs=("$@")
elif [[ "$publish_all" == "true" ]]; then
  while IFS= read -r dir; do
    plugin_dirs+=("$dir")
  done < <(find skills -mindepth 1 -maxdepth 1 -type d | sort)
else
  if [[ -z "${GITHUB_EVENT_BEFORE:-}" || -z "${GITHUB_SHA:-}" ]]; then
    echo "No plugin dirs were provided and GITHUB_EVENT_BEFORE/GITHUB_SHA are unavailable."
    echo "Pass skills/<name> explicitly or set TESSL_PUBLISH_ALL=true."
    exit 1
  fi

  while IFS= read -r dir; do
    plugin_dirs+=("$dir")
  done < <(
    git diff --name-only "$GITHUB_EVENT_BEFORE" "$GITHUB_SHA" -- skills |
      awk -F/ 'NF >= 2 { print $1 "/" $2 }' |
      sort -u
  )
fi

if [[ "${#plugin_dirs[@]}" -eq 0 ]]; then
  echo "No changed plugins to publish."
  exit 0
fi

for plugin_dir in "${plugin_dirs[@]}"; do
  if [[ ! -f "$plugin_dir/.tessl-plugin/plugin.json" ]]; then
    echo "Skipping $plugin_dir: missing .tessl-plugin/plugin.json"
    continue
  fi

  echo "== tessl plugin lint: ${plugin_dir#skills/} =="
  npx "tessl@$tessl_version" plugin lint "$plugin_dir"

  echo "== tessl plugin publish: ${plugin_dir#skills/} =="
  npx "tessl@$tessl_version" plugin publish "${publish_args[@]}" "$plugin_dir"
done
