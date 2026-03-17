#!/bin/sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
cd "$ROOT_DIR"

PATTERN='(\]\((/Users/|/private/|file://|vscode://))|(<(file://|vscode://))'

if rg -n --glob '*.md' "$PATTERN" .; then
  echo >&2
  echo "Absolute local links are not allowed in checked-in Markdown." >&2
  echo "Use repo-relative links for local docs and references instead." >&2
  exit 1
fi

echo "No absolute local Markdown links found."
