---
name: review
description: "Review existing code, diffs, branches, or pull requests using concern-specific reviewer personas and evidence. Use when auditing someone else's work, triaging risk in a PR, or producing a ship-it / needs-review / blocked verdict. Do not use to verify your own completed change; use `verify` for that."
---

# Review

Review existing code with independent lenses before deciding whether it is safe to ship.

## Principles

- Prefer parallel reviewer personas when the concerns are independent
- Evidence beats taste
- Load shared doctrine from the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules
- Keep the final verdict tied to concrete evidence, not reviewer instinct alone
- Keep findings risk-focused; do not drown the user in low-value nits
- Always list the reviewer personas you used, even when there were only one or two
- Always include an explicit `unverified areas` line, even if the answer is `none`
- Always choose the verdict from exactly: `ship it`, `needs review`, `blocked`
- If runtime proof for your own completed change is the goal, hand off to `verify`

## Handoffs

- Need to prove your own completed change works on real surfaces → use `verify`
- Review is blocked because the repo cannot be booted or exercised reliably → use `agent-readiness`
- Main problem is stale AGENTS.md, README, specs, or repo docs → use `docs`

## Before You Start

1. Define the scope: file, diff, branch, commit range, or PR
2. Load the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules, when present
3. Choose reviewer personas from [references/reviewer-selection.md](references/reviewer-selection.md)
4. Decide which personas can run independently in parallel

Default personas:

- [reviewers/general.md](reviewers/general.md)
- [reviewers/tests.md](reviewers/tests.md)
- [reviewers/silent-failures.md](reviewers/silent-failures.md)

Add conditional personas only when they earn their keep:

- [reviewers/types.md](reviewers/types.md)
- [reviewers/cleanup.md](reviewers/cleanup.md)
- [reviewers/comments.md](reviewers/comments.md)

Persona shortcuts:

- doc-only or comment-only diffs: use `general` plus `comments`; skip `tests`, `types`, `silent-failures`, and `cleanup` unless the diff actually justifies them
- type-shape or schema changes: add `types`
- dead files, deprecated paths, or obviously unused helpers: add `cleanup` and call out deletion explicitly when warranted
- mock-heavy or shallow tests around risky behavior: make that a finding rather than treating test presence as proof

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
- If legacy or dead code is still present, say whether it should be deleted or why it must stay
- If tests mock the main integrations or boundaries, say that the behavior is still unverified on the real surface

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
- unverified areas or readiness gaps
- recommended follow-up: implementation, `verify`, `agent-readiness`, or `docs`

Use those labels explicitly. Do not replace them with softer prose like "safe to merge" or "do not ship today".

Prefer the active harness's best native review representation instead of a prose-heavy wall of text.

Harness-specific presentation rules:

- Tell the harness to use the strongest structured review format it supports
- Codex / OpenAI review harnesses: prefer the native structured findings UI so issues appear as `P0` / `P1` / `P2` / `P3` findings with tight file and line references
- Claude / Anthropic harnesses: prefer a compact findings table over paragraphs. Recommended columns: severity, file or lines, issue, why it matters, and evidence
- Any harness without a richer native review primitive: fall back to a short severity-ordered list, not a long narrative
- Do not hide actionable findings inside a long prose recap when the harness can represent them more clearly

Example:

```text
verdict: needs review
scope reviewed: feature/auth-session branch
reviewer personas: general, tests, silent-failures
finding: high — src/auth/session.ts:42 fallback returns an anonymous session when token parsing fails
evidence: targeted test passes only for valid tokens; no failure-path coverage covers malformed headers
unverified areas: runtime behavior for malformed OAuth callbacks
recommended follow-up: implementation
```

## References

- [references/reviewing.md](references/reviewing.md) — reviewer persona workflow, evidence expectations, and verdict synthesis
- [references/reviewer-selection.md](references/reviewer-selection.md) — which reviewer personas to run for which change shapes
- [reviewers/](reviewers/) — specialized review lenses
