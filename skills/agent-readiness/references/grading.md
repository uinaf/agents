# Agent-Readiness Grading Scale

Grade a project's readiness for autonomous agent work from F to A. Mechanical criteria — no subjective judgment.

## Scale

### F — Not Ready
- App cannot start without manual multi-step setup (env files, manual installs, wiki)
- Zero tests, or only trivial tests that import nothing from the app
- Agent cannot run the app at all

### D — Minimal
- App starts but requires more than one command or manual env config
- Tests exist but all use mocks (`jest.mock`, `vi.mock`, `unittest.mock`) — zero tests hit a running process
- No smoke test, no health endpoint
- Agent can write code but can't see results

### C — Functional
- App boots with one command
- At least one smoke test confirms app is alive (health endpoint, home page, `--version`)
- At least one test hits a real running process — even a single curl check counts
- A local verification command exists or the missing command is the main verifiability gap
- Agent can verify *some* things but has blind spots

### B — Solid
- All of C, plus:
- E2e tests cover key user flows on real surfaces (Playwright for UI, API round-trips, golden files for CLIs)
- Smoke tests run in CI on every push/PR
- Git hooks enforce the local verification command or the same lint + smoke checks before push
- Structured logs or health endpoints exist
- Verification writes inspectable artifacts or logs in predictable paths
- Long-running checks have explicit timeout, cleanup, and resource bounds
- Agent can produce evidence for most changes

### A — Excellent
- All of B, plus:
- Per-worktree or per-container isolation (parallel agents don't collide)
- Required gitignored local config is handled by `.worktreeinclude`, setup scripts, or worktree hooks without broad secret/cached-file copying
- Agent runs are independent of a developer's live terminal, browser tab, or laptop session
- Custom lint rules with agent-readable error messages that teach how to fix
- Seed data / fixture scripts for reproducible test state
- E2e tests cover error paths and edge cases, not just happy paths
- CI runs full integration suite
- Permissions are enforced by infrastructure (sandbox, CI environment, scoped tokens), not runtime prompt approval
- Agent rarely needs human QA

## Example Output

```
- grade: C → B after adding e2e tests and a CI gate
- layers: 1-4 present, 5 partial, 6-7 missing
- bootable: pass — dev server starts and health check responds
- testable: pass — e2e covers real UI and one API round trip
- observable: partial — structured logs exist, queryable health endpoint missing
- verifiable: pass — screenshots and response logs are captured
- gaps: pre-push enforcement missing; health endpoint missing; worktree isolation missing
- next: add pre-push hook with lint and smoke
```

## Grading Rules

- Grade based on what an agent can actually use, not what exists in theory
- A test suite requiring manual setup to run = grade D, not C
- CI-only checks without a local command agents can run before push are a verifiability gap
- A mock-only suite cannot establish C-grade testability because it never exercises a real process or boundary. Mocked unit tests may still prove isolated logic; count them as supporting evidence, not real-surface readiness proof
- Do not infer that an entire test file is worthless from one mock import or delete useful unit tests merely to raise the readiness grade
- Grade each dimension independently (bootable / testable / observable / verifiable), take the lowest as overall grade
- Treat user-session dependence, dashboard-only verification, unbounded cost, or prompt-only permissions as explicit autonomy gaps
- Cite specific files, commands, or configs as evidence for each grade
