---
name: sdlc-ded
description: "ALL coding work. Features, fixes, refactors - never hand-code. Delegate via ACP coding agents, review, ship, or escalate."
---

# sdlc-ded

ALL coding goes through here. Never hand-code - always delegate.

## The Loop

```
Scope → Delegate (ACP) → Agent does everything → Orchestrator reviews → Merge
                                                    ↓ fail
                                               Respawn (max 3) → Escalate
```

1. **Scope** - write task brief (mandatory, see template)
2. **Delegate** - create worktree, spawn ACP session
3. **Agent does everything** - code, test, commit, push branch, fire system event
4. **Orchestrator reviews** - read diffs, check constraints, no scope creep
5. **Merge** - merge branch + clean worktree
6. **Guardrails fail** → respawn agent with fix prompt (max 3 attempts)
7. **3 respawns exhausted** → escalate with full context

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

Always append:

```markdown
**When done:**
1. Self-review: edge cases, error handling, test coverage
2. Run verification commands and confirm green
3. Commit with a conventional commit message
4. Push your branch: `git push origin HEAD`
5. Run: `/opt/homebrew/bin/openclaw system event --text "Done: <summary>" --mode now`
6. If an announce/completion reply is requested, output exactly: `ANNOUNCE_SKIP`
```

## Delegation

### 1) Prepare worktree

```bash
cd ~/projects/<repo>
git worktree add -b <branch> ~/worktrees/<repo>/<branch>
```

### 2) Spawn via acp-router

ACP routing and spawn mechanics are owned by the `acp-router` skill. sdlc-ded prepares the brief + worktree, then hands off.

Pass to acp-router:
- `cwd: "~/worktrees/<repo>/<branch>"`
- `task: <full brief from template above>`
- `agentId: "codex"` (default) or whatever harness was requested

acp-router handles: `sessions_spawn` calls, agentId mapping, thread vs one-shot, recovery/fallback, direct acpx path.

### 3) Fire and forget

1. Spawn via acp-router
2. Move on immediately; do not block
3. Wait for system event completion
4. Review via git history/diff

### 4) Delivery hygiene (mandatory)

- Treat ACP as silent background execution for chat users.
- Never let raw ACP agent chatter reach the user.
- Require announce suppression in task briefs (`ANNOUNCE_SKIP`).
- Send only sanitized orchestrator updates: status + final diff/verify summary.
- **No fallback to running CLI directly.** Always use ACPX via `sessions_spawn`. If ACPX leaks or misbehaves, escalate — don't work around it by running `codex` or `claude` in a PTY.

## Review

After agent completion:
- `git diff main --stat` - scope check
- `git diff main -- <key paths>` - read critical changes
- Confirm guardrails ran and are green
- Verify brief alignment and no scope creep

## Ship Modes

**Default: branch → review → merge**

| Mode | Trigger | Flow |
|---|---|---|
| **Branch** (default) | nothing | agent pushes branch → review → merge |
| **Yolo** | "push it" / "merge" | review → merge to main immediately |
| **PR** | "make a PR" | branch + push + PR |
| **Stacked** | "stack it" | stacked PR flow |

**Never push red.** If guardrails fail → fix or escalate.

## Merge + Cleanup

```bash
cd ~/projects/<repo> && git merge <branch> --no-ff && git push
git worktree remove ~/worktrees/<repo>/<branch>
git branch -d <branch>
```

Cleanup is part of done.

## Hard Rules

### Never hand-patch
CI failing or broken output → delegate again. Max 3 attempts, then escalate.

### Never swap requested harness silently
If user asked Codex, use ACP `agentId: codex`. If invocation fails, retry invocation (max 2), then escalate.

### Respawn limit
Max 3 attempts per task. Then escalate with: attempts, errors, why blocked.

### One concern per agent
Don't batch unrelated issues into one task.
