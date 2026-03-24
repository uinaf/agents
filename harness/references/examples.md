# Real-World Harness Examples

Existence proofs from teams running agents at scale.

## OpenAI — Codex Frontend (0 lines of manually-written code)

**Setup**: 3 engineers, ~1500 PRs, ~1M LOC, 3.5 PRs/engineer/day

**Harness:**
- Per-worktree bootable app — each change gets its own running instance
- CDP (Chrome DevTools Protocol) wired into agent runtime — DOM snapshots, screenshots, navigation
- Ephemeral observability per worktree — logs, metrics, traces torn down after task
- Golden principles as mechanical lints — custom linters with error messages that inject remediation into agent context
- Rigid architectural layers (Types → Config → Repo → Service → Runtime → UI) mechanically enforced

**Key lesson:** AGENTS.md as table of contents (~100 lines), not encyclopedia. "We tried the big AGENTS.md. It failed."

Source: https://openai.com/index/harness-engineering/

## Anthropic — Long-Running Agent Apps (GAN-inspired)

**Setup**: Three-agent pattern: Planner → Generator → Evaluator

**Harness:**
- Evaluator uses Playwright MCP to navigate live app, screenshot, grade against criteria
- Sprint contracts negotiated between generator and evaluator before coding
- Init.sh + smoke test before any new work — start dev server, Puppeteer smoke test
- Feature list as JSON (not Markdown) — models less likely to corrupt structured data
- Progress file + git history — each session reads progress, picks next feature

**Key lesson:** Separating builder from judge is the single biggest lever. Self-evaluation is unreliable.

Source: https://www.anthropic.com/engineering/harness-design-long-running-apps

## Anthropic — Two-Agent Pattern

**Setup**: Initializer + Coding agent (incremental per session)

**Harness:**
- Initializer sets up env, feature list, init.sh
- Coding agent reads progress, picks next feature, commits descriptively
- Browser automation for e2e — "Providing Claude with testing tools dramatically improved performance"
- Communication via files — agents write/read files to coordinate

**Key lesson:** Init.sh + smoke test before every session prevents "it was already broken" failures.

## Common Traits Across All

1. **Single-command boot** — no setup wiki, no "first install X then configure Y"
2. **Real surfaces** — tests hit the actual running app, not mocks
3. **Agent can see results** — screenshots, logs, response bodies available as evidence
4. **Mechanical enforcement** — lints and checks catch issues before the agent claims "done"
5. **Isolation** — parallel agents don't step on each other (per-worktree or per-container)
