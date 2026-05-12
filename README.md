# agents

Reusable agent skills, global behavioral rules, and a small sync script for AI coding agents.

## Layout

- `skills/` — local skill packages.
- `rules/agents.md` — global behavioral rules.
- `rules/agents.local.md` — optional private machine-specific overrides, ignored by git.
- `rules/agents.final.md` — generated combined rules, ignored by git.
- `scripts/sync/sync.sh` — symlink rules and install manifest skills.
- `scripts/skills/` — Tessl review helpers.
- `docs/` — distribution notes.

## Sync (rules + skills together)

```bash
git clone git@github.com:uinaf/agents.git
cd agents
./scripts/sync/sync.sh
```

Sync is additive by default. To remove globally installed skills that are not listed in `scripts/sync/skills.json`, run:

```bash
./scripts/sync/sync.sh --prune
```

Third-party skill sources are skipped by default during sync. Set `ALLOW_THIRD_PARTY_SKILLS=1` only when intentionally installing non-`uinaf/agents` skills.

## Evaluate

```bash
./scripts/skills/review.sh
./scripts/skills/optimize.sh review
```
