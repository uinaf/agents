# Distribution

This repo publishes each skill as its own public Tessl tile in the `uinaf` workspace.

## Tile names

Do not maintain a hardcoded list here. The source of truth is the `name` field in each `skills/*/tile.json`.

To inspect the current published tile names locally:

```bash
jq -r '.name' skills/*/tile.json
```

## How publishing works

- Each skill directory under `skills/*` has its own `tile.json`
- `.github/workflows/publish-skills.yml` lints and publishes only the tiles that changed on pushes to `main`
- If the workflow file itself changes, or the workflow is run manually, it publishes all tiles so workflow fixes can be validated immediately
- The publish workflow also runs `tessl skill review --threshold 90` for each changed skill and blocks publishing if the score is below that bar
- Publishing uses `--bump patch`, so an existing registry version is automatically patch-bumped instead of failing the workflow
- The workflow expects a repository secret named `TESSL_TOKEN`

## Required GitHub secret

Create a Tessl API key for the `uinaf` workspace, then add it to this repository as the `TESSL_TOKEN` Actions secret.

You can create the key either from the Tessl web UI or with the CLI:

```bash
tessl api-key create --workspace uinaf --name github-actions-publish --role publisher
```

## Local checks

```bash
tessl tile lint skills/review
tessl tile publish --dry-run skills/review
```
