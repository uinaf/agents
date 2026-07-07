---
name: autoreview
description: "Run structured Codex/Claude autoreview closeout for local changes, pull requests, branch diffs, or commits: choose the target, validate findings, rerun focused tests, and repeat review until clean. Use when asked for autoreview, second-model review, pre-merge review, or readiness-to-ship review."
---

# Auto Review

Run the bundled structured review helper as a closeout check. This is code review, not Guardian `auto_review` approval routing.

Codex review is the default when no engine is set. It tries the helper's built-in preferred Codex models unless overridden, usually delivers the best review results, and should remain the normal final closeout engine. Claude review is optional and uses the helper's built-in preferred Claude model plus fallback unless overridden.

Use when:

- user asks for Codex review / Claude review / autoreview / second-model review
- after non-trivial code edits, before final/commit/ship
- reviewing a local branch or PR branch after fixes

## Contract

- Treat review output as advisory: verify every finding against real code, adjacent files, and dependency docs/types when relevant.
- Reject speculative or over-broad findings; fix accepted issues with the smallest change at the right ownership boundary.
- When a finding exposes a repeated bug class, inspect the current PR scope for sibling instances before fixing.
- Keep review-triggered fixes inside the original task scope; use [references/scope.md](references/scope.md) before accepting anything broader.
- If a review-triggered fix changes code, rerun focused proof plus autoreview until the helper exits cleanly; stop there.
- Honor the requested engine/model, do not invoke nested reviewers, and use review panels only when explicitly requested or risk justifies them.
- Do not push just to review. Push only when the user requested push, ship, or PR update.

Use [references/troubleshooting.md](references/troubleshooting.md) for heartbeat patience, Gitcrawl repair, regression provenance, security-suppression, and conscious-rejection rules.

## Scope And Release Guardrails

Use [references/scope.md](references/scope.md) before accepting review-triggered fixes that could expand the task, touch release process, or exceed two patch cycles.

## Core Workflow

1. Set `AUTOREVIEW` and `AUTOREVIEW_HARNESS` once for the active skill location.
2. Pick the real target: dirty local work, branch/PR base, or a single commit.
3. Run the helper with Codex by default, or Claude when requested.
4. Verify each finding against the code and reject weak findings explicitly.
5. Fix accepted findings at the right ownership boundary.
6. Rerun focused tests plus autoreview when fixes change code.
7. Stop after the helper exits 0 with no accepted/actionable findings and report that exact clean run.

## Skill Path (set once)

Set the skill script paths once, then use `"$AUTOREVIEW"` and `"$AUTOREVIEW_HARNESS"` in the examples below.

Choose one:

```bash
# Project-local skill in the current repo:
export AUTOREVIEW=".agents/skills/autoreview/scripts/autoreview"
export AUTOREVIEW_HARNESS=".agents/skills/autoreview/scripts/test-review-harness"
```

```bash
# Source checkout of openclaw/agent-skills:
export AUTOREVIEW="skills/autoreview/scripts/autoreview"
export AUTOREVIEW_HARNESS="skills/autoreview/scripts/test-review-harness"
```

```bash
# Global skill:
export AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
export AUTOREVIEW="$AGENTS_HOME/skills/autoreview/scripts/autoreview"
export AUTOREVIEW_HARNESS="$AGENTS_HOME/skills/autoreview/scripts/test-review-harness"
```

When using Claude Code, set `AGENTS_HOME="$HOME/.claude"` for global skills. Project-local skills live under `.claude/skills/` in the current repo.

## Pick Target

Dirty local work:

```bash
"$AUTOREVIEW" --mode local
```

Use this only when the patch is actually unstaged/staged/untracked in the
current checkout. `--mode uncommitted` is accepted as an alias for `--mode local`.
For committed, pushed, or PR work, point the helper at the commit
or branch diff instead; do not force dirty modes just
because the helper docs mention dirty work first. A clean local review
only proves there is no local patch.

Branch/PR work:

```bash
"$AUTOREVIEW" --mode branch --base origin/main
```

Optional review context is first-class. Prompt files and datasets must be repo-relative so review bundles cannot pull arbitrary host files:

```bash
"$AUTOREVIEW" --mode branch --base origin/main --prompt-file review-notes.md --dataset evidence.json
```

If an open PR exists, use its actual base:

```bash
base=$(gh pr view --json baseRefName --jq .baseRefName)
"$AUTOREVIEW" --mode branch --base "origin/$base"
```

Committed single change:

```bash
"$AUTOREVIEW" --mode commit --commit HEAD
```

Use commit review for already-landed or already-pushed work on `main`. Reviewing
clean `main` against `origin/main` is usually an empty diff after push. For a
small stack, review each commit explicitly or review the branch before merging
with `--base`.

## Parallel Closeout

Format first if formatting can change line locations. Then it is OK to run tests and review in parallel:

```bash
"$AUTOREVIEW" --parallel-tests "<focused test command>"
```

Tradeoff: tests may force code changes that stale the review. If tests or review lead to code edits, rerun the affected tests and rerun review until no accepted/actionable findings remain. Once that rerun exits cleanly, stop; do not spend another long review cycle on redundant confirmation.

## Review Panels

Run multiple reviewers against one frozen bundle:

```bash
"$AUTOREVIEW" --reviewers codex,claude
```

`--panel` is shorthand for Codex plus Claude unless `--engine` changes the first reviewer:

```bash
"$AUTOREVIEW" --panel
```

Set reviewer models and thinking/effort explicitly:

```bash
"$AUTOREVIEW" --reviewers codex,claude --model codex=gpt-5.6-sol --thinking codex=high --model claude=claude-fable-5 --thinking claude=max
```

Inline syntax is also supported for simple model IDs:

```bash
"$AUTOREVIEW" --reviewers codex:gpt-5.6-sol:high,claude:claude-fable-5:max
```

Codex maps thinking to `model_reasoning_effort` and accepts `low`, `medium`,
`high`, or `xhigh`. Claude maps thinking to `--effort` and also accepts `max`.

For models with slashes or extra colons, prefer keyed form:

```bash
"$AUTOREVIEW" --reviewers codex,claude --model codex=gpt-5.6-sol --model claude=claude-fable-5
```

## Engine Details

Use [references/engine-details.md](references/engine-details.md) for model defaults, environment overrides, Claude fallback models, and Codex/Claude isolation details.

## Context Efficiency

Run the helper directly so target selection, engine choice, structured validation, and exit status all stay in one path. If output is noisy, summarize the completed helper output after it returns; do not ask another agent or reviewer to rerun the review.

## Helper

After setting `AUTOREVIEW` and `AUTOREVIEW_HARNESS` above:

```bash
"$AUTOREVIEW" --help
```

The smoke harness has thin shell wrappers over a shared Python implementation:

```bash
"$AUTOREVIEW_HARNESS" --fixture benign --engine codex
```

The helper:

- chooses dirty local changes first, otherwise PR base, otherwise `origin/main` for non-main branches; branch review does not fetch automatically.
- supports Codex and Claude only; Codex is the default, and panels are opt-in with `--panel` or `--reviewers`.
- treats `--prompt-file` and `--dataset` as repo-relative inputs, with sensitive paths, symlinks, oversized content, and secret-looking values guarded.
- resolves commands safely outside the reviewed checkout and runs reviewers with read-only/tool-isolated settings; see [references/engine-details.md](references/engine-details.md).
- prints a clean line and exits 0 when no accepted/actionable findings remain; exits nonzero when accepted/actionable findings are present.

## Final Report

Include:

- review command used
- tests/proof run
- findings accepted/rejected, briefly why
- the clean review result from the final helper/review run, or why a remaining finding was consciously rejected

Do not run another review solely to improve the final report wording. If the final helper run exited 0 and produced no accepted/actionable findings, report that exact run as clean.

## References

- [references/troubleshooting.md](references/troubleshooting.md) - security-audit suppression and other edge-case closeout notes
- [references/scope.md](references/scope.md) - scope governor and release-branch freeze rules
- [references/engine-details.md](references/engine-details.md) - model defaults, environment overrides, and engine isolation details
- [references/upstream.md](references/upstream.md) - OpenClaw upstream provenance and local packaging notes
