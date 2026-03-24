---
name: harness
description: "Evaluate, set up, and improve a project's agent-testable verification infrastructure. Use when a repo has no bootable dev environment, no integration tests, no interaction layer an agent can use, or when asked for a harness audit or harness grade. Not for per-change verification (use verify for that)."
---

# Harness

Build the verification infrastructure that coding agents use to prove their work.

**Harness builds the tools. Verify uses them.**

## When to Use

- New repo with no dev environment an agent can boot
- Agent can write code but can't see what it built (no screenshots, no DOM inspection, no live endpoint)
- No integration or e2e tests — only mocked unit tests
- `verify` keeps reporting harness gaps it can't fill
- Periodic harness health check or grade requested

## When NOT to Use

- Per-change verification → use `verify`
- Writing application code or features
- Documentation updates → use `docs`

## Workflow

### 1. Evaluate

Inspect the repo and grade the current harness across four dimensions. For each, record `status` (pass / partial / fail), `evidence` (specific file or command), and `gap` (what's missing).

**Bootable** — Can an agent start the app with one command and confirm it's running?

**Testable** — Do tests exercise the real running app, not just mocks? Distinguish:
- *Smoke tests*: app is alive (health endpoint responds, home page loads). Under 5 seconds
- *E2e tests*: key user flows work (Playwright journeys, API round-trips, CLI golden files)
- Detection: check for `jest.mock`, `vi.mock`, `unittest.mock`, `mockery` at test file level. Tests that only exercise mocks score zero for testability

**Observable** — Can the agent query structured logs, health endpoints, or error traces?

**Verifiable** — Can the agent produce evidence (screenshots, response logs, traces) that another agent or human can review?

Grade the project using the scale in `references/grading.md`

### 2. Act

Based on the grade, either set up from scratch or improve what exists:

- **Grade F–D**: Set up. Build the missing foundation in priority order below
- **Grade C+**: Improve. Identify the highest-value gap and implement one improvement per pass

Priority order (each piece should be independently useful — stop after any step if the remaining gaps aren't blocking):

1. **Boot script** — one command to start the app. For complex stacks, use Docker Compose. Create an init script that boots + confirms health before any work begins
2. **Smoke test** — fast check that the app is alive (health endpoint, home page, CLI `--version`)
3. **Interaction layer** — agent can exercise the app:
   - UI: Playwright CLI for automated tests; Playwright MCP when an agent needs interactive navigation and grading
   - APIs: curl/httpie for key endpoints
   - CLIs: shell scripts with golden file assertions
4. **E2e test flows** — executable tests for key user journeys on real surfaces
5. **Mechanical enforcement** — git hooks (`pre-push` running smoke + lint), CI gate (smoke/integration on every PR), custom lint rules with agent-readable error messages
6. **Observability** — structured logs, health endpoints, queryable by agent
7. **Seed data / fixtures** — reproducible test state for APIs and backends

For containerized stacks, see `references/patterns.md` → "Containerized Stacks."
For per-worktree isolation, see `references/patterns.md` → "Per-Worktree Isolation."

### 3. Separate Builder from Judge

Self-evaluation is unreliable. When the project needs quality grading beyond "does it boot":

- Spawn a separate evaluator sub-agent that navigates the running app, screenshots it, and grades against criteria
- The builder agent should never grade its own output
- See `references/examples.md` for the Anthropic evaluator pattern

## Principles

- **The harness matters more than the prompt** — environment > instruction
- **Mechanical enforcement > documentation** — git hooks, CI gates, and lint rules with error messages > rules in AGENTS.md
- **Separate builder from judge** — self-evaluation is unreliable; spawn evaluator sub-agents
- **JSON > Markdown for agent-consumed state** — models corrupt Markdown more than JSON
- **CLI > MCP for standard tools** — more token-efficient, better training data coverage. Exception: use MCP when interactive agent navigation is needed
- **Progressive disclosure** — small entry point + pointers to deeper docs

## References

- `references/grading.md` — harness quality grading scale with mechanical criteria
- `references/patterns.md` — concrete setup patterns by project type
- `references/examples.md` — real-world harness examples (OpenAI, Anthropic)

## Output

After any harness work, report:

- **Grade**: before and after (if changes made)
- **Dimensions**: bootable / testable / observable / verifiable — each with status + evidence
- **What changed**: specific files added or modified
- **Gaps**: remaining gaps ranked by impact
- **Next step**: single highest-value improvement remaining
- **Harness gaps for verify**: what `verify` still can't do after this pass
