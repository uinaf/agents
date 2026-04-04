---
name: verify
description: "Review code changes and pull requests using the repo's existing harness. Use when validating your own changes, reviewing someone else's PR, or producing a ship-it / needs-review / blocked verdict with evidence. If the repo is not verifiable yet, stop and hand off to harness instead of improvising checks."
---

# Verify

Use the existing harness to judge changes on real surfaces.

## Principles

- The builder does not grade their own work
- Evidence beats vibes
- Use the smallest set of reviewer lanes that meaningfully challenge the change
- Load shared doctrine from the repo's `AGENTS.md` first; reviewer files add a lens, not a new religion
- If the harness is too weak to verify reliably, stop and hand off to `harness`

## Handoffs

- No stable boot / smoke / interact path, or harness too weak to trust → use `harness`
- Main problem is stale AGENTS.md, README, specs, or repo docs → use `docs`

## Before You Start

1. Define the scope: diff, branch, commit range, or PR
2. Confirm you can boot and interact with the real surface
3. Load the target repo's `AGENTS.md`
4. Choose reviewer lanes from `references/reviewer-selection.md`

Default lanes:

- `reviewers/general.md`
- `reviewers/tests.md`
- `reviewers/silent-failures.md`

Add conditional lanes only when they earn their keep:

- `reviewers/types.md`
- `reviewers/comments.md`

## Workflow

### 1. Scope the review

Review the requested diff, but inspect nearby risk as well.

### 2. Run independent lanes

Use parallel subagents when available. Keep lanes independent and concern-focused.

### 3. Exercise the real surface

- UI → navigate it
- API → hit the real endpoint
- CLI → run the shipped command
- state/config → verify round trips and restart behavior

Follow `references/evidence-rules.md` when collecting proof.

### 4. Synthesize the verdict

Produce one clear outcome:

- `ship it`
- `needs review`
- `blocked`

If blocked because the harness is weak, say so explicitly and hand off to `harness`.

## Output

After verification, report:

- verdict
- scope reviewed
- reviewer lanes used
- top findings by severity
- exact evidence: commands, screenshots, traces, responses, or file references
- harness gaps or doc drift discovered during review
- recommended follow-up: `harness`, `docs`, or implementation

## References

- `references/verification.md` — evaluator pattern, lane design, real-surface checks, cost trade-offs
- `references/reviewer-selection.md` — which reviewer lanes to run for which change shapes
- `references/evidence-rules.md` — what counts as proof and how to report it
- `reviewers/*.md` — specialized review lenses
