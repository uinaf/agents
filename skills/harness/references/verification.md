# Verification

Prove changes work on real surfaces. The agent that wrote the code must not verify it.

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
- [Subagent Lanes](#subagent-lanes)
- [Choosing Lanes](#choosing-lanes)
- [Model Selection](#model-selection)
- [Cost Awareness](#cost-awareness)

## Before You Start

1. Check harness grade: C+ = proceed. D/F = invoke harness setup first
2. Can you boot the app?
3. Can you interact with it? (Playwright CLI for UI, curl for APIs, CLI invocation)
4. If not, flag as a harness gap — don't improvise a one-off check

## Checks

### Real Surface
- Run the shipped CLI, service, or UI flow with representative inputs
- For UI: Playwright CLI or CDP — inspect behavior, structure, legibility, responsiveness
- For services: hit the real local endpoint, confirm full round trip

### Change Review
- Screenshots are evidence, not the verdict
- Check nearby surfaces and follow-on states, not just the named change
- If the result is weak, fix it and re-run

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

**Three agents**: Planner → Generator → Evaluator
- **Evaluator** is always independent from the builder
- Uses Playwright/CDP to navigate the live app, screenshot it, grade against criteria
- Can reject work and send it back with specific feedback
- Sprint contracts define what "done" looks like before each sprint

**Why it works**: LLMs are terrible self-evaluators — they confidently praise mediocre work. Tuning a standalone evaluator to be skeptical is far more tractable than making a generator self-critical.

**When to use**: complex features, subjective quality, UI work. Not for simple CRUD or config changes.

**Evaluator tuning**: out of the box, Claude identifies issues then talks itself into approving. Multiple rounds of prompt tuning needed — read evaluator logs, find judgment divergences from human expectations, update QA prompt.

### Context Flooding Problem

HumanLayer identified this: running a full test suite floods the context window, causing agents to lose track and hallucinate about test files. Verification must be **context-efficient**:

- Swallow passing output, only surface errors
- Run targeted subsets (< 30 seconds), not the full suite every iteration
- Use hooks that run silently on success, exit with error only on failure

## Subagent Lanes

Subagents are **context firewalls** — each gets only the context for its concern. This prevents context pollution and rot. It's the primary reason to split, not speed.

**When to split**: work divides cleanly by concern, lanes are independent, context is large enough to benefit from isolation.

**When NOT to split**: lanes depend on each other's output, context is small, coordination overhead exceeds benefit.

### Review Lanes

**`security`** — auth, secrets, injection, access control, unsafe input
- Hardcoded credentials, leaked tokens in config
- Auth flows: bypass, privilege escalation paths
- Unsanitized input reaching SQL, shell, eval, templates
- Access control enforced at the right layer (not just UI)

**`tests`** — missing behavioral coverage, weak edge cases, brittle tests
- Behavioral coverage over line coverage
- Untested error handling paths that cause silent failures
- Missing edge cases at boundaries (empty, null, max, concurrent)
- Tests that test implementation details instead of behavior

**`silent-failures`** — swallowed errors, broad catches, hidden fallbacks
- Zero tolerance for catch blocks that swallow errors without surfacing
- Every fallback must be explicit and justified
- Optional chaining chains that silently return undefined through important paths

**`types-and-contracts`** — type design, invariants, API contracts, schema drift
- Can invalid states be constructed?
- Invariants enforced at construction, not scattered across callers
- Stringly-typed fields that should be enums or branded types

**`maintainability`** — unnecessary complexity, duplication, awkward abstractions
- Where does understanding one concept require bouncing between many small files?
- Tightly coupled modules creating integration risk at seams
- Inaccurate comments, misleading docs, comment rot

### Sanity-Check Lanes (run-it-and-prove-it)

Each lane should **execute commands and capture evidence**, not just read code.

**`ui-surface`** — navigate the real UI flow with Playwright/CDP, screenshot at each step, check structure/legibility/responsiveness, verify responsive behavior, check for console errors

**`api-surface`** — hit real local endpoints with representative requests, verify status codes/response shapes/error responses, exercise adjacent/error cases

**`state-and-config`** — write data, restart, read it back; boot with new config and confirm; check both fresh-state and existing-state behavior

**`external-contracts`** — compare actual API responses against expected shapes; watch for optional fields, missing fields, version drift; if you can't hit the real API, surface the gap

## Choosing Lanes

Pick the smallest set of independent lanes that challenge the change from different angles:

- **UI change**: `ui-surface` + `tests`; add `types-and-contracts` if data shape changed
- **API/backend**: `api-surface` + `tests`; add `silent-failures` or `external-contracts` for integrations
- **State/migration/config**: `state-and-config` + `tests`; add `types-and-contracts` for invariant changes
- If the risk is broader than the request, verify broadly anyway

## Model Selection

Match model capability to lane complexity:

- **Strong reasoning** (e.g. Opus, GPT-5.4): security, types-and-contracts, orchestration/planning
- **Balanced** (e.g. Sonnet, GPT-5.4-mini): tests, maintainability, silent-failures
- **Fast/cheap** (e.g. Haiku, flash): ui-surface, api-surface, state-and-config scans

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
