# Real-World Harness Examples

## Common Traits (the actual patterns)

Every team running agents at scale converges on these:

1. **Single-command boot** — no setup wiki, no "first install X then configure Y"
2. **Real surfaces** — tests hit the actual running app, not mocks
3. **Agent can see results** — screenshots, logs, response bodies available as evidence
4. **Mechanical enforcement** — git hooks, CI gates, and lint rules catch issues before "done"
5. **Isolation** — parallel agents don't step on each other (per-worktree, per-container)
6. **Init before work** — boot + smoke test at the start of every session, preventing "it was already broken"
7. **Separate builder from judge** — the agent that writes code doesn't evaluate its own output

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
