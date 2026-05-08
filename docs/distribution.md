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
- `.github/workflows/publish-skills.yml` runs a secretless review job first, then continuously publishes through the `release` Environment for secret scoping
- Pushes to `main` publish only the tiles that changed
- Manual workflow runs publish all tiles only when the run ref is `main`; non-`main` manual runs can review, but the publish job is skipped
- The publish job uses [`uinaf/tessl-publish-action`](https://github.com/uinaf/tessl-publish-action) to detect changed tiles, run review and lint, and publish them
- The action derives semantic version bumps from Conventional Commit messages: breaking changes -> `major`, `feat` -> `minor`, everything else -> `patch`
- Before publish, the action probes `tessl tile publish --dry-run` and keeps bumping patch versions in the job workspace until Tessl accepts a free version
- After a successful publish, the workflow commits the resulting `tile.json` version bumps back to `main` as `github-actions[bot]` with a skip-CI commit message
- Publish-path actions are pinned to full commit SHAs with trailing comments for their human version tags

## Required GitHub Environment

Create a GitHub Environment named `release` for the publish job:

- Do not add required reviewers; releases should stay continuously publishable after the review job passes on `main`
- Limit Environment deployment branches to `main`
- Store the Tessl publish token as the Environment secret `TESSL_TOKEN`; do not store it as a plain repository Actions secret
- Protect `main` so only trusted uinaf admins can update it, with force-push and branch deletion blocked where GitHub supports those controls
- If publish or release tags are added later, restrict tag creation and mutation to trusted release automation or release admins

Create a Tessl API key for the `uinaf` workspace, then add it to the `release` Environment as `TESSL_TOKEN`. Use a `uinaf` workspace key, not a token from another Tessl workspace.

You can create the key either from the Tessl web UI or with the CLI:

```bash
npx tessl api-key create --workspace uinaf --name github-actions-publish --role publisher
```

The workflow still references the token as `${{ secrets.TESSL_TOKEN }}`; GitHub resolves that value from the `release` Environment when the publish job starts.

## Local checks

```bash
npx tessl tile lint skills/review
npx tessl tile publish --dry-run skills/review
```
