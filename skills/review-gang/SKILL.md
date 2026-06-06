---
name: review-gang
description: "Independently audit existing code, diffs, branches, or pull requests by spawning mandatory concern-specific reviewer subagents, then synthesizing their evidence into a ship decision. Use when triaging PR risk, deciding whether someone else's change is safe to ship, or following up after runtime proof. Produces a `ship it` / `needs review` / `blocked` verdict. Do not use to self-check a change you just authored."
---

# Review Gang

Independently audit existing code by spawning concern-specific reviewer subagents, then synthesize one evidence-backed ship decision.

## Contract

- Spawn reviewer personas as separate subagents every time; if subagents are unavailable, the review is `blocked` unless the user explicitly allows a sequential fallback
- Always run the default gang: `general`, `tests`, `silent-failures`, and `code-shape`
- Keep findings risk-focused, evidence-backed, severity-ordered, and free of low-value nits
- Block when missing context or proof prevents an honest verdict; otherwise name the unverified surface and adjust the verdict
- Do not use this lane to self-check a change you just authored

## Before You Start

1. Define the scope: file, diff, branch, commit range, or PR
2. Load the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules, when present
3. Confirm the reviewed base/head or live artifact is current; stale review artifacts are evidence to refresh, not evidence to trust
4. Spawn the mandatory default reviewer subagents from [references/reviewer-selection.md](references/reviewer-selection.md)
5. Add conditional reviewer subagents when the change shape calls for them

Add conditional personas only when they add a distinct concern; use [references/reviewer-selection.md](references/reviewer-selection.md) for shortcuts and criteria.

## Workflow

### 1. Scope nearby risk

Review the requested code, but inspect adjacent behavior when the risk leaks past the named diff.

Refresh the source of truth before judging branches or PRs: base branch, head SHA, diff, checks, and linked issue or specification when present.

### 2. Spawn reviewer subagents

Spawn one subagent per selected persona. Run them in parallel when the environment supports it, and keep each persona concern-focused and independent. Do not collapse the gang into one blended self-review pass.

Use this prompt shape for each subagent, filling in the persona and scope:

```text
You are the <persona> reviewer. Read the target repo guidance, then review only <scope> against your persona concerns from skills/review-gang/reviewers/<persona>.md.

Return only material findings with file/line evidence, severity, confidence, and the proof or missing proof that changes the verdict. If you find nothing material, say "none" and name any residual unverified surface.
```

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

Keep detailed issue text in native findings or fallback finding bullets. Keep the verdict footer to 4 labeled lines or fewer after findings.

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

- [references/reviewing.md](references/reviewing.md) — reviewer subagent workflow, evidence expectations, and verdict synthesis
- [references/reviewer-selection.md](references/reviewer-selection.md) — mandatory and conditional reviewer subagents
