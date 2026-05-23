---
name: review
description: "Independently audit existing code, diffs, branches, or pull requests using concern-specific reviewer personas and evidence. Use when triaging risk in a PR, deciding whether a change is safe to ship, or following up after runtime proof to make the call the builder cannot make on their own work. Produces a `ship it` / `needs review` / `blocked` verdict. Do not use to self-check a change you just authored."
---

# Review

Independently audit existing code with concern-specific lenses and decide whether it is safe to ship. Review is the gate after runtime proof: the builder proves the change works on the real surface, then review decides whether the change is *good*.

## Principles

- Review is the independent decision layer for existing work; it can use any native review command or platform, but owns the verdict
- Use parallel reviewer personas only when concerns are independent
- Load shared doctrine from the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules
- Keep findings risk-focused, evidence-backed, severity-ordered, and free of low-value nits
- Keep proof layers separate: diff inspection, focused regression tests, CI, runtime proof, and live/deploy evidence are not interchangeable
- Do not use this lane to self-check a change you just authored

## Handoffs

- Review is blocked when missing context or missing proof prevents an honest verdict; otherwise name the unverified surface and adjust the verdict.
- Stale AGENTS.md, README, specs, or repo docs are documentation work unless they change the review verdict.

## Before You Start

1. Define the scope: file, diff, branch, commit range, or PR
2. Load the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules, when present
3. Confirm the reviewed base/head or live artifact is current; stale review artifacts are evidence to refresh, not evidence to trust
4. Choose reviewer personas from [references/reviewer-selection.md](references/reviewer-selection.md)
5. Decide which personas can run independently in parallel

Default personas:

- `general`
- `tests`
- `silent-failures`

Add conditional personas only when they earn their keep; use [references/reviewer-selection.md](references/reviewer-selection.md) for shortcuts and criteria.

## Workflow

### 1. Scope nearby risk

Review the requested code, but inspect adjacent behavior when the risk leaks past the named diff.

Refresh the source of truth before judging branches or PRs: base branch, head SHA, diff, checks, and linked issue or specification when present.

### 2. Run reviewer personas

Use parallel subagents when available. Keep each persona concern-focused and independent.

Concrete starting points:

- `git diff --stat <base>...HEAD` to size the change
- `git diff <base>...HEAD -- <path>` to inspect risky files
- targeted tests such as `pnpm test path/to/spec` when behavior claims need proof

### 3. Collect evidence

- Cite exact file references for static findings
- Run the smallest runtime check that changes the verdict when the repo supports it
- If something is unverified, say so explicitly
- Treat stale CI, stale review artifacts, or moved branch heads as unverified until refreshed
- If legacy or dead code is still present, say whether it should be deleted or why it must stay
- If tests mock the main integrations or boundaries, say that the behavior is still unverified on the real surface

### 4. Synthesize the verdict

Order findings by severity. If no findings are discovered, say that explicitly and mention any residual risk or testing gap. Choose exactly one verdict: `ship it`, `needs review`, or `blocked`.

## Output

After review, report in this compact bullet shape:

- `- findings:` first, only when present; otherwise `- findings: none`
- `- verdict:` exactly one of `ship it`, `needs review`, or `blocked`
- `- evidence:` concise explanations of what checks proved, not full commands
- `- unverified:` residual risk, readiness gaps, or `none`
- `- next:` one of `implementation`, runtime verification, readiness setup, documentation cleanup, or `none`
- `- notes:` only for out-of-scope repo state the user must act on

Use those labels explicitly. Keep the verdict label exact and omit opener, closer, apology, status preface, or conversational recap.

Prefer the active harness's best native review representation instead of a prose-heavy wall of text.

Keep the final answer short:

- Put detailed issue text, file references, and line numbers in native findings or the fallback findings list
- Keep native finding details in the findings and keep the verdict block short
- Keep the core verdict footer to 4 labeled lines or fewer after findings
- Keep `unverified:` narrow and explicit about the proof layer that is missing

See [references/reviewing.md](references/reviewing.md) for stale evidence handling and presentation details.

Example:

```text
- finding: high — src/auth/session.ts:42 fallback returns an anonymous session when token parsing fails
- verdict: needs review
- evidence: session tests exercised token parsing failures
- unverified: malformed OAuth callback runtime behavior
- next: implementation
```

## References

- [references/reviewing.md](references/reviewing.md) — reviewer persona workflow, evidence expectations, and verdict synthesis
- [references/reviewer-selection.md](references/reviewer-selection.md) — which reviewer personas to run for which change shapes
