---
name: review
description: "Review existing code, diffs, branches, or pull requests using concern-specific reviewer personas and evidence. Use when auditing someone else's work, triaging risk in a PR, or producing a ship-it / needs-review / blocked verdict. Do not use to verify your own completed change; use `verify` for that."
---

# Review

Review existing code with independent lenses before deciding whether it is safe to ship.

## Principles

- Prefer parallel reviewer personas when the concerns are independent
- Evidence beats taste
- Load shared doctrine from the target repo's `AGENTS.md` first
- Keep findings risk-focused; do not drown the user in low-value nits
- If runtime proof for your own completed change is the goal, hand off to `verify`

## Handoffs

- Need to prove your own completed change works on real surfaces → use `verify`
- Review is blocked because the repo cannot be booted or exercised reliably → use `harness`
- Main problem is stale AGENTS.md, README, specs, or repo docs → use `docs`

## Before You Start

1. Define the scope: file, diff, branch, commit range, or PR
2. Load the target repo's `AGENTS.md`
3. Choose reviewer personas from [references/reviewer-selection.md](references/reviewer-selection.md)
4. Decide which personas can run independently in parallel

Default personas:

- [reviewers/general.md](reviewers/general.md)
- [reviewers/tests.md](reviewers/tests.md)
- [reviewers/silent-failures.md](reviewers/silent-failures.md)

Add conditional personas only when they earn their keep:

- [reviewers/types.md](reviewers/types.md)
- [reviewers/comments.md](reviewers/comments.md)

## Workflow

### 1. Scope nearby risk

Review the requested code, but inspect adjacent behavior when the risk leaks past the named diff.

### 2. Run reviewer personas

Use parallel subagents when available. Keep each persona concern-focused and independent.

Concrete starting points:

- `git diff --stat <base>...HEAD` to size the change
- `git diff <base>...HEAD -- <path>` to inspect risky files
- targeted tests such as `pnpm test path/to/spec` when behavior claims need proof

### 3. Collect evidence

- Cite exact file references for static findings
- Run the smallest runtime check that changes the verdict when the repo supports it
- If something is unverified, say so explicitly instead of bluffing

### 4. Synthesize the verdict

Produce one clear outcome:

- `ship it`
- `needs review`
- `blocked`

Order findings by severity. If no findings are discovered, say that explicitly and mention any residual risk or testing gap.

## Output

After review, report:

- verdict
- scope reviewed
- reviewer personas used
- top findings by severity
- exact evidence: file references, commands, traces, or responses
- unverified areas or harness gaps
- recommended follow-up: implementation, `verify`, `harness`, or `docs`

Example:

```text
verdict: needs review
scope reviewed: feature/auth-session branch
reviewer personas: general, tests, silent-failures
finding: high — src/auth/session.ts:42 fallback returns an anonymous session when token parsing fails
evidence: targeted test passes only for valid tokens; no failure-path coverage covers malformed headers
recommended follow-up: implementation
```

## References

- [references/reviewing.md](references/reviewing.md) — reviewer persona workflow, evidence expectations, and verdict synthesis
- [references/reviewer-selection.md](references/reviewer-selection.md) — which reviewer personas to run for which change shapes
- [reviewers/](reviewers/) — specialized review lenses
