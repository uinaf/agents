# Tessl Audit Commands

Use the repo wrappers when present; they own the audited Tessl pin and batch behavior.

```bash
./scripts/skills/review.sh
```

For a formal single-skill audit or a repo without wrappers, use the same pin as the repo's review scripts:

```bash
skill_dir="skills/<name>"
tessl_version="${TESSL_CLI_VERSION:-0.90.0}"
npx "tessl@$tessl_version" plugin lint "$skill_dir"
npx "tessl@$tessl_version" review run --workspace uinaf --threshold 0 --json "$skill_dir"
```

Capture the score, summary, and concrete suggestions before proposing edits. Prefer per-skill `--json` for a narrow or structured loop. If the audited Tessl version is unavailable, install or initialize it using the [CLI documentation](https://docs.tessl.io/reference/cli-commands).

Use optimization only when explicitly requested:

```bash
./scripts/skills/optimize.sh <name>
```

If the repo has no optimizer wrapper, reuse the audited `tessl_version` from the formal audit block:

```bash
npx "tessl@$tessl_version" skill review --optimize --yes --max-iterations 1 skills/<name>
```
