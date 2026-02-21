# agents

Shared AI agent guidelines and skills. One file, every machine.

## What's in here

- **AGENTS.md** — coding rules for AI agents (Claude Code, Codex, Cursor, etc.)
- **skills/skills.json** — stable, portable skills manifest (source-of-truth)
- **skills/.skill-lock.json** — legacy lockfile reference (fallback only)

## Setup

```bash
git clone git@github.com:uinaf/agents.git ~/projects/agents
~/projects/agents/scripts/install.sh
```

This will:
1. Symlink `~/.claude/CLAUDE.md` → `AGENTS.md`
2. Symlink `~/.codex/AGENTS.md` → `AGENTS.md`
3. Install global skills from `skills/skills.json` (portable manifest)

## Update

```bash
~/projects/agents/scripts/install.sh
```

## Push changes

```bash
~/projects/agents/scripts/push.sh
```

Syncs your local global skill set into `skills/skills.json`, commits, and pushes.

## Adding skills

```bash
npx skills add owner/repo -g
~/projects/agents/scripts/push.sh
```
