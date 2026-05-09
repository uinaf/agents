---
name: review
description: "Independently audit existing code, diffs, branches, or pull requests using concern-specific reviewer personas and evidence. Use when triaging risk in a PR, deciding whether a change is safe to ship, or following up on a `verify` pass to make the call the builder cannot make on their own work. Produces a `ship it` / `needs review` / `blocked` verdict. Do not use to self-check a change you just authored; use `verify` for that."
---

# Review

Independently audit existing code with concern-specific lenses and decide whether it is safe to ship. Review is the gate after `verify` — the builder proves the change works on the real surface, then review decides whether the change is *good*.

## Principles

- Prefer parallel reviewer personas when the concerns are independent
- Evidence beats taste
- Load shared doctrine from the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules
- Keep the final verdict tied to concrete evidence, not reviewer instinct alone
- Keep findings risk-focused and filter low-value nits
- Track reviewer personas internally; include them visibly only when asked or when the harness has compact metadata
- If runtime proof for your own completed change is the goal, hand off to `verify`

## Handoffs

- Self-checking a change you just authored, before handing it off for review → use `verify`
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
- If something is unverified, say so explicitly
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
- `- next:` one of `implementation`, `verify`, `agent-readiness`, or `docs`
- `- notes:` only for out-of-scope repo state the user must act on

Use those labels explicitly. Keep the verdict label exact and omit opener, closer, apology, status preface, or conversational recap.

Prefer the active harness's best native review representation instead of a prose-heavy wall of text.

Keep the final answer short:

- Put detailed issue text, file references, and line numbers in native findings or the fallback findings list
- Keep native finding details in the findings and keep the verdict block short
- Keep the core verdict footer to 4 labeled lines or fewer after findings; add `notes:` only when necessary
- Keep each label to one short sentence or fragment
- Summarize passing commands by intent and result, for example `typecheck passed for tv-vite` or `browser e2e covered pointer long-press`; include the full command only when it failed, is needed for reproduction, or the user asks for it
- Keep `unverified:` narrow; split only by semicolon when there are multiple concrete gaps
- Omit scope and personas from the footer unless the user asked for them or the scope would be ambiguous without one short `reviewed:` line
- If there are no findings, say `findings: none` and keep the rest equally compact
- If repo housekeeping appears, prefer `notes: untracked "--" left out of scope` over a paragraph

Harness-specific presentation rules:

- Prefer the strongest structured finding format available: Codex/OpenAI native `P0` / `P1` / `P2` / `P3` cards, or a compact table in Claude/Anthropic harnesses
- If no richer primitive exists, use a short severity-ordered findings list with file/line, issue, impact, and evidence
- Put actionable findings first, before footer or recap material

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
- [reviewers/](reviewers/) — specialized review lenses
