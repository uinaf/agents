# Skill Evaluation

This repo uses Tessl as the evaluation loop for skill quality, clarity, self-activation, and impact scenarios.

## Review

Run a read-only plugin lint plus quality review across every local skill:

```bash
./scripts/skills/review.sh
```

By default this enforces `--threshold 90` in the `uinaf` workspace. Override with `TESSL_THRESHOLD=94`, `TESSL_WORKSPACE=<name>`, or pass `--threshold` / `--workspace` explicitly.
The wrapper pins the Tessl CLI through `TESSL_CLI_VERSION`, defaulting to the
version in the script. Bump it intentionally rather than relying on moving npm
latest.

In CI, Tessl's scored `review run` requires authentication. When `CI` is set
and `TESSL_TOKEN` is absent, the wrapper falls back to `tessl plugin lint` so
pull requests still get deterministic structure validation without requiring a
secret or posting bot-authored review comments. Set `TESSL_REVIEW_MODE=lint` to
force that mode locally.

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
- CI runs `./scripts/skills/review.sh` on pull requests and pushes to `main`
- Skill packages use `.tessl-plugin/plugin.json`; do not reintroduce `tile.json`
