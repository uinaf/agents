---
name: harness
description: "Evaluate, set up, and improve a project's agent-testable verification infrastructure. Use when asked for a harness audit, harness grade, or when a repo lacks bootable dev environment, integration tests, browser automation, or observability. Also use when verification relies on mocks instead of real surfaces. Not for per-change verification (use verify for that)."
---

# Harness

Build the verification infrastructure that coding agents use to prove their work.

**Harness builds the tools. Verify uses them.**

## When to Use

- New repo or project with no dev environment an agent can boot
- Tests exist but are all unit tests with mocks — nothing runs the real app
- Agent can write code but can't see what it built (no screenshots, no DOM inspection)
- `verify` skill keeps reporting gaps it can't fill
- Periodic harness health check requested

## When NOT to Use

- Per-change verification → use `verify`
- Writing application code or features → use the task itself
- Documentation updates → use `docs`

## Workflow

### 1. Evaluate

Inspect the repo and grade the current harness. Answer each question with evidence:

**Bootable?**
- Can the app start with one command? (`make dev`, `npm run dev`, `cargo run`)
- Does it work in a fresh worktree / clean checkout?
- Is there a health check or smoke test that confirms the app is running?

**Testable on real surfaces?**
- Are there integration or e2e tests that hit the running app?
- Can the agent interact with the UI? (Playwright, CDP, curl for APIs)
- What percentage of tests use mocks vs real surfaces?

**Observable?**
- Are there structured logs the agent can query?
- Health endpoints? Metrics?
- Error traces with enough context for diagnosis?

**Verifiable?**
- Are key user flows covered by executable smoke tests?
- Is there a clear definition of "working" beyond "tests pass"?
- Can the agent produce evidence (screenshots, response logs, traces)?

Output a **harness grade** after evaluation. See `references/grading.md` for the scale.

### 2. Set Up

Fill the gaps identified in evaluation. Work in priority order:

1. **Bootable dev environment** — single command to start, works per-worktree
2. **Smoke test** — runs after boot, confirms the app is alive
3. **Interaction layer** — agent can exercise the app (Playwright for UI, curl/httpie for APIs, CLI invocation for CLIs)
4. **Verification flows** — executable tests for key user journeys on real surfaces
5. **Observability** — structured logs, health endpoints, queryable by agent

Prefer tools with broad training data coverage:
- **Playwright CLI** over Playwright MCP (more token-efficient)
- **curl/httpie** over API testing frameworks for simple checks
- **Standard test runners** (vitest, pytest, go test) over custom harnesses

Each piece should be independently useful. Don't build everything at once.

### 3. Improve

For repos that already have partial harness infrastructure:

- Grade current state (step 1)
- Identify the highest-value gap
- Implement one improvement per pass
- Re-grade after implementation

Common improvements:
- Replace mocked tests with live integration tests
- Add Playwright smoke tests for key UI flows
- Add structured logging that agents can grep
- Wire up screenshots/DOM snapshots to verification output
- Create per-worktree isolation (so parallel agents don't collide)
- Add custom lint rules with agent-readable error messages

## Principles

- **The harness matters more than the prompt.** Environment > instruction
- **Mechanical enforcement > documentation.** Lints with error messages > rules in AGENTS.md
- **Separate builder from judge.** Self-evaluation is unreliable
- **JSON > Markdown for agent-consumed state.** Models corrupt Markdown more than JSON
- **CLI > MCP for standard tools.** More token-efficient, better training data coverage
- **Progressive disclosure.** Small entry point + pointers to deeper docs

## References

- `references/grading.md` — harness quality grading scale
- `references/patterns.md` — concrete setup patterns by project type
- `references/examples.md` — real-world harness examples (OpenAI, Anthropic, put.io SDK)

## Output

After any harness work, report:

- **Grade**: before and after (if changes made)
- **What exists**: bootable / testable / observable / verifiable
- **What's missing**: gaps ranked by impact
- **What changed**: specific files added or modified
- **Next step**: single highest-value improvement remaining
