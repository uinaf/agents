---
name: verify
description: "Verify your own completed code changes using the repo's existing harness and an independent evaluator context. Use after implementing a change when you need to run unit or integration tests, check build or lint gates, and prove the real surface works with evidence. If the repo is not verifiable yet, hand off to `harness`; if you are reviewing someone else's code, use `review`."
---

# Verify

Use the existing harness to prove your own change works before calling it done.

## Principles

- The builder does not grade their own work in the same context; switch into a fresh evaluator context or separate subagent first
- Evidence beats confidence
- Run repo guardrails first, then hit the real surface
- Load shared doctrine from the repo's `AGENTS.md` before judging the result
- If the harness is too weak to verify reliably, stop and hand off to `harness`

## Handoffs

- No stable boot / smoke / interact path, or harness too weak to trust → use `harness`
- Need to review existing code, a diff, branch, or PR you are not verifying as the builder → use `review`
- Main problem is stale AGENTS.md, README, specs, or repo docs → use `docs`

## Before You Start

1. Define the exact change being verified and the expected user-visible behavior
2. Switch into an independent evaluator context before judging your own work
3. Load the target repo's `AGENTS.md`
4. Confirm you can boot and interact with the real surface
5. Pick the smallest check set that can disprove the change honestly

## Workflow

### 1. Run deterministic guardrails first

- Prefer the repo's built-in entrypoint: `make verify`, `just verify`, `pnpm test`, `cargo test`, or the nearest targeted equivalent
- Swallow boring success output and surface only failures, anomalies, and exact commands

### 2. Exercise the real surface

- UI → run the browser harness, navigate the changed flow, and capture screenshots
- API → hit the local endpoint with a real request such as `curl http://127.0.0.1:3000/health`
- CLI → run the shipped command such as `node dist/cli.js --help` or the repo's packaged entrypoint
- state/config → verify round trips, restart behavior, and config boot paths

Follow [references/evidence-rules.md](references/evidence-rules.md) when collecting proof.

### 3. Probe adjacent risk

- Check the main happy path
- Check at least one failure path or edge case
- Re-test any config, persistence, or restart-sensitive behavior touched by the change

### 4. Synthesize the verdict

Produce one clear outcome:

- `ship it`
- `needs review`
- `blocked`

If blocked because the harness is weak, say so explicitly and hand off to `harness`.

## Output

After verification, report:

- verdict
- change verified
- surfaces exercised
- top findings by severity
- exact evidence: commands, screenshots, traces, responses, or file references
- harness gaps or doc drift discovered during verification
- recommended follow-up: `harness`, `docs`, or implementation

Example:

```text
verdict: needs review
change verified: retry banner after transient API failure
surfaces exercised: pnpm test test/retry.spec.ts, curl http://127.0.0.1:3000/api/retry
finding: medium — the UI recovers, but the retry count is not persisted across refresh
evidence: local API returned 200 after retry; browser screenshot after refresh shows count reset to 0
recommended follow-up: implementation
```

## References

- [references/verification.md](references/verification.md) — evaluator pattern, targeted real-surface checks, and cost trade-offs
- [references/evidence-rules.md](references/evidence-rules.md) — what counts as proof and how to report it
