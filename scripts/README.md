# Skill Evaluation

This repo uses Tessl as the evaluation loop for skill quality, clarity, self-activation, and impact scenarios.

## Sync

The public entrypoint remains a small compatibility wrapper around the typed
Node 24 implementation in `sync/sync.ts`:

```bash
./scripts/sync/sync.sh
```

Run the canonical local gate without pulling repositories or changing globally
installed skills:

```bash
npm ci
npm run verify
```

The gate expects ShellCheck on `PATH`; actionlint and the TypeScript toolchain
are installed from the lockfile. It also rejects OpenAI skill interface prompts
over Codex's 1,024-character limit so they cannot be silently ignored. The
validator parses YAML before measuring the decoded prompt value.

The sync tests use an isolated fixture runtime. They prove that every manifest
skill is attempted, installer failures are reported together, a partial failure
exits nonzero, invalid manifests fail clearly, and a fully successful run still
generates and links the expected rules. CI runs the same verification command
on pull requests and pushes to `main`.

Sync refuses linked worktrees and non-`main` branches before pulling or changing
global agent state. Installer failures include a bounded diagnostic with common
credential-shaped values redacted.

## Review

Run a read-only plugin lint plus quality review across every local skill:

```bash
./scripts/skills/review.sh
```

By default this enforces `--threshold 90` in the `uinaf` workspace. Override with `TESSL_THRESHOLD=94`, `TESSL_WORKSPACE=<name>`, or pass `--threshold` / `--workspace` explicitly.
The wrapper pins the Tessl CLI through `TESSL_CLI_VERSION`, defaulting to the
version in the script. Bump it intentionally rather than relying on moving npm
latest.

In CI, Tessl has two lanes:

- Pull requests run with `TESSL_REVIEW_MODE=lint` and no `TESSL_TOKEN`, so
  untrusted PR code only gets deterministic plugin structure validation.
- Trusted `main` review runs through the GitHub `release` environment with
  `TESSL_TOKEN` and executes authenticated `tessl review run`.

Set `TESSL_REVIEW_MODE=lint` to force the pull-request lane locally. If `CI` is
set and `TESSL_TOKEN` is absent, the wrapper also falls back to lint mode.

Useful direct invocations:

```bash
npx tessl@0.90.0 review run --workspace uinaf skills/review-gang
npx tessl@0.90.0 review run --json --workspace uinaf --threshold 90 skills/verify
npx tessl@0.90.0 plugin lint skills/vite-plus
```

Use per-skill `--json` output directly with Tessl rather than `skills/review.sh`, because the batch wrapper emits one review per skill.

## Impact evals

Eval scenarios live under each skill's `evals/` directory. Generate missing scenarios with Tessl and merge them into the target skill:

```bash
tessl scenario generate --workspace uinaf --count 3 skills/<skill-name>
tessl scenario download --output skills/<skill-name>/evals --strategy merge <generation-id>
```

Run plugin impact evals from a skill directory when validating score-impact changes:

```bash
tessl eval run --quality-check skills/<skill-name>
```

`scripts/skills/publish.sh` publishes with `tessl plugin publish --bump patch` by default. Set `TESSL_SCENARIO_QUALITY_CHECK=true` only when Tessl's scenario-quality workflow is healthy enough to be a publish gate.

## Optimize

Apply Tessl's optimizer to one skill at a time:

```bash
./scripts/skills/optimize.sh review-gang
```

Direct form:

```bash
npx tessl@0.90.0 skill review --optimize --yes --max-iterations 1 skills/review-gang
```

## Suggested workflow

1. Edit the skill
2. Run `./scripts/skills/review.sh`
3. If the score or suggestions are weak, run Tessl optimize on a single skill or apply the feedback manually
4. Re-run review and inspect the diff before keeping any optimizer changes

## Notes

- `skills/review.sh` is the batch entrypoint for local skill review
- `skills/optimize.sh` applies mutations, so run it intentionally and inspect the resulting diff
- Prefer optimizing one skill at a time rather than churning the whole repo at once
- CI runs lint-only `./scripts/skills/review.sh` on pull requests and
  authenticated review on `main` through the `release` environment
- Skill packages use `.tessl-plugin/plugin.json`; do not reintroduce `tile.json`
