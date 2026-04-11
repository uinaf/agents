# Reviewing

Review existing code with independent lenses, then collapse the result into one evidence-backed verdict.

## Sources

- Anthropic PR review toolkit (agent-per-concern): https://github.com/anthropics/claude-code/tree/main/plugins/pr-review-toolkit/agents
- OpenAI Codex subagents: https://developers.openai.com/codex/concepts/subagents
- Context rot research: https://research.trychroma.com/context-rot

## Workflow

1. Load the repo's `AGENTS.md` and local review doctrine first
2. Pick the smallest set of reviewer personas that can challenge the change from distinct angles
3. Run personas independently when parallelism actually buys separation of concerns
4. Merge findings into one prioritized verdict

## Evidence

- Prefer file references with line numbers for static findings
- Use targeted commands when a claim needs proof
- Keep passing output terse; surface only the lines that matter
- Mark any unverified surface as `unverified`

## Verdict Shape

- `ship it` — no material findings; remaining risk is minor and named
- `needs review` — issues exist, but the repo and harness are good enough to continue
- `blocked` — missing harness, missing context, or a severe issue stops honest review

## Anti-Patterns

- Running every persona blindly on tiny diffs
- Reporting stylistic nits as if they were defects
- Treating screenshots or passing tests as a substitute for code reasoning
- Reviewing your own work here when the real task is self-verification
