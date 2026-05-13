# Skill Evaluation

This repo uses Tessl as the evaluation loop for skill quality, clarity, and self-activation.

## Review

Run a read-only review across every local skill:

```bash
./scripts/skills/review.sh
```

By default this enforces `--threshold 90`. Override with `TESSL_THRESHOLD=94` or pass `--threshold` explicitly.
The wrapper pins the Tessl CLI through `TESSL_CLI_VERSION`, defaulting to the
version in the script. Bump it intentionally rather than relying on moving npm
latest.

Useful direct invocations:

```bash
npx tessl@0.79.1 skill review skills/review
npx tessl@0.79.1 skill review --json --threshold 90 skills/verify
```

Use per-skill `--json` output directly with Tessl rather than `skills/review.sh`, because the batch wrapper emits one review per skill.

## Optimize

Apply Tessl's optimizer to one skill at a time:

```bash
./scripts/skills/optimize.sh review
```

Direct form:

```bash
npx tessl@0.79.1 skill review --optimize --yes --max-iterations 1 skills/review
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
