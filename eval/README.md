# Skill Evaluation

This repo uses Tessl as the evaluation loop for skill quality, clarity, and self-activation.

## Review

Run a read-only review across every local skill:

```bash
cd ..
./eval/review-skills.sh
```

By default this enforces `--threshold 90`. Override with `TESSL_THRESHOLD=94` or pass `--threshold` explicitly.

Useful direct invocations:

```bash
npx tessl skill review skills/review
npx tessl skill review --json --threshold 90 skills/verify
```

Use per-skill `--json` output directly with Tessl rather than `review-skills.sh`, because the batch wrapper emits one review per skill.

## Optimize

Apply Tessl's optimizer to one skill at a time:

```bash
cd ..
./eval/optimize-skills.sh review
```

Direct form:

```bash
npx tessl skill review --optimize --yes --max-iterations 1 skills/review
```

## Suggested workflow

1. Edit the skill
2. Run `./eval/review-skills.sh`
3. If the score or suggestions are weak, run Tessl optimize on a single skill or apply the feedback manually
4. Re-run review and inspect the diff before keeping any optimizer changes

## Notes

- `review-skills.sh` is the batch entrypoint for local skill review
- `optimize-skills.sh` applies mutations, so run it intentionally and inspect the resulting diff
- Prefer optimizing one skill at a time rather than churning the whole repo at once
- CI runs `./eval/review-skills.sh` on pull requests and pushes to `main`
