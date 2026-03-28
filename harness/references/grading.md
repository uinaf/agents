# Harness Grading Scale

Grade a project's verification infrastructure from F to A. Mechanical criteria — no subjective judgment.

## Scale

### F — No Harness
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
- Agent can verify *some* things but has blind spots

### B — Solid
- All of C, plus:
- E2e tests cover key user flows on real surfaces (Playwright for UI, API round-trips, golden files for CLIs)
- Smoke tests run in CI on every push/PR
- Git hooks enforce at least lint + smoke before push
- Structured logs or health endpoints exist
- Agent can produce evidence for most changes

### A — Excellent
- All of B, plus:
- Per-worktree or per-container isolation (parallel agents don't collide)
- Custom lint rules with agent-readable error messages that teach how to fix
- Seed data / fixture scripts for reproducible test state
- E2e tests cover error paths and edge cases, not just happy paths
- CI runs full integration suite
- Agent rarely needs human QA

## Example Output

```
Grade: C → B (after adding e2e tests + CI gate)
Layers: 1-4 present, 5 partial, 6-7 missing

Bootable:   pass   — `npm run dev` starts app, health check at :3000/health
Testable:   pass   — 3 Playwright e2e tests hit real UI, 1 API round-trip test
Observable: partial — structured logs exist but no queryable health endpoint
Verifiable: pass   — screenshots captured, response logs saved

Gaps (ranked):
1. No git hooks (layer 5) — lint/smoke not enforced pre-push
2. No structured health endpoint (layer 6) — logs only
3. No worktree isolation (layer 7) — parallel agents would collide

Next step: add pre-push hook with lint + smoke
Confidence: needs review (observable gaps)
```

## Grading Rules

- Grade based on what an agent can actually use, not what exists in theory
- A test suite requiring manual setup to run = grade D, not C
- Mocked unit tests count zero toward testability — detect via mock imports at test file level
- Grade each dimension independently (bootable / testable / observable / verifiable), take the lowest as overall grade
- Cite specific files, commands, or configs as evidence for each grade
