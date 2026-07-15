# agents

Reusable agent skills, global behavioral rules, and a small sync script for AI coding agents.

## Layout

- `skills/` — local Tessl plugin packages with `SKILL.md`, `.tessl-plugin/plugin.json`, and optional `evals/`.
- `rules/agents.md` — global behavioral rules.
- `rules/agents.local.md` — optional private machine-specific overrides, ignored by git.
- `rules/agents.final.md` — generated combined rules, ignored by git.
- `scripts/sync/sync.sh` — stable wrapper for the typed rules and skill sync.
- `scripts/skills/` — Tessl review and publish helpers.
- `docs/` — distribution notes.

`agents.local.md` is inserted beneath the generated `## Local Overrides`
section, so local content should begin at `###` heading depth.

## Sync (rules + skills together)

```bash
git clone git@github.com:uinaf/agents.git
cd agents
./scripts/sync/sync.sh
```

Skill installation is additive and manifest-driven. Sync installs every skill
listed in `scripts/sync/skills.json` for the supported agents on the machine and
does not remove globally installed skills outside the manifest.

Run sync only from the primary checkout on `main`. Before changing global agent
state, it requires a clean tracked checkout, fast-forwards, and confirms local
`main` exactly matches its upstream. Ignored `rules/agents.local.md` and the
generated `rules/agents.final.md` remain allowed. Sync creates absent global
rule links or replaces links already managed by this checkout; it refuses to
overwrite regular files or foreign symlinks.

The sync script pins the `skills` CLI by default. Override with
`SKILLS_CLI_VERSION=<version>` only when intentionally testing or rotating the
installer.

## Verify

```bash
npm ci
npm run verify
```

The local gate typechecks and tests the sync CLI, runs the autoreview tests, and
lints shell scripts, GitHub Actions workflows, and every local skill. It expects
ShellCheck on `PATH`; CI runs the same command.

## Evaluate

```bash
./scripts/skills/review.sh
./scripts/skills/optimize.sh review-gang
```

The Tessl helper scripts pin the `tessl` CLI by default. Override with
`TESSL_CLI_VERSION=<version>` when intentionally rotating the evaluator.
