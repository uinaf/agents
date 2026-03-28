#!/usr/bin/env bash
set -euo pipefail
node src/index.js &
PID=$!
sleep 2
curl -sf http://localhost:3456/health | grep -q ok
echo "Smoke passed"
kill $PID
