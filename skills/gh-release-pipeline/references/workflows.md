# Workflows

Use when aligning GitHub Actions release workflow files.

## File Layout

- Default: a single `.github/workflows/ci.yml` with `verify` and `release` jobs.
- Split into `verify.yml` + `release.yml` only when verify must run on a different cadence (e.g., scheduled) or when release needs a runner the verify path does not.
- Keep a single release workflow by default. Add a third "tag-driven backstop" workflow only with a documented reason, because two active release paths make provenance and retry behavior harder to reason about.
- Before changing layout, read existing workflows and any same-org repo that already publishes the same artifact type. Keep its action choice, token naming, and tap handling when the target matches.

## Triggers

- Verify: `pull_request` and `push` to `main`.
- Release: `push` to `main` only. Encode this as an `if:` on the release job rather than a separate `on:` block, so verify and release stay coupled.
- Do not use `pull_request_target` for any workflow that checks out, installs, builds, tests, packages, signs, publishes, or otherwise executes project code. Keep fork and outsider code on `pull_request` with read-only credentials and no release secrets.
- Manual `workflow_dispatch` is fine to add for verify; release paths still honor the `[skip ci]` gate.
- Secret-bearing manual release/backfill workflows use trusted checkout refs: `main`, a published `v*` tag, or a separately validated protected ref.
- GitHub Environment branch/tag policies gate the workflow run ref; they do not prove that a later `actions/checkout` `with.ref` or `git checkout` input is trusted. Treat run ref and checkout ref as separate trust boundaries.

## Manual Inputs

- Pass `workflow_dispatch` inputs through `env:` into a secretless validation step. Validate shape/length/allowed values, emit the sanitized value as a step output, then use that output downstream.
- Use `actions/checkout` with `with: { ref: ${{ steps.validate.outputs.ref }} }` after validation.
- Keep untrusted multiline input out of `$GITHUB_ENV` unless it is sanitized or written with a heredoc-safe delimiter.
- Do metadata prep and input validation before loading registry, signing, store, or release secrets.

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

- Workflow default: `permissions: {}`. Jobs opt into only the scopes they need.
- Release job:

  ```yaml
  permissions:
    contents: write
  ```

- Add `id-token: write` only when the job uses npm trusted publishing, provider OIDC, or keyless provenance. Add `issues: write` and `pull-requests: write` only when semantic-release is configured to comment on issues or pull requests. Add `attestations: write` only when producing GitHub build provenance:

  ```yaml
  id-token: write
  attestations: write
  ```

## Runners

- Use GitHub-hosted floating runner labels for routine CI and release jobs: `ubuntu-latest`, `windows-latest`, and `macos-latest`.
- Pin a runner image only when the OS image is part of the tested toolchain contract, and document that reason next to the workflow or in the repo release docs.

## Settings and Secrets

- Check live settings before severity or remediation calls: `main` rules, allowed push actors, release tag rules, Actions permission policy, Environment reviewers/branch policy, and publish secret location.
- Continuous releases should use Environment-scoped secrets without approval gates. Use separate reviewer-gated environments only when a human must approve signing, production promotion, or store submission.
- Package/library/CLI/marketplace release jobs that use an Environment only to read publish secrets set `deployment: false`. This keeps Environment secrets, variables, and branch policy without creating GitHub Deployment records.
- Keep deployment records enabled for running-service/app deploys and for Environments that use custom deployment protection rules.
- Do not add CODEOWNERS as a blanket default for small repos. Use it only when the repo's maintainers explicitly want owner-gated workflow or release-file review.

## Release Tooling

- Pin high-trust release, publish, upload, and signing actions to full commit SHAs with a trailing same-line version comment. Dependabot can update SHA-pinned GitHub Actions when the ref line carries the version comment; stale SHAs that no longer exist upstream should be fixed before relying on the updater.
- When a release action installs plugins at runtime, pin each requested plugin to an exact version in jobs with registry, signing, or repository-write secrets.
- Keep CI/CD-only release tooling out of the repo dependency graph by default. Use action inputs such as `extra_plugins` for workflow-owned release plugins, and reserve `devDependencies` for tooling the repo intentionally exposes through local scripts or lockfile-owned release wrappers.

## Checkout

- Both jobs: `actions/checkout@<full-sha> # v6.x.y` with `fetch-depth: 0`. Semantic-release walks history to compute the next version; a shallow clone breaks it.
- Keep `persist-credentials: false` through checkout, install, build, and pack steps whenever possible, especially before package-manager lifecycle scripts run. If `@semantic-release/git` must push a bump commit, add write credentials only at the narrow release boundary: use a release bot or GitHub App token that branch rules explicitly allow, configure the git remote or credential helper immediately before semantic-release, and avoid exposing that token to dependency install steps.

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

Use a `noreply.github.com` address or a dedicated bot account so bump commits are attributed to automation.

- The token actor and commit identity must agree. `GIT_AUTHOR_*`/`GIT_COMMITTER_*` with `GITHUB_TOKEN` still writes as `github-actions[bot]`; use a dedicated release bot or GitHub App token when branch rules need a separately allowlisted actor.
- If a third-party action commits internally, verify it accepts author/committer inputs or honors `GIT_AUTHOR_*`/`GIT_COMMITTER_*`. Checkout tokens do not override hardcoded metadata.

## Caches

- Verify jobs may use dependency caches. Secret-bearing release, publish, signing, and promotion jobs do fresh dependency installs by default.
- Do not share package-manager caches between `pull_request` and privileged `push: main`, `workflow_dispatch`, or tag-driven jobs. The dangerous shape is outsider-controlled code populating a cache that a later publish job consumes.
- Release caches are only for unavoidable download/tool caches, not package-manager stores, generated dependency trees, or build outputs that become signed/published artifacts.
- Regenerate or verify generated trees such as `Pods/`, `vendor/`, `dist/`, build directories, or packaged runtime bundles inside secret-bearing release jobs.
- If a cache is unavoidable, namespace it by workflow, event/trust level, platform, and lockfile. Release jobs must consume only caches from the same trusted event class and must regenerate or verify generated trees before signing or publishing.

## npm Supply-Chain Incident Checks

- For active npm compromise response, scan manifests and lockfiles before installing. Look for affected versions from the advisory, unexpected git dependencies, malicious `optionalDependencies`, and package-root payloads such as `router_init.js`.
- If an affected package was installed on a developer machine or CI runner, treat that host as compromised and rotate registry, GitHub, cloud, SSH, Vault, and package-manager credentials reachable from the host before publishing again.
- npm trusted publishing is the default for public npm packages published from GitHub-hosted Actions: configure the package on npm for the repo, workflow filename, and optional Environment; grant `id-token: write`; remove `NPM_TOKEN`; and rely on npm's automatic provenance for public packages from public repos.
- SLSA or npm provenance proves the package came from a workflow identity, not that the workflow runner was clean. Keep provenance, but do not let it replace trusted refs, fresh release installs, and cache separation.

## Multi-Verify Composition

When the verify path has parallel jobs (e.g., `verify-unit`, `verify-consumer-surface`):

```yaml
release:
  needs: [verify-unit, verify-consumer-surface]
```

Release waits for **all** verify jobs. Adding a new verify job means adding it to `needs:` explicitly.

## Bootstrap Snippets

Pick one matching the repo's toolchain and place it after `actions/checkout`. Use the repo's existing verify command (`make verify`, `vp run verify`, `mise run verify`, etc.).

```yaml
# Node / TypeScript
- uses: actions/setup-node@<full-sha> # v5.x.y
  with: { node-version-file: ".nvmrc" }
- run: npm ci
```

```yaml
# Node via Vite+
- uses: voidzero-dev/setup-vp@<full-sha> # v1.x.y
  with: { node-version-file: ".node-version", cache: false }
- run: vp install
```

```yaml
# Go CLI
- uses: jdx/mise-action@<full-sha> # v4.x.y
- run: mise run verify
```

```yaml
# Swift (CocoaPods + SwiftPM)
- uses: maxim-lobanov/setup-xcode@<full-sha> # v1.x.y
  with: { xcode-version: latest-stable }
- uses: ruby/setup-ruby@<full-sha> # v1.x.y
  with: { bundler-cache: false }
```
