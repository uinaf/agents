---
name: sdlc-ded
description: "ALL coding work. Features, fixes, refactors — never hand-code. Delegates to coding-agent, reviews, ships or escalates."
---

# sdlc-ded

ALL coding goes through here. Never hand-code — always delegate.
[coding-agent](https://github.com/openclaw/openclaw/blob/main/skills/coding-agent/SKILL.md) provides exec patterns (pty, background, worktree, process monitoring). This skill provides the workflow.

## The Loop

```
Scope → Delegate → Agent verifies → Orchestrator reviews → Guardrails pass → Ship
                                                              ↓ fail
                                                         Respawn (max 3) → Escalate
```

1. **Scope** — write task brief (mandatory, see template below)
2. **Delegate** — spin up coding agent in worktree
3. **Agent self-verifies** — tests, lint, typecheck, real-data sanity check (per AGENTS.md)
4. **Orchestrator reviews** — read key diffs, check constraints, no scope creep
5. **Guardrails pass** → ship (push to main by default)
6. **Guardrails fail** → respawn agent with fix prompt (max 3 attempts)
7. **3 respawns exhausted or novel issue** → escalate to user with full context

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

Always append to prompt:
- Self-review before finishing: edge cases, error handling, test coverage
- Run verification commands before declaring done
- Run the actual thing with real data and verify outputs make sense

## Verification

Agent owns verification (per `agents/src/AGENTS.md`). Orchestrator sanity-checks:
- Read key diffs — does the change match the brief?
- Smell-test outputs if applicable (numbers, dates, API responses)
- If something looks off, dig in before pushing

## Delegation

Use `exec pty:true background:true` patterns from coding-agent skill.

- Isolate in worktree: `git worktree add -b <slug> ~/worktrees/<repo>/<slug>`
- Append wake trigger to every prompt:
  `When finished, run: openclaw system event --text "Done (pass|fail): <summary>" --mode now`
- One task per agent. Don't mix concerns.
- If no system event after ~15min, check `process:log`.

### After launch: fire and forget

1. `exec pty:true background:true` — launch
2. **Move on immediately.** Respond to user. Do other work.
3. System event wakes you when agent finishes
4. Then `process:log` to read results and review
5. **Never poll. Never block. Never wait.**

## Ship Modes

**Default: push to main.** User controls ceremony level per task.

| Mode | Trigger | Flow |
|---|---|---|
| **Yolo** (default) | nothing / "push it" | guardrails green → push to main |
| **PR** | "make a PR" | branch + push + PR, merge on user's call |
| **Stacked** | "stack it" | graphite stacked PRs |
| **Review** | "review this" | `codex review --base main` before push |

**Never push red.** If any guardrail fails (tests, lint, typecheck) → fix first or escalate. This is the one absolute gate.

## Merge + Cleanup

```bash
cd ~/projects/<repo> && git merge <slug> && git push
git worktree remove ~/worktrees/<repo>/<slug>
git branch -d <slug>
```

Cleanup is part of "done." No cleanup = not done.

## Report

```markdown
## Result
- Status: done | blocked | escalated
- Changes: what shipped
- Verification: what passed
- Worktree: cleaned up yes/no
- Risks / follow-ups:
```

## Hard Rules

### Never hand-patch
CI failing, tests red, agent output broken → **delegate to coding agent.** Not "let me just look at it." Delegate. If agent fails 3 times → escalate to user. You are an orchestrator, not a coder.

### Never swap tools
User says Codex → use Codex. Tool fails → fix the invocation (flags, env, workdir). Max 2 retries on invocation issues. Then escalate to user with the error. **Never silently switch to another tool.**

### Respawn limit
Max 3 agent attempts on the same task. After that → escalate with: what was tried, what failed, error output. Stop burning tokens.

## Tool Reference

⚠️ **Both Codex CLI and Claude Code require PTY.** Always use `exec pty:true background:true`. Never `& disown` — process dies silently without TTY.

### Codex CLI
```bash
# Default — no sandbox, no approvals:
codex --yolo exec "<prompt>"

# Sandboxed alternative (when user asks):
codex exec --full-auto "<prompt>"

# Review:
codex review --base main
codex review --uncommitted
codex review --commit <sha>
```

### Claude Code
```bash
claude --dangerously-skip-permissions -p "<prompt>"
```
