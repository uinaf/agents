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
- If the workflow is run manually, it publishes all tiles
- The publish workflow uses [`uinaf/tessl-publish-action`](https://github.com/uinaf/tessl-publish-action) to detect changed tiles, run review and lint, and publish them
- The action derives semantic version bumps from Conventional Commit messages: breaking changes -> `major`, `feat` -> `minor`, everything else -> `patch`
- Before publish, the action probes `tessl tile publish --dry-run` and keeps bumping patch versions in the job workspace until Tessl accepts a free version
- The action does not commit version bumps back to this repository; `tile.json` changes exist only in the CI workspace for the publish job
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
