# agents

Shared AI agent guidelines and skills. One file, every machine.

## What's in here

- **AGENTS.md** — coding rules for AI agents (Claude Code, Codex, Cursor, etc.)
- **.skill-lock.json** — tracks installed skills from [skills.sh](https://skills.sh)

## Setup

```bash
git clone git@github.com:uinaf/agents.git ~/projects/agents
~/projects/agents/scripts/install.sh
```

This will:
1. Symlink `~/.claude/CLAUDE.md` → `AGENTS.md`
2. Symlink `~/.codex/AGENTS.md` → `AGENTS.md`
3. Install global skills from the lockfile

## Update

```bash
~/projects/agents/scripts/install.sh
```

## Push changes

```bash
~/projects/agents/scripts/push.sh
```

Syncs your local skill-lock, commits, and pushes.

## Adding skills

```bash
npx skills add owner/repo -g
~/projects/agents/scripts/push.sh
```
