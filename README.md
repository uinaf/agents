# agents

Reusable agent skills, global behavioral rules, and a small sync script for AI coding agents.

## Layout

- `skills/` — local skill packages.
- `rules/agents.md` — global behavioral rules.
- `scripts/sync/sync.sh` — symlink rules and install manifest skills.
- `scripts/skills/` — Tessl review helpers.
- `docs/` — distribution notes.

## Sync (rules + skills together)

```bash
git clone git@github.com:uinaf/agents.git
cd agents
./scripts/sync/sync.sh
```

Sync is additive by default. To remove stale globally installed skills whose source is `uinaf/agents`, run:

```bash
./scripts/sync/sync.sh --prune
```

## Evaluate

```bash
./scripts/skills/review.sh
./scripts/skills/optimize.sh review
```
