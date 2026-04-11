# Verification

Prove your own changes work on real surfaces. The agent that wrote the code must not verify it in the same context.

## Sources

- Anthropic evaluator pattern: https://www.anthropic.com/engineering/harness-design-long-running-apps
- Anthropic PR review toolkit (agent-per-concern): https://github.com/anthropics/claude-code/tree/main/plugins/pr-review-toolkit/agents
- OpenAI Codex subagents: https://developers.openai.com/codex/concepts/subagents
- HumanLayer context flooding: https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents
- Datadog verification pyramid: https://www.datadoghq.com/blog/ai/harness-first-agents/
- Context rot research: https://research.trychroma.com/context-rot

## Contents

- [Before You Start](#before-you-start)
- [Checks](#checks)
- [Evaluator Pattern](#evaluator-pattern)
- [Check Selection](#check-selection)
- [Model Selection](#model-selection)
- [Cost Awareness](#cost-awareness)

## Before You Start

1. Check harness grade: C+ = proceed. D/F = invoke harness setup first
2. Can you boot the app?
3. Can you interact with it? (Playwright CLI for UI, curl for APIs, CLI invocation)
4. Can you verify your own work from a fresh evaluator context or separate subagent?
5. If not, flag as a harness gap — don't improvise a one-off check

## Checks

### Real Surface
- Run the shipped CLI, service, or UI flow with representative inputs
- For UI: Playwright CLI or CDP — inspect behavior, structure, legibility, responsiveness
- For services: hit the real local endpoint, confirm full round trip

### Deterministic Guardrails
- Run the repo's built-in verify entrypoint first when it exists
- Prefer targeted checks over full-suite context floods during iteration
- If a deterministic check fails, fix that failure before claiming runtime success

### External Contracts
- Verify field names, enums, response shapes against docs or real responses
- Can't verify a contract detail? Stop and surface the gap

### State and Config
- Verify public interfaces end to end
- Verify persistence/state round trips with real data
- Verify config changes by starting the program with the new config

### CI Integration
- If the project has CI, push and wait for results before declaring done
- CI failures after verify = verify missed something. Investigate

### Smell Test
- Check outputs look plausible to a human
- **Investigate anything odd instead of rationalizing it** — this is the specific failure mode
- Look for: unexpected empty states, wrong user names, stale data, truncated responses, hardcoded test values in production output

### Proof of Work
- Query structured logs, health endpoints, error traces
- Keep screenshots, response logs, traces, sample responses
- Evidence should be reproducible — include exact commands

## Evaluator Pattern

Anthropic's GAN-inspired approach: separate generation from evaluation entirely.

**Three roles**: Planner → Generator → Evaluator
- **Evaluator** is always independent from the builder
- Uses Playwright/CDP, curl, or the shipped CLI to inspect the live result
- Can reject work and send it back with specific feedback
- Success criteria are defined before running the check

**Why it works**: LLMs are terrible self-evaluators — they confidently praise mediocre work. Tuning a standalone evaluator to be skeptical is far more tractable than making a generator self-critical.

**When to use**: complex features, subjective quality, UI work. Not for simple CRUD or config changes.

**Evaluator tuning**: out of the box, Claude identifies issues then talks itself into approving. Multiple rounds of prompt tuning needed — read evaluator logs, find judgment divergences from human expectations, update QA prompt.

### Context Flooding Problem

HumanLayer identified this: running a full test suite floods the context window, causing agents to lose track and hallucinate about test files. Verification must be **context-efficient**:

- Swallow passing output, only surface errors
- Run targeted subsets (< 30 seconds), not the full suite every iteration
- Use hooks that run silently on success, exit with error only on failure

## Check Selection

Pick the smallest set of checks that can honestly disprove the change:

- **UI change** → targeted UI flow, screenshot, responsive spot-check, console scan
- **API/backend** → representative request, error request, schema or contract check
- **CLI/tooling** → shipped command invocation, representative args, exit code, stdout/stderr sanity check
- **State/config** → write/read round trip, restart, boot with changed config, migrate existing state
- **Pure refactor** → deterministic tests plus one surface check that proves behavior parity

## Model Selection

Match model capability to lane complexity:

- **Strong reasoning** (e.g. Opus, GPT-5.4): evaluator orchestration, complex UI judgment, contract-sensitive checks
- **Balanced** (e.g. Sonnet, GPT-5.4-mini): targeted runtime checks, API verification, state/config passes
- **Fast/cheap** (e.g. Haiku, flash): repeated smoke checks, screenshot capture, command re-runs

Use your strongest model for planning/orchestration. Use cheaper models for workers and surface checks.

## Cost Awareness

Anthropic's numbers:
- **Solo agent**: $9 / 20 min
- **Full harness (3-agent)**: $200 / 6 hours (22x more)
- **Simplified harness (Opus 4.6)**: $125 / 4 hours

The evaluator is expensive. Use it for:
- Complex features at the model's capability edge
- Subjective quality (UI design, UX flows)
- High-stakes changes where self-evaluation is dangerous

Skip it for:
- Tasks within the model's comfort zone
- Simple CRUD, config, or migration work
- When the harness's deterministic checks (lint, tests, CI) are sufficient

**Key principle**: "Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing." As models improve, simplify the harness.
