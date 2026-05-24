---
name: autoreview
description: "Run structured Codex/Claude autoreview closeout for uncommitted changes, branch/PR diffs, or single commits: choose the target, run the bundled review helper, validate findings, and rerun focused tests until clean. Use when asked for autoreview, Codex review, Claude review, automated PR review, second-model review, or merge-readiness review."
---

# Auto Review

Run the bundled structured review helper as a closeout check. This is code review, not Guardian `auto_review` approval routing.

Use when:

- user asks for Codex review / Claude review / autoreview / second-model review
- after non-trivial code edits, before final/commit/ship
- reviewing a local branch or PR branch after fixes

## Contract

- Treat review output as advisory: verify findings against real code, adjacent files, and dependency docs/types when relevant.
- Reject unrealistic edge cases, speculative risks, broad rewrites, and over-complicated fixes.
- If a review-triggered fix changes code, rerun focused tests and the structured review helper until it exits 0 with no accepted/actionable findings.
- Never switch or override the requested review engine/model. If the review hits model capacity, retry the same command a few times with the same engine/model.
- Report security findings only when the change creates a concrete, actionable risk or removes an important safety check.
- Do not invoke built-in `codex review`, nested reviewers, or reviewer panels from inside the review. The helper builds one bundle, calls one selected engine, validates one structured result, and stops.
- Stop as soon as the helper exits 0 with no accepted/actionable findings; do not run an extra review just for a nicer "clean" line, second opinion, or clearer closeout wording.
- If rejecting a finding as intentional/not worth fixing, add a brief inline code comment only when it explains a real invariant or ownership decision that future reviewers should know.
- Route security-audit suppression closeout through [references/troubleshooting.md](references/troubleshooting.md).
- Do not push just to review. Push only when the user requested push/ship/PR update.

For upstream provenance, use [references/upstream.md](references/upstream.md).

## Helper Path

Resolve the helper from this skill directory before choosing a target, and keep
your shell cwd in the git repo being reviewed:

```bash
SKILL_DIR="<directory containing this SKILL.md>"
AUTOREVIEW="$SKILL_DIR/scripts/autoreview"
"$AUTOREVIEW" --help
```

Do not look for or create `scripts/autoreview` in the target repo. The target
repo only supplies the git diff; the executable helper is bundled with this
skill.

## Pick Target

Dirty local work:

```bash
"$AUTOREVIEW" --mode local
```

Use this only when the patch is actually unstaged/staged/untracked. For committed,
pushed, or PR work, point the helper at the commit or branch diff instead.

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

Use commit review for already-landed or already-pushed work on `main`. For a
small stack, review each commit explicitly or review the branch before merging.

## Parallel Closeout

Format first if formatting can change line locations. Then it is OK to run tests and review in parallel:

```bash
"$AUTOREVIEW" --parallel-tests "<focused test command>"
```

If tests or review lead to code edits, rerun the affected tests and structured review once more.

## Helper

Bundled helper: [scripts/autoreview](scripts/autoreview)

Use `--help` for flags. Codex is the default engine, and Claude is supported.
The helper validates structured output,
prints `autoreview clean: no accepted/actionable findings reported` when clean,
and exits nonzero when accepted/actionable findings are present.

Smoke harness: [scripts/test-review-harness](scripts/test-review-harness)

## Final Report

Include:

- review command used
- tests/proof run
- findings accepted/rejected, briefly why
- the clean review result from the final helper/review run, or why a remaining finding was consciously rejected
