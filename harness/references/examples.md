# Real-World Harness Examples

## Common Traits (the actual patterns)

Every team running agents at scale converges on these:

1. **Single-command boot** — no setup wiki, no "first install X then configure Y"
2. **Real surfaces** — tests hit the actual running app, not mocks
3. **Agent can see results** — screenshots, logs, response bodies available as evidence
4. **Mechanical enforcement** — git hooks, CI gates, and lint rules catch issues before "done"
5. **Deterministic + agentic split** — lint/push/format are hardcoded, implementation is agentic
6. **Isolation** — parallel agents don't step on each other (per-worktree, per-container)
7. **Init before work** — boot + smoke test at the start of every session, preventing "it was already broken"
8. **Separate builder from judge** — the agent that writes code doesn't evaluate its own output
9. **Hard retry cap** — max 2 CI rounds, then hand back. Partial success > infinite retry
10. **Scoped rules** — rules attached per subdirectory/file pattern, not global dump

## OpenAI — Codex Frontend

3 engineers, ~1500 PRs, ~1M LOC, 3.5 PRs/engineer/day. Zero lines of manually-written code.

- Per-worktree bootable app — each change gets its own running instance
- CDP (Chrome DevTools Protocol) wired into agent runtime — DOM snapshots, screenshots, navigation
- Ephemeral observability per worktree — logs, metrics, traces torn down after task
- Golden principles as mechanical lints — custom linters with error messages that inject remediation into agent context
- Rigid architectural layers mechanically enforced (Types → Config → Repo → Service → Runtime → UI)

Key lesson: AGENTS.md as table of contents (~100 lines), not encyclopedia. "We tried the big AGENTS.md. It failed."

Source: https://openai.com/index/harness-engineering/

## Anthropic — Evaluator Pattern (GAN-inspired)

Three-agent pattern: Planner → Generator → Evaluator.

- **Evaluator is a separate agent** that uses Playwright MCP to navigate the live app, screenshot it, and grade against criteria
- Sprint contracts negotiated between generator and evaluator before coding
- Evaluation criteria: design quality, originality, craft, functionality (weighted)
- The evaluator can reject work and send it back with specific feedback

This is the concrete implementation of "separate builder from judge." The evaluator agent:
1. Boots the app
2. Navigates key flows with Playwright
3. Takes screenshots
4. Grades against predefined criteria
5. Returns pass/fail with evidence

Source: https://www.anthropic.com/engineering/harness-design-long-running-apps

## Anthropic — Two-Agent Init Pattern

Initializer + Coding agent, incremental per session.

- Initializer sets up env, creates feature list (as JSON), writes init.sh
- Every session: run init.sh (boot + smoke), read progress file, pick next feature, work, commit
- Progress file + git history give each session full context without re-evaluation

Key lesson: init.sh + smoke test before every session prevents "it was already broken" failures. This is the simplest, most portable pattern — works in any stack.

## Stripe — Minions (1,300+ PRs/week, zero human-written code)

Fully unattended agents. Engineer sends Slack message, walks away, comes back to finished PR.

- **Devboxes**: cloud machines pre-loaded with codebase, 10-second spin-up via warm pool. QA-isolated, no confirmation prompts. Built for humans years before LLMs — agents just slotted in
- **Blueprints**: hybrid orchestration mixing deterministic nodes (lint, push, PR template) with agentic nodes (implement, fix CI). "Putting LLMs into contained boxes compounds into reliability"
- **Scoped rules**: global rules used "very judiciously." Almost all rules scoped to subdirectories/file patterns, auto-attached as agent navigates. Same rules for Minions, Cursor, Claude Code — no duplication
- **Feedback loops**: pre-push lint < 5 seconds (background daemon precomputes), then selective CI from 3M+ tests with autofixes, max 2 CI rounds then hand back to human
- **Partial success**: "A not-entirely-correct minion run is often still an excellent starting point"
- **Toolshed**: centralized MCP server with ~500 tools. Agents get curated subsets, not kitchen sink

Key lesson: "Investments in human developer productivity over time have returned to pay dividends in the world of agents." The infra that made humans productive is exactly what made agents possible.

Sources: https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents (Part 1 & 2)
