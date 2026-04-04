---
name: harness
description: "Build and improve the verification infrastructure coding agents need to prove their work. Use when: a repo has no bootable dev environment, no real-surface tests, or no interaction layer an agent can use; auditing a repo's agent-readiness; or when verification is blocked by harness gaps. Do not use for routine PR review or documentation-only work."
---

# Harness

Build the verification infrastructure that makes agent work trustworthy.

## Principles

- **Environment > instruction** — the harness matters more than the prompt
- **Mechanical enforcement > prose** — hooks, CI, health checks, and scripts beat wishes
- **Separate builder from judge** — `harness` builds the rig, `verify` uses it
- **Smallest useful harness first** — add layers in order, stop when the repo becomes reliably verifiable
- **Progressive disclosure** — keep the core workflow here, load patterns on demand

## Handoffs

- Need to review a diff, branch, or PR on real surfaces → use `verify`
- Need to update AGENTS.md, README.md, specs, or repo docs → use `docs`

## The 7-Layer Stack

1. **Boot** — single command starts the app
2. **Smoke** — a fast proof the app is alive
3. **Interact** — agent can exercise the real surface
4. **E2e** — key user flows work end to end
5. **Enforce** — hooks, CI gates, lint rules, or mechanical checks
6. **Observe** — logs, health endpoints, traces, machine-readable signals
7. **Isolate** — worktrees or containers do not collide

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

### 2. Setup

Build missing layers in this order:

**Boot → Smoke → Interact → E2e → Enforce → Observe → Isolate**

Each step should be independently useful. Stop once the repo is reliably verifiable; do not build a cathedral because you got excited.

### 3. Improve

Tighten weak or flaky layers:

- remove mock-only confidence theater
- replace one-off checks with reusable scripts or hooks
- add logs and health signals agents can query
- make parallel work safe when agent collisions are real

### 4. Hand Off

When the repo reaches C+ and can be judged honestly, hand off to `verify`.
If harness changes created doc drift, hand off to `docs`.

## Anti-Patterns

- **Mock-only tests** — pass by construction, verify nothing
- **Self-evaluation** — builder grading its own work
- **Docs-only fixes disguised as harness work**
- **Routine PR review here** — that's `verify`
- **Perfect harness upfront** — iterate from real failure modes

## Output

After harness work, report:

- grade before and after
- dimensions with evidence
- files changed
- remaining gaps ranked by impact
- verify readiness
- recommended next handoff: `verify`, `docs`, or human review

## References

- [references/grading.md](references/grading.md) — harness quality grading scale with mechanical criteria
- [references/setup-patterns.md](references/setup-patterns.md) — boot, smoke, e2e, observability, and isolation patterns
- [references/industry-examples.md](references/industry-examples.md) — external patterns and justification for harness investment
