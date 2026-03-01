---
name: sdlc-ded
description: "ALL coding work. Features, fixes, refactors — never hand-code. Delegates to coding-agent, reviews, ships or escalates."
---

# sdlc-ded

ALL coding goes through here. Never hand-code — always delegate.

## The Loop

```
Scope → Delegate → Agent does everything → Orchestrator reviews → Merge
                                                    ↓ fail
                                               Respawn (max 3) → Escalate
```

1. **Scope** — write task brief (mandatory, see template below)
2. **Delegate** — create worktree, launch agent
3. **Agent does everything** — code, test, commit, push branch, fire system event
4. **Orchestrator reviews** — read diffs, check constraints, no scope creep
5. **Merge** — orchestrator merges branch + cleans up worktree
6. **Guardrails fail** → respawn agent with fix prompt (max 3 attempts)
7. **3 respawns exhausted** → escalate to user with full context

## Task Brief (mandatory)

No structured brief = no delegation. Every prompt must include:

```markdown
## Task: <title>
**Goal:** one sentence
**Context:** key files/docs/APIs
**Constraints:** what NOT to do
**Done when:** verifiable success criteria
**Verify:** concrete commands (tests + real-data run)
**Read first:** AGENTS.md
```

Always append to every prompt:

```markdown
**When done:**
1. Self-review: edge cases, error handling, test coverage
2. Run verification commands and confirm green
3. Commit with a conventional commit message
4. Push your branch: `git push origin HEAD`
5. Run: `/opt/homebrew/bin/openclaw system event --text "Done: <summary>" --mode now`
```

## Delegation

**Default tool: Codex CLI.** Faster than Claude Code (2-4min vs 8-10min). Only use Claude Code if user asks or task requires it.

**One task per agent.** Never batch multiple issues into one prompt — they time out.

**Timeout: 900s (15min).** Single tasks finish in 2-4min on Codex, 8-10min on Claude Code. 15min gives headroom.

```bash
# 1. Create worktree
cd ~/projects/<repo>
git worktree add -b <branch> ~/worktrees/<repo>/<branch>

# 2. Launch agent (fire and forget)
cd ~/worktrees/<repo>/<branch> && codex --yolo exec "<prompt>"
# exec with: pty:true, background:true, timeout:900

# 3. Move on immediately. System event wakes you.
```

### After launch: fire and forget

1. `exec pty:true background:true timeout:900` — launch
2. **Move on immediately.** Respond to user. Do other work.
3. System event wakes you when agent finishes
4. Check worktree `git log` + `git diff main` to review (PTY output is unreadable)
5. **Never poll. Never block. Never wait.**

## Review

Orchestrator reviews after agent completes:
- `git diff main --stat` — scope check
- `git diff main -- src/` — read key changes
- Verify agent ran guardrails (check commit message or log)
- Smell-test: does the change match the brief? No scope creep?

## Ship Modes

**Default: branch → review → merge.** Agent pushes branch, orchestrator reviews, then merges.

| Mode | Trigger | Flow |
|---|---|---|
| **Branch** (default) | nothing | agent pushes branch → review → merge |
| **Yolo** | "push it" / "merge" | review → merge to main immediately |
| **PR** | "make a PR" | branch + push + GitHub PR |
| **Stacked** | "stack it" | graphite stacked PRs |

**Never push red.** If any guardrail fails (tests, lint, typecheck) → fix first or escalate.

## Merge + Cleanup

```bash
cd ~/projects/<repo> && git merge <branch> --no-ff && git push
git worktree remove ~/worktrees/<repo>/<branch>
git branch -d <branch>
```

Cleanup is part of "done." No cleanup = not done.

## Hard Rules

### Never hand-patch
CI failing, tests red, agent output broken → delegate to coding agent. Not "let me just look at it." Delegate. If agent fails 3 times → escalate.

### Never swap tools
User says Codex → use Codex. Tool fails → fix invocation, max 2 retries. Then escalate. Never silently switch.

### Respawn limit
Max 3 agent attempts per task. Then escalate with: what was tried, what failed, error output.

### One concern per agent
Don't batch unrelated issues. Related or chained tasks (fix + update docs, refactor + add tests) are fine in one prompt.

## Tool Reference

⚠️ **Both tools require PTY.** Always `exec pty:true background:true`. Never `& disown`.

### Codex CLI (default)
```bash
codex --yolo exec "<prompt>"
```

### Claude Code (when requested)
```bash
claude --dangerously-skip-permissions -p "<prompt>"
```

### Codex Review
```bash
codex review --base main
codex review --uncommitted
codex review --commit <sha>
```
