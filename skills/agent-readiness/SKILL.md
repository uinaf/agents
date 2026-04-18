---
name: agent-readiness
description: "Audit and build the infrastructure a repo needs so agents can work autonomously — boot scripts, smoke tests, CI/CD gates, dev environment setup, observability, and isolation. Use when a repo can't boot, tests are broken or missing, there's no dev environment, agents can't verify their work, or agents need human help to get anything done. Do not use for reviewing an existing diff or for documentation-only cleanup."
---

# Agent-Readiness

Make a repo ready for autonomous agent work.

## Principles

- **Environment > instruction** — infrastructure matters more than the prompt
- **Mechanical enforcement > prose** — hooks, CI, health checks, and scripts beat wishes
- **Separate builder from judge** — `agent-readiness` builds the rig, `verify` proves your own change, `review` critiques existing code
- **Real behavior > mocked confidence** — smoke, integration, and e2e checks beat large suites that mostly mock the seam under test
- **Smallest useful layer first** — add layers in order, stop when the repo becomes reliably verifiable
- **Progressive disclosure** — keep the core workflow here, load patterns on demand

## Handoffs

- Need to review existing code, a diff, branch, or PR → use `review`
- Need to prove your own completed change works on real surfaces → use `verify`
- Need to update AGENTS.md, README.md, specs, or repo docs → use `docs`

## The 7-Layer Stack

1. **Boot** — single command starts the app
2. **Smoke** — a fast proof the app is alive
3. **Interact** — agent can exercise the real surface
4. **E2e** — key user flows work end to end
5. **Enforce** — hooks, CI gates, lint rules, or mechanical checks
6. **Observe** — logs, health endpoints, traces, machine-readable signals
7. **Isolate** — worktrees or containers do not collide

Concrete examples:

- Boot: `pnpm dev`, `cargo run`, or `docker compose up`
- Smoke: `curl http://127.0.0.1:3000/health`
- Interact/E2e: `pnpm exec playwright test`
- Observe: structured logs or a machine-readable health endpoint

## Workflow

### 1. Audit

Grade the repo across these dimensions:

- **bootable**
- **testable**
- **observable**
- **verifiable**

For each, report:

- status: `pass` / `partial` / `fail`
- evidence: file or command
- gap: what is missing

Use [references/grading.md](references/grading.md). Lowest dimension sets the overall grade.

Example output:

```text
bootable: partial — `pnpm dev` starts the app after manual env setup
testable: fail — only mocked tests under test/
observable: partial — health endpoint exists, structured logs missing
verifiable: fail — no stable smoke or interaction script
overall grade: D
```

### 2. Setup

Build missing layers in this order:

**Boot → Smoke → Interact → E2e → Enforce → Observe → Isolate**

Each step should be independently useful. Stop once the repo is reliably verifiable; do not build a cathedral because you got excited.

When readiness work includes agent entrypoints, keep `AGENTS.md` as the canonical authored guide and place `CLAUDE.md` beside it as a symlink to `AGENTS.md` rather than maintaining two separate guidance files.

**Boot** — create a single-command entry point:

```bash
#!/usr/bin/env bash
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

**Smoke** — fast proof the app is alive (< 5 seconds):

```bash
curl -sf http://localhost:3000/health | jq .   # HTTP service
./dist/my-cli --version                         # CLI tool
npx playwright test smoke.spec.ts               # UI app
```

**Enforce** — pre-push hook to catch failures before CI:

```bash
#!/usr/bin/env bash
# .git-hooks/pre-push
set -euo pipefail
<your-lint-command>
<your-smoke-command>
```

See [references/setup-patterns.md](references/setup-patterns.md) for e2e, observability, isolation, and containerized stack patterns.

### 3. Improve

Tighten weak or flaky layers:

- remove mock-only confidence theater
- prefer smoke, integration, and e2e checks over mock-heavy suites that self-verify implementation details
- replace one-off checks with reusable scripts or hooks
- add dead-code or unused-symbol enforcement where the stack supports it
- add logs and health signals agents can query
- make parallel work safe when agent collisions are real

### 4. Hand Off

When the repo reaches C+ and can be judged honestly, hand off to `verify` or `review`.
If changes created doc drift, hand off to `docs`.

## Anti-Patterns

- **Mock-only tests** — pass by construction, verify nothing
- **Mock-heavy unit suites as the main proof** — agents love them because they are easy to satisfy, not because they prove the system works
- **Self-evaluation** — builder grading its own work
- **Docs-only fixes disguised as readiness work**
- **Routine PR review here** — that's `review`
- **Perfect infrastructure upfront** — iterate from real failure modes

## Output

After readiness work, report:

- grade before and after
- dimensions with evidence
- files changed
- remaining gaps ranked by impact
- verify readiness
- recommended next handoff: `verify`, `review`, `docs`, or human review

## References

- [references/grading.md](references/grading.md) — agent-readiness grading scale with mechanical criteria
- [references/setup-patterns.md](references/setup-patterns.md) — boot, smoke, e2e, observability, and isolation patterns
- [references/industry-examples.md](references/industry-examples.md) — external patterns and justification for readiness investment
