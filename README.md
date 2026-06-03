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

Sync is additive and manifest-driven. It installs every skill listed in
`scripts/sync/skills.json` for the supported agents installed on the machine,
and does not remove globally installed skills that are outside the manifest.

The sync script pins the `skills` CLI by default. Override with
`SKILLS_CLI_VERSION=<version>` only when intentionally testing or rotating the
installer.

## Evaluate

```bash
./scripts/skills/review.sh
./scripts/skills/optimize.sh review-gang
```

The Tessl helper scripts pin the `tessl` CLI by default. Override with
`TESSL_CLI_VERSION=<version>` when intentionally rotating the evaluator.
