# Harness Grading Scale

Grade a project's verification infrastructure from F to A.

## Scale

### F — No Harness
- No dev server or bootable environment
- No tests, or only trivial tests
- Agent cannot run the app at all

### D — Minimal
- App boots with manual steps (multiple commands, env file setup)
- Some unit tests exist but all use mocks
- No integration or e2e tests
- Agent can write code but can't see the result

### C — Functional
- App boots with one command
- Mix of unit tests (mocked) and some integration tests
- No browser automation or visual verification
- Basic observability (console logs, maybe a health endpoint)
- Agent can verify some things but has blind spots

### B — Solid
- App boots reliably, works in clean checkout
- Integration tests hit real surfaces (running app, real API, live DB)
- Browser automation available for UI projects (Playwright, CDP)
- Structured logs, health endpoints
- Agent can produce evidence for most changes
- Key user flows covered by smoke tests

### A — Excellent
- All of B, plus:
- Per-worktree isolation (parallel agents don't collide)
- Custom lint rules with agent-readable error messages
- Automated visual regression or screenshot comparison
- Ephemeral observability per task (logs/metrics torn down after)
- Verification flows cover edge cases, not just happy paths
- Agent rarely needs human QA

## Grading Rules

- Grade based on what an agent can actually use, not what exists in theory
- A test suite that requires manual setup to run counts as D, not C
- Mocked unit tests that pass by construction don't count toward "testable"
- Evidence: cite specific files, commands, or configs backing each grade
