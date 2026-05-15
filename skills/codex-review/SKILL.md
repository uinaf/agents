---
name: codex-review
description: "Run the Codex CLI `codex review` command as an advisory closeout pass: choose the right target, run local/branch/commit review, filter findings, and rerun focused tests plus review after fixes. Use when the user asks for Codex review, codex-review, autoreview, second-model review, or a final `codex review` sweep. Do not use for ordinary review verdicts; use `review` for that."
---

# Codex Review

Run the Codex CLI `codex review` command as an advisory closeout pass.

## Use When

- The user asks for Codex review, autoreview, or a second-model review
- A non-trivial local change needs a final advisory sweep before final, commit, push, or ship
- A branch or PR branch was fixed and needs a closeout pass against its base
- A single committed change needs review without reviewing unrelated local dirt

## Contract

- Treat review output as advisory; verify findings in real code and dependency docs before changing anything.
- Reject unrealistic edge cases, speculative risks, broad rewrites, and over-complicated fixes.
- Prefer small fixes at the right ownership boundary.
- If a review-triggered fix changes code, rerun focused tests and rerun `codex review`.
- Keep the review model unchanged; retry the same command on model capacity and use `--full-access` only when the environment allows it.
- Stop as soon as the review command or helper exits cleanly with no accepted/actionable findings.
- Do not push just to review. Push only when the user requested push, ship, or PR update.

## Pick Target

Dirty local work:

```bash
codex review --uncommitted
```

Use this only when the patch is actually unstaged, staged, or untracked. For committed, pushed, or PR work, review the branch against its base instead. A clean `--uncommitted` review only proves there is no local patch.

Branch or PR work:

```bash
git fetch origin
codex review --base origin/main
```

Do not pass an inline prompt with `--base`; current CLI rejects `--base` plus a prompt. If custom instructions are needed, run the plain base review first, then do a local/manual follow-up pass.

If an open PR exists, use its actual base:

```bash
base=$(gh pr view --json baseRefName --jq .baseRefName)
codex review --base "origin/$base"
```

Committed single change:

```bash
codex review --commit HEAD
```

## Helper Script

Use the bundled helper when target selection, output capture, or parallel tests would otherwise be hand-rolled.

Installed skill path:

```bash
"$HOME/.agents/skills/codex-review/scripts/codex-review" --help
```

Repo checkout path:

```bash
skills/codex-review/scripts/codex-review --help
```

The extensionless `codex-review` entrypoint delegates to `codex-review.sh`; use either path if the install preserves executable bits. Leave the helper in `--mode auto` for ordinary local work. Force `--mode branch` for committed PR work when the tree has unrelated local dirt. Use `--help` for the full option list.

## Parallel Closeout

Format first if formatting can change line locations. Then it is acceptable to run review and focused tests in parallel:

```bash
skills/codex-review/scripts/codex-review --parallel-tests "<focused test command>"
```

Tradeoff: tests may force code changes that make review stale. If tests or review lead to code edits, rerun the affected tests and rerun review until no accepted/actionable findings remain.

## Context Efficiency

Codex review can be noisy. When subagents are allowed, use a separate reviewer/filter and ask for accepted findings, rejected findings with one-line reasons, and exact files or tests to rerun. Run inline for tiny changes or when subagents are unavailable or disallowed.

## Final Report

Include:

- review command used
- tests or proof run
- findings accepted or rejected, briefly why
- the clean review result from the final helper/review run, or why a remaining finding was consciously rejected

Do not run another Codex review solely to improve the final report wording. If the final helper run exited 0 and produced no accepted/actionable findings, report that exact run as clean.

## Attribution

Adapted with credit from Peter Steinberger's [`agent-scripts` codex-review skill](https://github.com/steipete/agent-scripts/tree/main/skills/codex-review). This fork uses repo-relative and `$HOME/.agents/skills` paths instead of personal checkout paths. The bundled helper keeps the upstream MIT notice in `LICENSE.upstream`.
