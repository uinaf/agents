---
name: verify
description: "Self-check your own completed change before handing off to `review` — the pre-review sanity pass. Use when you want to verify your change, test it end-to-end, run the repo's guardrails (lint, typecheck, tests, build), exercise the real surface with evidence, and catch obvious self-correctable issues you can fix in seconds. Produces a `ready for review` / `needs more work` / `blocked` verdict — never a ship decision (that's `review`'s job). If the repo cannot be booted or exercised reliably, hand off to `agent-readiness`. If you are auditing someone else's diff, branch, or PR, use `review` instead."
---

# Verify

Self-check your own completed change before handing it off to `review`. Verify proves the change boots, passes guardrails, and survives the real surface — it is not a substitute for independent review.

## Principles

- Verify is the builder's gate before review; it does not replace review
- The builder does not grade their own work in the same context — switch into a fresh evaluator context or separate subagent first
- Run repo guardrails first, then hit the real surface
- Prefer smoke, integration, contract, or e2e proof over unit tests that mock most of the behavior under test
- Self-correct obvious issues you spot while exercising the change; leave the rigorous code-shape pass to `review`
- Load shared doctrine from the repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules before judging the result
- If the infrastructure is too weak to verify reliably, stop and hand off to `agent-readiness`

## Handoffs

- Verification passed → hand off to `review` for the independent ship decision
- No stable boot / smoke / interact path, or infrastructure too weak to trust → use `agent-readiness`
- Auditing existing code, a diff, branch, or PR you did not author → use `review`
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
- When choosing tests, prefer the strongest cheap proof available: smoke, integration, contract, or e2e checks beat mock-heavy unit suites that mainly replay implementation details
- Swallow boring success output and surface only failures, anomalies, and exact commands

### 2. Exercise the real surface

- UI → run the browser automation, navigate the changed flow, and capture screenshots
- API → hit the local endpoint with a real request such as `curl http://127.0.0.1:3000/health`
- CLI → run the shipped command such as `node dist/cli.js --help` or the repo's packaged entrypoint
- state/config → verify round trips, restart behavior, and config boot paths

Follow [references/evidence-rules.md](references/evidence-rules.md) when collecting proof.

### 3. Self-correct obvious issues

While exercising the change, fix anything cheap and obvious that you spot:

- A typo in a log line, a stale comment, an unused import, a duplicated helper inside the diff
- An `any`, unsafe `as`, or non-null assertion you can replace with a real type in seconds
- A failure path that swallows errors silently when a one-line `throw` makes the diagnostic useful

Do not turn this into a full review pass. Substantive code-shape concerns (architecture mismatches, broader duplication, error-classification redesigns) belong to `review`. Use [references/simplification.md](references/simplification.md) only as a short self-check, not as a refactoring backlog.

### 4. Probe adjacent risk

- Check the main happy path
- Check at least one failure path or edge case
- Check that at least one exercised failure path returns or logs a useful, actionable error instead of a vague or swallowed failure
- Re-test any config, persistence, or restart-sensitive behavior touched by the change

### 5. Synthesize the verdict

Produce one clear outcome:

- `ready for review` — guardrails green, real surface confirmed, no obvious self-correctable issues left
- `needs more work` — the change is not ready to be reviewed; specific issues to address are listed
- `blocked` — verification cannot proceed, usually because infrastructure is too weak (hand off to `agent-readiness`)

Verify never issues `ship it`. The independent ship decision is `review`'s job.

## Output

After verification, report:

- verdict
- change verified
- surfaces exercised
- self-corrections applied during verification (if any)
- top findings by severity (issues you could not self-correct)
- exact evidence: commands, screenshots, traces, responses, or file references
- readiness gaps or doc drift discovered during verification
- recommended follow-up: `review`, `agent-readiness`, `docs`, or more implementation

Example:

```text
verdict: ready for review
change verified: retry banner after transient API failure
surfaces exercised: pnpm test test/retry.spec.ts, curl http://127.0.0.1:3000/api/retry
self-corrections: dropped unused import in src/retry/banner.ts; tightened error log to include status code
top finding: medium — the UI recovers, but the retry count is not persisted across refresh (left for review to weigh)
evidence: local API returned 200 after retry; browser screenshot after refresh shows count reset to 0
recommended follow-up: review
```

## References

- [references/verification.md](references/verification.md) — evaluator pattern, targeted real-surface checks, and cost trade-offs
- [references/evidence-rules.md](references/evidence-rules.md) — what counts as proof and how to report it
- [references/simplification.md](references/simplification.md) — clarity, dedupe, and "fresh-agent readability" checks for changed code
