---
name: autoreview
description: "Run structured Codex/Claude autoreview closeout for local changes, pull requests, branch diffs, or commits: choose the target, validate findings, rerun focused tests, and repeat review until clean. Use when asked for autoreview, second-model review, pre-merge review, or readiness-to-ship review."
---

# Auto Review

Run the bundled structured review helper as a closeout check. This is code review, not Guardian `auto_review` approval routing.

Codex review is the default when no engine is set. It usually delivers the best review results and should remain the normal final closeout engine.

Use when:

- user asks for Codex review / Claude review / autoreview / second-model review
- after non-trivial code edits, before final/commit/ship
- reviewing a local branch or PR branch after fixes

## Contract

- Treat review output as advisory: verify every finding against real code, adjacent files, and dependency docs/types when relevant.
- Reject unrealistic edge cases, speculative risks, broad rewrites, and fixes that over-complicate the codebase.
- Prefer small fixes at the right ownership boundary; no refactor unless it clearly improves the bug class.
- When an accepted finding shows a bug class or repeated pattern, inspect the current PR scope for sibling instances before fixing.
- Keep going until structured review returns no accepted/actionable findings; if a review-triggered fix changes code, rerun focused tests and review.
- Never switch or override the requested review engine/model. If the review hits model capacity, retry the same command a few times with the same engine/model.
- Security perspective is always included, but it should not cripple legitimate functionality. Report security findings only when the change creates a concrete, actionable risk or removes an important safety check.
- Do not invoke built-in `codex review`, nested reviewers, or reviewer panels from inside the review. The helper builds one bundle, calls one selected engine, validates one structured result, and stops.
- Multi-reviewer panels are opt-in only. Use them when explicitly requested or when risk justifies the extra spend; the main agent still verifies every accepted finding before fixing.
- Do not push just to review. Push only when the user requested push/ship/PR update.

Use [references/troubleshooting.md](references/troubleshooting.md) for heartbeat patience, Gitcrawl repair, provenance, security-suppression, and other edge-case closeout rules.

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

Optional review context is first-class:

```bash
"$AUTOREVIEW" --mode branch --base origin/main --prompt-file /tmp/review-notes.md --dataset /tmp/evidence.json
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
"$AUTOREVIEW" --reviewers codex,claude --model codex=gpt-5.1 --thinking codex=high --model claude=sonnet --thinking claude=max
```

Inline syntax is also supported:

```bash
"$AUTOREVIEW" --reviewers codex:gpt-5.1:high,claude:sonnet:max
```

Codex maps thinking to `model_reasoning_effort` and accepts `low`, `medium`,
`high`, or `xhigh`. Claude maps thinking to `--effort` and also accepts `max`.
Engines without a real thinking knob reject `--thinking`.

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

- chooses dirty local changes first
- accepts `--mode uncommitted` as an alias for `--mode local`
- otherwise uses current PR base if `gh pr view` works
- otherwise uses `origin/main` for non-main branches
- supports `--engine codex` and `claude`; default is `AUTOREVIEW_ENGINE` or `codex`; Codex should remain the default when nothing is set
- resolves bare `git`, `gh`, and reviewer commands from absolute `PATH` entries only, never from the reviewed checkout; explicit relative `--*-bin` paths are resolved from the reviewed repository root
- use `--mode commit --commit <ref>` for already-committed work, especially clean `main` after landing
- should be left in `--mode auto` or forced to `--mode branch` for PR/branch work; do not force `--mode local` after committing
- writes only to stdout unless `--output`, `--json-output`, or live streamed engine stderr is set
- supports `--dry-run`, `--parallel-tests`, `--prompt`, `--prompt-file`, `--dataset`, `--no-tools`, `--no-web-search`, and commit refs
- supports `--stream-engine-output` or `AUTOREVIEW_STREAM_ENGINE_OUTPUT=1` for live engine text while preserving structured validation; Codex and Claude hide tool/file event details, emit compact activity summaries, and report usage at turn completion
- supports opt-in review panels with `--panel` / `--reviewers`, plus per-engine `--model` and `--thinking`
- allows read-only tools and web search by default where the selected CLI supports them; forbids nested review in the prompt; Codex is run through `codex exec` with read-only sandbox and structured output
- prints `review still running: <engine> elapsed=<seconds>s pid=<pid>` to stderr at long-running intervals while waiting for the selected review engine, unless streamed output or compact Codex activity has been visible recently
- prints `autoreview clean: no accepted/actionable findings reported` when the selected review command exits 0
- exits nonzero when accepted/actionable findings are present

## Final Report

Include:

- review command used
- tests/proof run
- findings accepted/rejected, briefly why
- the clean review result from the final helper/review run, or why a remaining finding was consciously rejected

Do not run another review solely to improve the final report wording. If the final helper run exited 0 and produced no accepted/actionable findings, report that exact run as clean.

## References

- [references/troubleshooting.md](references/troubleshooting.md) - security-audit suppression and other edge-case closeout notes
- [references/upstream.md](references/upstream.md) - OpenClaw upstream provenance and local packaging notes
