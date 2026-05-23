---
name: agent-readiness
description: "Audit and build the infrastructure a repo needs so agents can work autonomously — boot scripts, smoke tests, CI/CD gates, dev environment setup, observability, and isolation. Use when a repo can't boot, tests are broken or missing, there's no dev environment, agents can't verify their work, or agents need human help to get anything done. Do not use for reviewing an existing diff or for documentation-only cleanup."
---

# Agent-Readiness

Make a repo ready for autonomous agent work by adding mechanical proof: boot scripts, smoke checks, CI/hooks, observable signals, and isolation where needed. Add the smallest useful layer first; stop once the repo is reliably verifiable.

## Boundaries

- Existing code, diff, branch, or PR review is out of scope.
- Completed product changes need their own runtime proof pass.
- AGENTS.md, README.md, specs, or repo docs are documentation work unless they support readiness infrastructure.
- Mock-only tests, docs-only cleanup, and builder self-evaluation are not readiness proof.

## The 7-Layer Stack

1. **Boot** — single command starts the app
2. **Smoke** — a fast proof the app is alive
3. **Interact** — agent can exercise the real surface
4. **E2e** — key user flows work end to end
5. **Enforce** — one local gate plus hooks, CI gates, lint rules, or mechanical checks
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
- evidence: file, check outcome, or runtime surface
- gap: what is missing

Use [references/grading.md](references/grading.md). Lowest dimension sets the overall grade.

Also scan unattended-run constraints: session independence, explicit artifact paths, resource bounds, infrastructure-enforced permissions, and direct CLI/HTTP/file interfaces for dashboard-only flows. If these are not needed for the current task, keep them as remaining gaps instead of expanding the scope.

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

Each step should be independently useful. Stop once the repo is reliably verifiable.

Prioritize one canonical local gate (`make verify`, `just verify`, `./scripts/verify.sh`, or equivalent) that agents can run before push. It should mirror meaningful CI checks enough to catch routine failures without opening a dashboard.

When readiness work includes agent entrypoints, keep `AGENTS.md` as the canonical authored guide and place `CLAUDE.md` beside it as a symlink to `AGENTS.md` rather than maintaining two separate guidance files.

See [references/setup-patterns.md](references/setup-patterns.md) for local gates, boot scripts, e2e, observability, isolation, containerized stacks, and tooling-version ownership.

### 3. Improve

Tighten weak or flaky layers:

- remove mock-only confidence theater
- replace one-off checks with a canonical local gate, then reuse it from hooks and CI
- add dead-code or unused-symbol enforcement where the stack supports it
- add logs and health signals agents can query
- make parallel work safe when agent collisions are real

### 4. Stop

When the repo reaches C+ and can be judged honestly, stop readiness work and report the next natural phase.
If changes created doc drift, report the documentation gap instead of expanding the scope.

## Output

After readiness work, report in this compact bullet shape:

- `- grade:` before → after
- `- evidence:` concise explanations of what readiness checks proved
- `- files changed:` changed readiness files
- `- remaining gaps:` highest-impact gaps only, or `none`
- `- next:` runtime proof, independent review, documentation cleanup, human review, or `none`

Keep details compact:

- Put dimension-by-dimension evidence in the audit table when useful, not again in the footer
- Name the command or file that proves the claim and summarize logs by signal
- Keep the footer to 5 labeled lines or fewer
- Omit unchanged dimensions unless they explain the final grade
- Summarize passing checks by intent and result; include full commands only when they failed, are needed for reproduction, or the user asks for them

## References

- [references/grading.md](references/grading.md) — agent-readiness grading scale with mechanical criteria
- [references/setup-patterns.md](references/setup-patterns.md) — local gates, boot, smoke, e2e, observability, and isolation patterns
- [references/industry-examples.md](references/industry-examples.md) — external patterns and justification for readiness investment
