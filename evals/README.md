# Agent-eval harness for `rules/agents.md`

Measures the impact of `rules/agents.md` on agent behavior using [`@vercel/agent-eval`](https://github.com/vercel-labs/agent-eval). Three conditions on the same suite of six tasks:

| Condition | Setup |
|---|---|
| `baseline` | No `rules/agents.md` present in the sandbox |
| `trimmed`  | Current `../rules/agents.md` (79 lines) written into the sandbox as `CLAUDE.md` |
| `original` | Pre-trim 154-line snapshot from commit `5e14688` (`fixtures/rules-original.md`) written into the sandbox as `CLAUDE.md` |

## Tasks

| Eval | Rule under test |
|---|---|
| `verify-loop` | `Use repo guardrails (make verify, just verify) when present` |
| `no-bypass` | `No --no-verify, no skipped tests, no workarounds without explicit approval` |
| `parse-dont-validate` | `Make illegal states unrepresentable; parse external input at the boundary, operate on typed values internally` |
| `ask-when-blocked` | `If instructions are unclear, contradictory, or have multiple plausible interpretations, ask before guessing` |
| `no-mock-tests` | `Bug fix → write a reproducing test first, then fix` + `Prefer integration / contract / e2e checks over mock-heavy unit tests` |
| `minimal-changeset` | `Fix only what was asked. Flag related issues, wait for approval before expanding scope` |

Each eval ships a fixture project with `PROMPT.md`, `EVAL.ts` (Vitest assertions, including assertions on `__agent_eval__/results.json` o11y data), `package.json`, and `src/`.

## Run

```bash
cd evals
npm install
cp .env.example .env  # fill in keys (see below)

# preview without API calls
npm run eval:dry

# full sweep across all three experiments
npm run eval

# inspect results in the playground
npm run playground
```

`@vercel/agent-eval` discovers `experiments/*.ts` and runs them against `evals/*/`. With the configs as committed, that's 3 experiments × 6 evals × 3 runs = 54 sandbox runs. Lower `runs:` in each experiment file for cheaper sweeps.

## Required keys

The harness needs an agent path and a sandbox path. Pick one of:

- **Vercel AI Gateway** (recommended): set `AI_GATEWAY_API_KEY` + `VERCEL_TOKEN` in `.env`. Experiments use `agent: 'vercel-ai-gateway/claude-code'`.
- **Direct Anthropic**: set `ANTHROPIC_API_KEY` and switch each experiment to `agent: 'claude-code'` + `sandbox: 'docker'`. Local Docker daemon must be running.

## Results

> **Status: not yet run.** No `AI_GATEWAY_API_KEY` / `ANTHROPIC_API_KEY` was available at the time the harness was committed. Fill in `.env`, run `npm run eval`, and append a row of pass-rate numbers per `(experiment, eval)` cell. A short text summary below the table should call out any rule that did not move pass rate vs. baseline so the next trim has evidence.

| Eval | baseline | trimmed | original |
|---|---|---|---|
| verify-loop | – | – | – |
| no-bypass | – | – | – |
| parse-dont-validate | – | – | – |
| ask-when-blocked | – | – | – |
| no-mock-tests | – | – | – |
| minimal-changeset | – | – | – |
| **mean pass rate** | – | – | – |
| **mean cost / run** | – | – | – |

Cost numbers come from the AI Gateway billing dashboard (or Anthropic console for direct API). The harness reports duration and tool-call counts per run in `results/<experiment>/<timestamp>/<eval>/run-N/result.json`.

### Interpreting the table

- `trimmed > baseline` on a rule's eval → that rule earns its keep
- `trimmed ≈ baseline` → the rule did not move the needle for this task; consider cutting it on the next trim or rephrasing it as a checked behavior
- `original > trimmed` → a rule we removed was actually doing work; restore it (or surface why the task triggered it)
- `original ≈ trimmed` AND both `> baseline` → the trim removed nothing load-bearing; the trim was correct

## Layout

```
evals/
├── package.json            # @vercel/agent-eval, scripts
├── .env.example
├── experiments/
│   ├── baseline.ts         # no setup
│   ├── trimmed.ts          # writes ../rules/agents.md as CLAUDE.md
│   └── original.ts         # writes fixtures/rules-original.md as CLAUDE.md
├── fixtures/
│   └── rules-original.md   # pinned 154-line pre-trim snapshot (commit 5e14688)
└── evals/
    ├── verify-loop/
    ├── no-bypass/
    ├── parse-dont-validate/
    ├── ask-when-blocked/
    ├── no-mock-tests/
    └── minimal-changeset/
```

## Adding evals

1. Create `evals/<name>/` with `PROMPT.md`, `EVAL.ts`, `package.json`, and a `src/` starter.
2. The EVAL.ts can read `__agent_eval__/results.json` for o11y data (shell commands, files modified, tool-call counts) and assert on the agent's actual behavior, not just file output.
3. Re-run `npm run eval`. Existing evals are skipped via fingerprint; new evals run cold.
