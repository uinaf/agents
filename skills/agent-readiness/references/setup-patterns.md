# Setup Patterns

Concrete patterns for building each readiness layer. Substitute your project's actual tools.

## Sources

- Stripe devboxes + blueprints: https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents
- Anthropic init pattern: https://www.anthropic.com/engineering/harness-design-long-running-apps
- Datadog DST + observability: https://www.datadoghq.com/blog/ai/harness-first-agents/
- Ona (infrastructure thesis): https://ona.com/stories/visual-guide-self-driving-codebases
- Ramp sandbox architecture: https://engineering.ramp.com/inspect
- Codex app worktrees and `.worktreeinclude`: https://developers.openai.com/codex/app/worktrees
- Claude Code worktrees and `.worktreeinclude`: https://code.claude.com/docs/en/worktrees

## Contents

- [Boot Scripts](#boot-scripts)
- [Containerized Stacks](#containerized-stacks)
- [Smoke Tests](#smoke-tests)
- [E2e Tests](#e2e-tests)
- [Canonical Local Gate](#canonical-local-gate)
- [Mechanical Enforcement](#mechanical-enforcement)
- [Tool Version Ownership](#tool-version-ownership)
- [Observability](#observability)
- [Seed Data / Fixtures](#seed-data--fixtures)
- [Per-Worktree Isolation](#per-worktree-isolation)
- [Unattended Run Constraints](#unattended-run-constraints)
- [Deterministic vs Agentic Split](#deterministic-vs-agentic-split)
- [Retry Caps](#retry-caps)

## Boot Scripts

Every project needs a single command to start. The tool doesn't matter — consistency does.

### Init Script

Boot the app and confirm it's alive. Run at the start of every agent session.

```bash
#!/usr/bin/env bash
# scripts/init.sh
set -euo pipefail
<your-boot-command> &
APP_PID=$!
for i in $(seq 1 30); do
  curl -sf http://localhost:${PORT:-3000}/health > /dev/null 2>&1 && break
  sleep 1
done
curl -sf http://localhost:${PORT:-3000}/health > /dev/null 2>&1 || {
  echo "ERROR: App failed to start"; kill $APP_PID 2>/dev/null; exit 1
}
echo "App is ready"
```

## Containerized Stacks

For services with dependencies (DB, Redis, queues), use Docker Compose with health checks:

```yaml
services:
  app:
    build: .
    ports: ["${PORT:-3000}:3000"]
    depends_on:
      db: { condition: service_healthy }
  db:
    image: postgres:16
    healthcheck:
      test: pg_isready
      interval: 2s
      timeout: 5s
      retries: 10
```

Boot: `docker compose up -d --wait`

## Smoke Tests

Fast (< 5 seconds) check that the app is alive. Not user flows — just "did it start."

```bash
# HTTP service
curl -sf http://localhost:3000/health | jq .

# CLI tool
./dist/my-cli --version

# UI app (Playwright)
npx playwright test smoke.spec.ts

# Static/deploy-only repo
test -f dist/index.html
wrangler deploy --dry-run
```

## E2e Tests

Key user flows on the real running app.

- **UI**: `npx playwright test e2e/`
- **API**: Create → Read → Delete round-trips with curl/httpie
- **CLI**: Golden file diffs (`diff output.json expected.json`)
- **SDK/Library**: Build, then use the artifact as a downstream consumer would

Prefer these over large suites of unit tests that mock the seam under change. For agent verification, one honest integration or e2e check is usually worth more than many self-verifying mocked tests.

## Canonical Local Gate

Every repo should expose one checked-in command an agent can run before push. It should be fast enough for normal iteration and close enough to CI to catch routine failures locally.

Good command shapes:

```bash
make verify
just verify
./scripts/verify.sh
pnpm verify
cargo xtask verify
go run ./cmd/verify
```

Default contents:

- lint, format check, typecheck, or static analysis
- build or package check when the repo ships an artifact
- smoke or integration proof that exercises a real process or real built output
- secret scan or dependency audit when the repo handles credentials or release infrastructure

If full CI is slow, split the contract:

```bash
make verify          # normal pre-push gate
make verify-full     # slower full suite for release or risky work
```

CI and hooks should call the same local gate when practical. If CI cannot call it directly, document the equivalence so agents can trust local proof before opening a PR.

## Mechanical Enforcement

### Git Hooks

```bash
# .git-hooks/pre-push
#!/usr/bin/env bash
set -euo pipefail
<your-local-gate-command>
```

Wire: `git config core.hooksPath .git-hooks`

### CI Gate

Smoke + integration on every PR:

```yaml
# .github/workflows/verify.yml
on: [pull_request]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<full-sha> # v6.x.y
      - run: <your-boot-command>
      - run: <your-smoke-command>
      - run: <your-test-command>
```

### Unused-Code Checks

Add dead-code and unused-symbol checks when the stack supports them. These tools are cheap, deterministic, and good at catching stale scaffolding that agents leave behind.

```bash
# TypeScript / JavaScript
npx knip

# Go
staticcheck ./...
```

For Go repos using `golangci-lint`, enable the unused and dead-code style analyzers there instead of inventing a separate wrapper.

### Custom Lint Rules

Error messages should tell the agent how to fix the issue:

```javascript
meta: {
  messages: {
    noDirectFetch: 'Use the API client from lib/api instead of fetch(). See docs/api-conventions.md'
  }
}
```

Prefer mechanical checks for error-handling hygiene when the stack supports them:

- no empty catches
- no broad catch-and-ignore handlers
- stable error codes or tagged variants for public interfaces
- user-facing error text that suggests a recovery step when one exists

## Tool Version Ownership

When adding CI, hooks, or bootstrap scripts, keep tool versions in one checked-in owner:

- Node in `.node-version`; CI reads it with `node-version-file` when the action supports it
- Package managers in `package.json#packageManager`; avoid separate `pnpm@...` or `corepack prepare ...@...` literals unless the repo cannot consume `packageManager`
- Tool wrappers in package metadata or a workspace catalog; if workflow input needs the version, read it with a structured tool such as `jq` instead of copying the literal
- GitHub Action SHA pins and same-line action version comments are not project tool versions; keep them explicit and Dependabot-managed

## Observability

Structured JSON logs + machine-readable health endpoints. This is what makes "Grade B" possible — agents can query results, not just read code.

```bash
# Structured log line
{"level":"info","ts":"...","msg":"request","method":"GET","path":"/api/items","status":200,"duration_ms":12}

# Health endpoint
GET /health → {"status":"ok","version":"1.2.3","uptime":3600}
```

Datadog's insight: observability isn't just for production. Wire it into the dev environment so agents can verify behavior through telemetry, not just test assertions.

## Seed Data / Fixtures

Reproducible test state prevents non-deterministic failures:

```bash
# scripts/seed.sh
<your-db-reset-command>
<your-seed-command>
```

Keep fixtures in `fixtures/` or `test/fixtures/` — version with the repo.

## Per-Worktree Isolation

For parallel agents on the same repo:

```bash
git worktree add ../feature-xyz -b feature-xyz origin/main
export PORT=$((3000 + $(echo "$PWD" | cksum | cut -d' ' -f1) % 1000))
export COMPOSE_PROJECT_NAME="app-$(basename $PWD)"
docker compose up -d --wait
```

Rules: no hardcoded ports, each worktree gets its own Docker Compose project, tear down after completion.

### Worktree Include Files

Codex app managed worktrees and Claude Code worktrees can copy required gitignored local files from the repository root with `.worktreeinclude`.

Use this when agents can create or enter worktrees but then fail because ignored local setup files are missing, such as `.env.local`, a local tool config, or a dev-only secrets file. Keep the file small:

```gitignore
# .worktreeinclude
.env.local
config/dev-secrets.json
```

Audit rules:

- Patterns use `.gitignore` syntax and should name specific paths whenever possible.
- Only include files that are already ignored by Git; tracked files are already present in the checkout.
- Do not include broad patterns such as `*`, `.env*`, `secrets/`, caches, build output, dependencies, or machine-global config.
- If the project should fetch secrets from Infisical, CI, or a setup script, document that path instead of copying a local secret file.
- Pair `.worktreeinclude` with `.gitignore`; adding one without the other is usually a readiness gap.
- Codex processes `.worktreeinclude` for local Codex-managed app worktrees, not remote worktrees or worktrees created manually with Git.
- Claude Code processes `.worktreeinclude` for default `--worktree`, subagent worktrees, and desktop parallel sessions.
- For custom Claude `WorktreeCreate` hooks or manual `git worktree add`, do not assume `.worktreeinclude` is processed. Copy required files in the hook or setup script instead.

## Unattended Run Constraints

Agent-ready checks should keep working after the user closes a terminal, browser tab, or laptop. Prefer scripts, CI jobs, or remote runners with explicit timeouts, cleanup, and artifact paths.

Minimum useful contract:

- `timeout` or CI job timeout limits wall-clock time
- logs and screenshots land under a checked or documented artifact directory
- cleanup runs on success and failure
- expensive paths document their resource class, parallelism, or expected runtime
- credentials are scoped to the task and enforced by the runtime environment

Avoid verification paths that require clicking dashboards, approving prompts mid-run, or watching a local session stay alive.

## Deterministic vs Agentic Split

**Always deterministic** (hardcoded, no LLM): linting, formatting, branch creation, push, PR template, test runner invocation, Docker startup.

**Agentic** (LLM decides): understanding the task, implementation, fixing failures, deciding which files to change.

This split saves tokens, reduces errors, and guarantees critical steps happen every time.

## Stop Hooks / Back-Pressure

Run targeted checks when the agent finishes a task — before commit, not just in CI. Silent on success, error-only on failure to avoid context flooding.

```bash
# .git-hooks/pre-commit or agent stop hook
set -euo pipefail
<your-typecheck-command> >/dev/null 2>&1 || <your-typecheck-command> 2>&1 | tail -20
<your-targeted-test-command> >/dev/null 2>&1 || <your-targeted-test-command> 2>&1 | tail -20
```

Pattern: run silently, only show output on failure. Run only tests related to changed files, not the full suite. Most test runners support file-pattern filtering.

## Retry Caps

Max 2 CI rounds. No infinite loops.

```
1. Agent implements change
2. Local lint + smoke (deterministic, < 5 seconds)
3. Push to CI — autofix known patterns on failure
4. One more attempt if unfixed
5. After 2nd CI failure → hand back to human
```

A PR that's 80% correct and an engineer polishes in 20 minutes > an agent retrying indefinitely at escalating token cost.
