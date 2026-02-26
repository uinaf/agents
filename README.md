# agents

Shared AI agent guidelines and skills. One file, every machine.

## What's in here

- **src/AGENTS.md** — coding rules for AI agents (Claude Code, Codex, Cursor, etc.)
- **src/skills.json** — stable, portable skills manifest (source-of-truth)
  - includes `version` + `manifestHash` for sync integrity

## Setup

```bash
git clone git@github.com:uinaf/agents.git ~/projects/agents
~/projects/agents/scripts/pull.sh
```

This will:

1. Symlink `~/.claude/CLAUDE.md` → `src/AGENTS.md`
2. Symlink `~/.codex/AGENTS.md` → `src/AGENTS.md`
3. Install global skills from `src/skills.json` (portable manifest)

## Update

```bash
~/projects/agents/scripts/pull.sh
```

## Push changes

```bash
~/projects/agents/scripts/push.sh
```

Syncs your local global skill set into `src/skills.json`, commits, and pushes.

## Adding skills

```bash
npx skills add owner/repo -g
~/projects/agents/scripts/push.sh
```
