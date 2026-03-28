---
name: harness
description: "Build and use the verification infrastructure coding agents need to prove their work. Use when: a repo has no bootable dev environment, no real-surface tests, or no interaction layer an agent can use; auditing or grading a repo's agent-readiness; verifying changes work end to end on real surfaces; or when harness gaps block reliable agent output."
---

# Harness

The verification infrastructure that makes agent work trustworthy.

## Principles

- **Environment > instruction** — the harness matters more than the prompt
- **Mechanical enforcement > documentation** — git hooks and CI gates > prose
- **Separate builder from judge** — self-evaluation is unreliable; spawn independent evaluators
- **Deterministic where possible** — lint/format/push hardcoded, implementation agentic
- **Context is a public good** — push knowledge into the repo; what agents can't access doesn't exist
- **Scoped rules over global rules** — per-directory/file-pattern rules, not a global dump
- **Progressive disclosure** — small entry points, load detail on demand
- **Accept and correct > prevent all errors** — small steady error rate with rapid correction beats perfection-seeking that serializes everything

## The 7-Layer Stack

Every harness has these layers. Name them when grading — "we have layers 1-3, missing 4-7":

1. **Boot** — single command starts the app
2. **Smoke** — app is alive (health endpoint, `--version`). Under 5 seconds
3. **Interact** — agent can exercise the app (Playwright, curl, shell scripts)
4. **E2e** — key user flows on real surfaces (not mocks)
5. **Enforce** — git hooks, CI gates, custom lint rules with agent-readable errors
6. **Observe** — structured logs, health endpoints, error traces queryable by agent
7. **Isolate** — per-worktree or per-container, parallel agents don't collide

## Workflow

### 1. Audit

Grade the repo across four dimensions. For each: `status` (pass/partial/fail), `evidence` (file or command), `gap` (what's missing).

- **Bootable** — one command starts the app and confirms it's running
- **Testable** — tests hit the real running app, not just mocks. Detect `jest.mock`/`vi.mock`/`unittest.mock` — mock-only = zero
- **Observable** — structured logs, health endpoints, or error traces queryable by agent
- **Verifiable** — agent can produce evidence (screenshots, response logs, traces)

Use parallel subagents where available (one per dimension); otherwise audit sequentially. Grade using `references/grading.md`. Lowest dimension = overall grade.

### 2. Setup

Based on grade, build missing layers in priority order:

**Boot → Smoke → Interact → E2e → Enforce → Observe → Isolate**

Each piece should be independently useful. Stop after any step if remaining gaps aren't blocking. See `references/setup-patterns.md` for concrete patterns by project type.

### 3. Verify

Prove changes work on real surfaces. The agent that wrote the code must not verify it — spawn an independent evaluator. If subagents are unavailable, use a fresh session or hand off to human review. Do not self-certify with implementation context still loaded.

- Boot the app, interact with it (Playwright CLI for UI, curl for APIs, CLI invocation)
- Check nearby flows and likely regressions, not just the exact diff
- Investigate anything odd instead of rationalizing it
- Max 2 verification cycles — escalate after that, don't loop
- Keep proof: commands run, screenshots, response logs, traces

For subagent lanes, evaluator pattern, and cost trade-offs: `references/verification.md`

### 4. Document

Keep the repo legible to humans and agents.

- `AGENTS.md` ≈ 100 lines — table of contents, not encyclopedia. Points to `docs/`
- `README.md` — human-facing overview, setup, usage
- Scoped rules per directory/file pattern, not global dump
- Update docs as part of the work, not after. Doc drift = test failure

For AGENTS.md structure, scoped rules, and hygiene: `references/documentation.md`

### 5. Specify (when warranted)

For non-trivial features, write a spec before coding. Not a throwaway PRD — a living contract.

- Define what, why, acceptance criteria, non-goals
- Define conformance tests or acceptance checks — the mechanical definition of "done"
- Get human approval on spec before implementation when scope is non-trivial
- Break into testable tasks
- Capture decisions during implementation and flow them back to the spec
- Reconcile spec ↔ code ↔ tests after implementation

For the SDD triangle, conformance tests, and the 70/30 rule: `references/specifications.md`

## Anti-Patterns

- **Mock-only tests** — pass by construction, verify nothing
- **Self-evaluation** — agent grades own work, always passes
- **Global AGENTS.md dump** — fills context before work starts
- **Infinite retry loops** — max 2 CI rounds, then hand back with partial result
- **All-agentic pipeline** — lint/push/format should be deterministic
- **Context flooding** — running full test suites floods context, agent hallucinates. Run targeted subsets, swallow passing output, surface only errors
- **Designing the perfect harness upfront** — iterate from failures, not theory

## Output

After any harness work, report:

- **Grade**: before and after (using `references/grading.md` scale)
- **Dimensions**: bootable / testable / observable / verifiable — each with status + evidence
- **What changed**: specific files added or modified
- **Gaps**: remaining gaps ranked by impact
- **Verify readiness**: C+ = can verify, D/F = fix harness first
- **Confidence**: `ship it` / `needs review` / `blocked`

## References

- `references/grading.md` — harness quality grading scale with mechanical criteria
- `references/setup-patterns.md` — boot, smoke, e2e, isolation, enforcement patterns
- `references/verification.md` — verify workflow, evaluator pattern, subagent lanes, cost
- `references/documentation.md` — AGENTS.md rules, scoped rules, README patterns, docs hygiene
- `references/specifications.md` — SDD triangle, conformance tests, acceptance criteria
- `references/industry-examples.md` — OpenAI, Anthropic, Stripe, Uber, Datadog, Cursor patterns. Read when designing a harness strategy or justifying investment, not during routine work

Each reference file includes source URLs for the research and articles it draws from.
