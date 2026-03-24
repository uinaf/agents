# Harness Grading Scale

Grade a project's verification infrastructure from F to A. Each grade has mechanical criteria — no subjective judgment.

## Scale

### F — No Harness
- App cannot start without manual multi-step setup (env files, manual installs, wiki instructions)
- Zero tests, or only trivial tests that import nothing from the app
- Agent cannot run the app at all

### D — Minimal
- App starts but requires more than one command or manual env configuration
- Tests exist but all use mocks (`jest.mock`, `vi.mock`, `unittest.mock`, etc.) — zero tests hit a running process
- No smoke test, no health endpoint
- Agent can write code but has no way to see results

### C — Functional
- App boots with one command (any tool: npm scripts, cargo, mise, just, Docker Compose, etc.)
- At least one smoke test confirms the app is alive (health endpoint, home page load, CLI `--version`)
- At least one test hits a real running process (not a mock) — even a single curl check counts
- Agent can verify *some* things but has blind spots

### B — Solid
- All of C, plus:
- E2e tests cover key user flows on real surfaces (Playwright for UI, API round-trips for backends, golden file diffs for CLIs)
- Smoke tests run in CI on every push/PR
- Git hooks enforce at least lint + smoke before push
- Structured logs or health endpoints exist
- Agent can produce evidence (screenshots, response logs, traces) for most changes

### A — Excellent
- All of B, plus:
- Per-worktree or per-container isolation (parallel agents don't collide)
- Custom lint rules with agent-readable error messages that teach how to fix
- Seed data / fixture scripts for reproducible test state
- E2e tests cover error paths and edge cases, not just happy paths
- CI runs full integration suite, not just smoke
- Agent rarely needs human QA

## Grading Rules

- Grade based on what an agent can actually use, not what exists in theory
- A test suite that requires manual setup to run is grade D, not C
- Mocked unit tests that pass by construction count zero toward testability — detect via mock imports at test file level
- Grade each dimension independently (bootable / testable / observable / verifiable), then take the lowest as the overall grade
- Cite specific files, commands, or configs as evidence for each grade
