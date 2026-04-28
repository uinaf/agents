# Workflows

Use when aligning GitHub Actions release workflow files.

## File Layout

- Default: a single `.github/workflows/ci.yml` with `verify` and `release` jobs.
- Split into `verify.yml` + `release.yml` only when verify must run on a different cadence (e.g., scheduled) or when release needs a runner the verify path does not.
- Avoid a third "tag-driven backstop" workflow unless the repo has a documented reason. Two active release paths is a foot-gun.
- Before changing layout, read existing workflows and any same-org repo that already publishes the same artifact type. Keep its action choice, token naming, and tap handling when the target matches.

## Triggers

- Verify: `pull_request` and `push` to `main`.
- Release: `push` to `main` only. Encode this as an `if:` on the release job rather than a separate `on:` block, so verify and release stay coupled.
- Manual `workflow_dispatch` is fine to add for verify but must not bypass `[skip ci]` for release.

## Concurrency

- Workflow-level cancellable group for verify:

  ```yaml
  concurrency:
    group: verify-${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: true
  ```

- Job-level non-cancellable group for release:

  ```yaml
  concurrency:
    group: release-${{ github.repository }}-main
    cancel-in-progress: false
  ```

  Cancelling a release mid-tag corrupts the tag/release pairing. Always queue.

## Permissions

- Workflow default: `permissions: read-all` (or just omit and rely on the default token's read scope).
- Release job:

  ```yaml
  permissions:
    contents: write
    issues: write
    pull-requests: write
  ```

- Add only when producing build provenance (e.g., GoReleaser + `actions/attest-build-provenance`):

  ```yaml
  id-token: write
  attestations: write
  ```

## Checkout

- Both jobs: `actions/checkout@v6` with `fetch-depth: 0`. Semantic-release walks history to compute the next version; a shallow clone breaks it.
- Release also needs `persist-credentials: true` (the default) so `@semantic-release/git` can push the bump commit using `GITHUB_TOKEN`.

## `[skip ci]` Gate

Both jobs must short-circuit when the head commit is the bot's bump commit:

```yaml
if: ${{ !contains(github.event.head_commit.message, '[skip ci]') }}
```

Apply on **both** verify and release. Skipping it on verify means the bump commit re-runs the verify suite for nothing; skipping it on release means the bump commit recursively triggers a new release.

## Bot Identity

Set inside the release step's `env:` (not at the job level — only semantic-release uses these):

```yaml
env:
  GIT_AUTHOR_NAME: release-bot
  GIT_AUTHOR_EMAIL: release-bot@users.noreply.github.com
  GIT_COMMITTER_NAME: release-bot
  GIT_COMMITTER_EMAIL: release-bot@users.noreply.github.com
```

Use a `noreply.github.com` address or a dedicated bot account. Do not attribute bump commits to a human contributor.

## Multi-Verify Composition

When the verify path has parallel jobs (e.g., `verify-unit`, `verify-consumer-surface`):

```yaml
release:
  needs: [verify-unit, verify-consumer-surface]
```

Release waits for **all** verify jobs. Adding a new verify job means adding it to `needs:` — do not rely on a single umbrella job.

## Bootstrap Snippets

Pick one matching the repo's toolchain and place it after `actions/checkout`. The verify command is whatever the repo already uses (`make verify`, `vp run verify`, `mise run verify`, etc.) — do not invent a new one.

```yaml
# Node / TypeScript
- uses: actions/setup-node@v5
  with: { node-version-file: ".nvmrc", cache: "npm" }
- run: npm ci
```

```yaml
# Node via VitePlus
- uses: voidzero-dev/setup-vp@v1
  with: { node-version-file: ".node-version", cache: true }
- run: vp install
```

```yaml
# Go CLI
- uses: jdx/mise-action@v4
- run: mise run verify
```

```yaml
# Swift (CocoaPods + SwiftPM)
- uses: maxim-lobanov/setup-xcode@v1
  with: { xcode-version: latest-stable }
- uses: ruby/setup-ruby@v1
  with: { bundler-cache: true }
```
