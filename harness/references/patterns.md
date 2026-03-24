# Harness Patterns by Project Type

Concrete patterns for common project types. All examples use placeholder boot commands — substitute your project's actual tool (npm scripts, cargo, mise tasks, just, vite, etc.).

## Boot Scripts

Every project needs a single command to start. The tool doesn't matter — consistency does.

```bash
# Whatever your stack uses:
npm run dev          # Node/frontend
cargo run            # Rust
mise run dev         # mise-managed
just dev             # justfile
docker compose up -d # containerized stack
python -m app        # Python
```

### Init Script

Create a script that boots the app and confirms it's alive before any work begins. Run this at the start of every agent session.

```bash
#!/usr/bin/env bash
# scripts/init.sh — boot and verify
set -euo pipefail

# Start the app (background if needed)
<your-boot-command> &
APP_PID=$!

# Wait for health
for i in $(seq 1 30); do
  curl -sf http://localhost:${PORT:-3000}/health > /dev/null 2>&1 && break
  sleep 1
done

curl -sf http://localhost:${PORT:-3000}/health > /dev/null 2>&1 || {
  echo "ERROR: App failed to start"
  kill $APP_PID 2>/dev/null
  exit 1
}

echo "App is ready"
```

## Containerized Stacks

For services with dependencies (DB, Redis, queues, etc.), use Docker Compose.

```yaml
# docker-compose.yml
services:
  app:
    build: .
    ports: ["${PORT:-3000}:3000"]
    depends_on:
      db:
        condition: service_healthy
  db:
    image: postgres:16
    healthcheck:
      test: pg_isready
      interval: 2s
      timeout: 5s
      retries: 10
    environment:
      POSTGRES_PASSWORD: test
```

Boot pattern:
```bash
docker compose up -d --wait  # waits for all health checks
# or:
docker compose up -d && scripts/wait-for-health.sh
```

## Smoke Tests

Fast (< 5 seconds) check that the app is alive. Not user flows — just "did it start."

```bash
# HTTP service
curl -sf http://localhost:3000/health | jq .

# CLI tool
./dist/my-cli --version

# UI app (Playwright)
npx playwright test smoke.spec.ts
# where smoke.spec.ts just checks the page loads:
# test('app loads', async ({ page }) => {
#   await page.goto('http://localhost:3000');
#   await expect(page).toHaveTitle(/.+/);
# });
```

## E2e Tests

Key user flows exercised on the real running app.

### UI (Playwright CLI)
```bash
npx playwright test e2e/
```

### API (curl/httpie)
```bash
# Create → Read → Delete round-trip
ID=$(curl -s -X POST http://localhost:8080/api/v1/items \
  -H "Content-Type: application/json" \
  -d '{"name": "test"}' | jq -r '.id')

curl -s http://localhost:8080/api/v1/items/$ID | jq .

curl -s -X DELETE http://localhost:8080/api/v1/items/$ID
```

### CLI (golden file diff)
```bash
./dist/my-cli process --input fixtures/sample.json --output /tmp/out.json
diff /tmp/out.json fixtures/expected-output.json
```

### SDK / Library (consumer test)
```bash
# Build, then use the artifact as a downstream would
npm run build
node -e "const sdk = require('./dist'); console.log(sdk.version)"
```

## Mechanical Enforcement

### Git Hooks

Commit hooks in `.git-hooks/` and wire via `git config core.hooksPath .git-hooks`

```bash
# .git-hooks/pre-push
#!/usr/bin/env bash
set -euo pipefail
echo "Running lint..."
<your-lint-command>
echo "Running smoke test..."
<your-smoke-command>
```

### CI Gate

Smoke + integration tests must run on every PR. Example (GitHub Actions):

```yaml
# .github/workflows/verify.yml
on: [pull_request]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: <your-boot-command>
      - run: <your-smoke-command>
      - run: <your-test-command>
```

### Custom Lint Rules

Error messages should tell the agent exactly how to fix the issue:

```javascript
// Bad: "Don't use fetch directly"
// Good:
meta: {
  messages: {
    noDirectFetch: 'Use the API client from lib/api instead of fetch(). See docs/api-conventions.md for the pattern.'
  }
}
```

## Seed Data / Fixtures

For APIs and backends, reproducible test state prevents non-deterministic test failures.

```bash
# scripts/seed.sh — reset DB and load test data
<your-db-reset-command>
<your-seed-command>
```

Keep fixture data in `fixtures/` or `test/fixtures/` — version it with the repo

## Per-Worktree Isolation

For parallel agents working on the same repo, each worktree needs its own running instance.

```bash
# Create isolated worktree
git worktree add ../feature-xyz -b feature-xyz origin/main

# Derive port from worktree to avoid collisions
export PORT=$((3000 + $(echo "$PWD" | cksum | cut -d' ' -f1) % 1000))

# For Docker Compose, use worktree-scoped project name
export COMPOSE_PROJECT_NAME="app-$(basename $PWD)"
docker compose up -d --wait
```

Key rules:
- No hardcoded ports in config — use env vars or port derivation
- Each worktree gets its own Docker Compose project (separate containers, networks, volumes)
- Tear down after task completion: `docker compose down -v`

## Observability

```bash
# Structured JSON logs to stdout (parseable by agent)
{"level":"info","ts":"...","msg":"request","method":"GET","path":"/api/items","status":200,"duration_ms":12}

# Health endpoint returning machine-readable status
GET /health → {"status":"ok","version":"1.2.3","uptime":3600}
```
