---
name: verify
description: "Verify your own completed code changes using the repo's existing infrastructure and an independent evaluator context. Use after implementing a change when you need to run unit or integration tests, check build or lint gates, prove the real surface works with evidence, and challenge the changed code for clarity, deduplication, and maintainability. If the repo is not verifiable yet, hand off to `agent-readiness`; if you are reviewing someone else's code, use `review`."
---

# Verify

Use the existing infrastructure to prove your own change works before calling it done.

## Principles

- The builder does not grade their own work in the same context; switch into a fresh evaluator context or separate subagent first
- Evidence beats confidence
- Run repo guardrails first, then hit the real surface
- Challenge the changed code for shape as well as behavior; passing tests do not excuse bloated, duplicated, or comment-dependent code
- Load shared doctrine from the repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules before judging the result
- If the infrastructure is too weak to verify reliably, stop and hand off to `agent-readiness`

## Handoffs

- No stable boot / smoke / interact path, or infrastructure too weak to trust → use `agent-readiness`
- Need to review existing code, a diff, branch, or PR you are not verifying as the builder → use `review`
- Main problem is stale AGENTS.md, README, specs, or repo docs → use `docs`

## Before You Start

1. Define the exact change being verified and the expected user-visible behavior
2. Switch into an independent evaluator context before judging your own work
3. Load the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules, when present
4. Confirm you can boot and interact with the real surface
5. Pick the smallest check set that can disprove the change honestly

## Workflow

### 1. Run deterministic guardrails first

- Prefer the repo's built-in entrypoint: `make verify`, `just verify`, `pnpm test`, `cargo test`, or the nearest targeted equivalent
- Swallow boring success output and surface only failures, anomalies, and exact commands

### 2. Exercise the real surface

- UI → run the browser automation, navigate the changed flow, and capture screenshots
- API → hit the local endpoint with a real request such as `curl http://127.0.0.1:3000/health`
- CLI → run the shipped command such as `node dist/cli.js --help` or the repo's packaged entrypoint
- state/config → verify round trips, restart behavior, and config boot paths

Follow [references/evidence-rules.md](references/evidence-rules.md) when collecting proof.

### 3. Run a code-shape pass on the changed files

- Focus on code touched in the current task unless the changes obviously exposed a broader local mess
- Ask whether the solution matches the repo's language, framework, and design patterns rather than merely working
- Remove duplication, dead branches, and unnecessary abstractions when they do not protect a real boundary
- Prefer code that explains itself; comments should survive only when they carry durable context the code cannot make obvious
- Read the changed files as if a brand new agent inherited them tomorrow and had to extend the flow without prior context

Use [references/simplification.md](references/simplification.md) for the exact simplification questions.

### 4. Probe adjacent risk

- Check the main happy path
- Check at least one failure path or edge case
- Re-test any config, persistence, or restart-sensitive behavior touched by the change

### 5. Synthesize the verdict

Produce one clear outcome:

- `ship it`
- `needs review`
- `blocked`

If blocked because the infrastructure is weak, say so explicitly and hand off to `agent-readiness`.

## Output

After verification, report:

- verdict
- change verified
- surfaces exercised
- code-shape findings: clarity, duplication, comments, or maintainability debt in the changed files
- top findings by severity
- exact evidence: commands, screenshots, traces, responses, or file references
- readiness gaps or doc drift discovered during verification
- recommended follow-up: `agent-readiness`, `docs`, or implementation

Example:

```text
verdict: needs review
change verified: retry banner after transient API failure
surfaces exercised: pnpm test test/retry.spec.ts, curl http://127.0.0.1:3000/api/retry
code-shape finding: low — retry counter update is split across two helpers with identical branching; merge into one explicit path
finding: medium — the UI recovers, but the retry count is not persisted across refresh
evidence: local API returned 200 after retry; browser screenshot after refresh shows count reset to 0
recommended follow-up: implementation
```

## References

- [references/verification.md](references/verification.md) — evaluator pattern, targeted real-surface checks, and cost trade-offs
- [references/evidence-rules.md](references/evidence-rules.md) — what counts as proof and how to report it
- [references/simplification.md](references/simplification.md) — clarity, dedupe, and "fresh-agent readability" checks for changed code
