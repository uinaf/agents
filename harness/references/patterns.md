# Harness Patterns by Project Type

Concrete setup patterns for common project types.

## Web App (React, Next.js, Vue, etc.)

### Bootable
```bash
# Makefile or package.json script
make dev        # starts dev server on predictable port
make dev-check  # starts server + waits for health endpoint
```

### Interaction Layer
```bash
# Playwright CLI for smoke tests
npx playwright test smoke.spec.ts --headed=false
```

Key smoke test shape:
```typescript
test('app loads and key flow works', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await expect(page).toHaveTitle(/App/);
  await page.click('[data-testid="main-action"]');
  await expect(page.locator('.result')).toBeVisible();
});
```

### Observability
- `GET /api/health` returning `{ status: "ok", version: "..." }`
- Structured JSON logs to stdout (parseable by agent)

## API / Backend Service

### Bootable
```bash
make serve              # starts the API
make serve-check        # starts + confirms health endpoint responds
```

### Interaction Layer
```bash
# curl scripts for key endpoints
curl -s http://localhost:8080/health | jq .
curl -s -X POST http://localhost:8080/api/v1/resource \
  -H "Content-Type: application/json" \
  -d '{"name": "test"}' | jq .
```

### Verification
- Request/response pairs as test fixtures
- Contract tests against OpenAPI spec if available
- Seed data script for consistent test state

## CLI Tool

### Bootable
```bash
make build && ./dist/my-cli --version
```

### Interaction Layer
```bash
# Smoke test script
./dist/my-cli process --input fixtures/sample.json --output /tmp/out.json
diff /tmp/out.json fixtures/expected-output.json
```

### Verification
- Golden file tests (expected output vs actual output)
- Exit code verification
- stderr/stdout capture and assertion

## SDK / Library

### Bootable
```bash
make build && make test   # builds and runs test suite
```

### Interaction Layer
```bash
# Consumer test — use the built artifact, not source
make build
node -e "const sdk = require('./dist'); console.log(sdk.version)"
```

### Verification Layers
1. **Static**: type check, lint
2. **Unit**: pure logic tests (these can mock)
3. **Integration**: tests against real/local instance of the upstream service
4. **Consumer**: install the built package and use it as a downstream would

## Monorepo

### Bootable
```bash
# Root-level dev command that boots relevant services
make dev                  # boots all services
make dev SERVICE=api      # boots specific service
```

### Per-worktree Isolation
- Each worktree gets its own port range or docker-compose project name
- Use env vars: `PORT_OFFSET`, `COMPOSE_PROJECT_NAME=$WORKTREE_NAME`
- Avoid hardcoded ports in config

### Verification
- Affected-service detection (what changed → what to test)
- Cross-service smoke tests for integration points

## Universal Patterns

### Custom Lint Rules
```javascript
// eslint rule with agent-readable message
module.exports = {
  meta: {
    messages: {
      noDirectApiCall: 'Use the API client from lib/api instead of fetch(). See docs/api-conventions.md for the pattern.'
    }
  }
};
```

Error messages should tell the agent exactly how to fix the issue.

### Progress Tracking (JSON)
```json
{
  "features": [
    { "id": "auth-flow", "status": "done", "verified": true },
    { "id": "dashboard", "status": "in-progress", "verified": false },
    { "id": "settings", "status": "pending", "verified": false }
  ],
  "harness_grade": "C",
  "last_updated": "2026-03-24T18:00:00Z"
}
```

### Makefile Convention
```makefile
# Every project should have these targets
dev:          # Boot the app for development
dev-check:    # Boot + wait for health
test:         # Run all tests
test-smoke:   # Run smoke tests only (fast, real surfaces)
lint:         # Static analysis
verify:       # Full verification pipeline
```
