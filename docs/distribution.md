# Distribution

This repo publishes each skill as its own public Tessl plugin in the `uinaf` workspace.

## Plugin names

Do not maintain a hardcoded list here. The source of truth is the `name` field in each `skills/*/.tessl-plugin/plugin.json`.

To inspect the current published plugin names locally:

```bash
jq -r '.name' skills/*/.tessl-plugin/plugin.json
```

## How publishing works

- Each skill directory under `skills/*` has its own `.tessl-plugin/plugin.json`
- `.github/workflows/publish-skills.yml` runs the canonical repository verification gate first, including secretless skill lint, then runs authenticated Tessl review and publish through the `release` Environment for secret scoping
- Pushes to `main` publish only the plugins that changed
- Manual workflow runs publish all plugins only when the run ref is `main`; non-`main` manual runs can lint, but authenticated review and publish are skipped
- The publish job runs `scripts/skills/publish.sh`, which detects changed plugin directories, runs `tessl plugin lint`, and publishes with `tessl plugin publish`
- The script defaults to `--bump patch`; set `TESSL_PUBLISH_BUMP=minor` or `major` only for intentional release version changes
- After a successful publish, the workflow commits the resulting `.tessl-plugin/plugin.json` version bumps back to `main` as `github-actions[bot]` with the workflow `GITHUB_TOKEN` and a skip-CI commit message
- Both review and publish jobs skip `[skip ci]` commits, and the publish job uses non-cancellable concurrency so version probing and writeback cannot race another publish
- Publish-path actions are pinned to full commit SHAs with trailing comments for their human version tags

## Required GitHub Environment

Create a GitHub Environment named `release` for the publish job:

- Do not add required reviewers; releases should stay continuously publishable after the review job passes on `main`
- Limit Environment deployment branches to `main`
- Store the Tessl publish token as the Environment secret `TESSL_TOKEN`; do not store it as a plain repository Actions secret
- Use workflow `GITHUB_TOKEN` writeback and do not enable branch push restrictions; GitHub's built-in `github-actions[bot]` actor is not a normal allowed-user entry. Repos that require push restrictions should use a narrowly scoped GitHub App release actor instead of a personal publish bot.
- Protect `main` with force-push and branch deletion blocked where GitHub supports those controls
- If publish or release tags are added later, restrict tag creation and mutation to trusted release automation or release admins

Create a Tessl API key for the `uinaf` workspace, then add it to the `release` Environment as `TESSL_TOKEN`. Use a `uinaf` workspace key, not a token from another Tessl workspace.

You can create the key either from the Tessl web UI or with the CLI:

```bash
npx tessl api-key create --workspace uinaf --name github-actions-publish --role publisher
```

The workflows still reference the token as `${{ secrets.TESSL_TOKEN }}`; GitHub resolves that value from the `release` Environment only for jobs that declare `environment: release`. Pull-request jobs do not declare the environment and force lint mode instead.

## Local checks

```bash
npx tessl@0.90.0 plugin lint skills/review-gang
npx tessl@0.90.0 plugin publish --dry-run --workspace uinaf --bump patch skills/review-gang
```
