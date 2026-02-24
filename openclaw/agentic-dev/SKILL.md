---
name: agentic-dev
description: Orchestrate non-trivial coding work via tmux-based coding agents. Use for plan → delegate → steer → verify workflows on real repositories.
---

# Agentic Dev

Use this skill for non-trivial coding tasks.
Keep behavior/style/quality rules in `AGENTS.md`.

## Workflow

research → short plan → delegate in tmux → steer if needed → verify

## Task Brief Template

```markdown
## Task: <title>
**Goal:** one sentence
**Context:** key files/docs/APIs
**Constraints:** what NOT to do
**Tests:** what to add/update
**Done when:** verifiable success criteria
**Verify:** concrete commands
**Read first:** AGENTS.md
```

If the goal cannot fit in one sentence, split the task.

## Pre-flight

- Confirm instruction links/files are present.
- Confirm CI/workflow scaffolding exists.
- If setup is broken, fix setup separately before feature work.

## Execution

- Use tmux sessions for coding agents.
- Do not use one-shot execution.
- Use an isolated task context (repo clone or worktree).
- Worktrees are optional.
- Session name format: `<agent>-<repo>-<task-slug>`.

## Helper Script

Use `scripts/tmux-agent.sh` to avoid repeating fragile shell quoting.

### Start sessions

```bash
SESSION="codex-<repo>-<task>"
WORKDIR="/absolute/path/to/repo-or-worktree"
PROMPT_FILE="/tmp/task-prompt.md"

scripts/tmux-agent.sh start codex "$SESSION" "$WORKDIR" "$PROMPT_FILE"
# or
scripts/tmux-agent.sh start claude "$SESSION" "$WORKDIR" "$PROMPT_FILE"
```

### First-run handshake + readiness

```bash
scripts/tmux-agent.sh handshake "$SESSION"
scripts/tmux-agent.sh ready "$SESSION"
```

### Monitor / steer / stop

```bash
scripts/tmux-agent.sh ls
scripts/tmux-agent.sh tail "$SESSION" 220
scripts/tmux-agent.sh done "$SESSION"   # checks for __DONE__ marker
scripts/tmux-agent.sh steer "$SESSION" "Stop. Focus on <specific scope>."
scripts/tmux-agent.sh stop "$SESSION"
scripts/tmux-agent.sh kill "$SESSION"   # last resort
```

## Delegation Rules

- Delegate non-trivial coding work; do not implement directly in orchestrator mode.
- Do not mix setup fixes and feature work in one run.
- Keep scope tight and testable.
- If agent drifts, steer in-session before restarting.
- Return concrete verification output with final result.

## Failure Handling

- Missing context: provide exact files/constraints.
- Environment/setup issue: stop and report root cause.
- Retry only with a clearer scoped prompt.
- Escalate when risky tradeoffs need user input.

## Git / PR

- Follow repo strategy (direct push vs branch+PR).
- Use concise conventional commits.
- For PRs, include: Summary, Changes, Validation, Linked Issues.

## Completion Standard

Complete only when:
- success criteria are met,
- verification commands pass,
- and outputs are clearly reported.

## Final Report Format

```markdown
## Result
- Status: done | blocked
- Scope delivered:
- Files changed:
- Verification run:
- Verification output summary:
- Risks / follow-ups:
```
