# Reviewing

Review existing code with independent subagent lenses, then collapse the result into one evidence-backed verdict.

## Sources

- Anthropic PR review toolkit (agent-per-concern): https://github.com/anthropics/claude-code/tree/main/plugins/pr-review-toolkit/agents
- OpenAI Codex subagents: https://developers.openai.com/codex/concepts/subagents
- Context rot research: https://research.trychroma.com/context-rot

## Workflow

1. Load the repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules, plus local review doctrine, when present
2. Spawn the mandatory default reviewer gang: general, tests, silent-failures, and code-shape
3. Add conditional reviewer subagents only when they add a distinct concern
4. Run personas independently, preferably in parallel
5. Refresh stale evidence before trusting it
6. Merge findings into one prioritized verdict

## Freshness

Before finalizing a branch or PR review, confirm the evidence still matches the reviewed head:

- base branch and head SHA
- current diff or commit range
- relevant CI/check status
- linked issue, spec, or behavior claim when the review depends on it

Cached review artifacts, old screenshots, stale local build output, or a green CI board from a previous head are not current proof. Refresh them or mark the affected surface as `unverified`.

## Evidence

- Prefer file references with line numbers for static findings
- Use targeted commands when a claim needs proof
- Keep passing output terse; surface only the lines that matter
- Mark any unverified surface as `unverified`
- Keep proof layers separate: code inspection, focused regression tests, CI, runtime proof, and live/deploy evidence each prove different claims

## Verdict Shape

- `ship it` — no material findings; remaining risk is minor and named
- `needs review` — material issues exist, or a required proof layer is absent but the next action is clear
- `blocked` — missing context, stale/missing source of truth, unavailable required evidence, or a severe issue stops honest review

## Presentation

- Findings first, severity ordered
- Native finding cards or inline review comments when available; compact fallback bullets otherwise
- Footer labels: `findings`, `verdict`, `evidence`, `unverified`, `next`, optional `notes`
- Keep `unverified:` narrow: name the missing proof layer, not a general anxiety
- Use `notes:` only for out-of-scope repo state the user must act on

## Anti-Patterns

- Skipping the mandatory default gang
- Adding conditional personas that repeat the default gang's concerns
- Reporting stylistic nits as if they were defects
- Treating screenshots or passing tests as a substitute for code reasoning
- Treating local proof as live/deploy proof, or CI as a real-behavior proof lane
- Trusting stale PR metadata, old review artifacts, or cached local output after the branch moved
- Reviewing your own work here when the real task is self-verification
