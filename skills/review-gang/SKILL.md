---
name: review-gang
description: "Review an existing diff, branch, pull request, or codebase with at least two independent reviewer subagents, scale the reviewer set to the risk, then synthesize their evidence into a ship decision. Use when the user asks to review this PR, check this diff independently, decide whether someone else's change is safe to merge, triage PR risk, or follow up after runtime proof. Produces a `ship it` / `needs review` / `blocked` verdict. Do not use to self-check a change you just authored."
---

# Review Gang

Independently audit existing code by spawning concern-specific reviewer subagents, then synthesize one evidence-backed ship decision.

## Contract

- Spawn at least two reviewer personas as separate subagents every time
- Treat invocation of `review-gang`, `$review-gang`, or the Review Gang tile as authorization to use reviewer subagents; if their tooling is not visible, discover or load it once, then report `blocked` if it remains unavailable unless the user explicitly allows a sequential fallback
- Scale the reviewer set to the change: a tiny low-risk diff gets `general` plus one relevant specialist; normal changes get `general`, `tests`, `silent-failures`, and `code-shape`; high-risk changes add only distinct specialists
- Keep findings risk-focused, evidence-backed, severity-ordered, and free of low-value nits
- Block when missing context or proof prevents an honest verdict; otherwise name the unverified surface and adjust the verdict
- Do not use this lane to self-check a change you just authored

## Before You Start

1. Define the scope: file, diff, branch, commit range, or PR
2. Load the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules, when present
3. Confirm the reviewed base/head or live artifact is current
4. Select the risk tier and reviewer set from [references/reviewer-selection.md](references/reviewer-selection.md)
5. Load each selected persona file relative to this `SKILL.md`, then spawn the reviewer with those instructions embedded in its task

Add conditional personas only when they add a distinct concern; use [references/reviewer-selection.md](references/reviewer-selection.md) for shortcuts and criteria.

## Workflow

### 1. Scope nearby risk

Review the requested code, but inspect adjacent behavior when the risk leaks past the named diff.

Refresh the source of truth before judging branches or PRs: base branch, head SHA, diff, checks, and linked issue or specification when present.

### 2. Spawn reviewer subagents

Spawn one subagent per selected persona. Run them in parallel when the environment supports it, and keep each persona concern-focused and independent. Do not collapse the gang into one blended self-review pass.

Before spawning, load `references/reviewers/<persona>.md` relative to this skill package and embed its contents in the task. Never ask the subagent to resolve a source-repo path from the target repository.

Use this prompt shape for each subagent, filling in the persona, scope, and loaded instructions:

```text
You are the <persona> reviewer. Read the target repo guidance, then review only <scope>.

Persona instructions:
<contents loaded from references/reviewers/<persona>.md>

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

Prefer the active harness's best native review representation instead of a prose-heavy wall of text.

Keep detailed issue text in native findings or fallback finding bullets. After findings, keep the remaining labels to four lines or fewer. Omit opener, closer, apology, status preface, and conversational recap.

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
- [references/reviewer-selection.md](references/reviewer-selection.md) — risk tiers and reviewer selection
