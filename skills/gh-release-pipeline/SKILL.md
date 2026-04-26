---
name: gh-release-pipeline
description: "Set up or align a GitHub Actions release pipeline for a versioned package, library, CLI, or marketplace action. Use when standardizing repos around the verify-then-release shape: push to main → guardrails → semantic-release tags + publishes → version-bump commit back to main with `[skip ci]`. Default to this shape unless the repo has a proven exception."
---

# Release Pipeline

Push-to-main, semantic-release driven, self-bumping. Only the publish plumbing varies by target (npm, SwiftPM/CocoaPods, Go, Rust, GitHub Action, Homebrew tap). Rust uses `release-plz` in place of semantic-release; the pipeline shape is identical.

## Pipeline Shape

```
push to main
  └─► verify job   (lint + typecheck + test + build, on PR and push)
        └─► release job   (push to main only, !contains [skip ci])
              ├─► semantic-release: analyze commits, tag, GitHub Release, notes
              ├─► publish to target (npm / pods / goreleaser / marketplace tag)
              └─► @semantic-release/git: commit version bump back to main with [skip ci]
```

Both jobs check out at `fetch-depth: 0`. The verify job is gated by a cancellable concurrency group; the release job uses a separate non-cancellable group so two releases never race.

## Workflow

1. Confirm prerequisites: `main` is the release branch, commits follow Conventional Commits, and a publish token for the target registry exists.
2. Pick the publish target — [references/targets.md](references/targets.md) covers npm, CocoaPods/SwiftPM, Go (GoReleaser), Rust (release-plz + cargo-dist), GitHub Actions marketplace, and Homebrew tap automation.
3. Author `.github/workflows/ci.yml` with verify and release jobs per [references/workflows.md](references/workflows.md).
4. Add release config (`.releaserc.json`, `release.config.js`, or a `"release"` block in `package.json`) per [references/semantic-release.md](references/semantic-release.md).
5. Wire publish secrets in repo settings (`NPM_TOKEN`, `COCOAPODS_TRUNK_TOKEN`, `TAP_GITHUB_TOKEN`, etc.) and scope `permissions:` per job — never broaden the default token.
6. Add the `[skip ci]` short-circuit to both jobs so the bump commit does not retrigger.
7. Set bot identity (`GIT_AUTHOR_NAME`/`GIT_COMMITTER_NAME` + emails) so the bump commit is attributed to the release bot, not the last human pusher.
8. Validate end-to-end: PR (verify only) → merge a `feat:` / `fix:` → watch verify→release run → confirm tag, GitHub Release, published artifact, and the `chore(release): … [skip ci]` commit on `main`.
9. Cross-check [references/troubleshooting.md](references/troubleshooting.md) when verify or release misbehaves before assuming the repo is at fault.

## Concrete Examples

Workflow skeleton (verify gated by PR + push, release gated by main + `[skip ci]`):

```yaml
name: ci
on:
  pull_request:
  push:
    branches: [main]

concurrency:
  group: verify-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  verify:
    if: ${{ !contains(github.event.head_commit.message, '[skip ci]') }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
        with: { fetch-depth: 0 }
      # bootstrap toolchain, then:
      - run: <repo verify command>   # e.g. vp run verify, make verify, mise run verify

  release:
    needs: [verify]
    if: ${{ github.event_name == 'push' && github.ref == 'refs/heads/main' && !contains(github.event.head_commit.message, '[skip ci]') }}
    runs-on: ubuntu-latest
    concurrency:
      group: release-${{ github.repository }}-main
      cancel-in-progress: false
    permissions:
      contents: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v5
        with: { fetch-depth: 0, persist-credentials: true }
      # bootstrap toolchain + install publish creds, then:
      - uses: cycjimmy/semantic-release-action@v4
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
          GIT_AUTHOR_NAME: release-bot
          GIT_AUTHOR_EMAIL: release-bot@users.noreply.github.com
          GIT_COMMITTER_NAME: release-bot
          GIT_COMMITTER_EMAIL: release-bot@users.noreply.github.com
```

Canonical `.releaserc.json`:

```json
{
  "branches": ["main"],
  "plugins": [
    ["@semantic-release/commit-analyzer", { "preset": "conventionalcommits" }],
    ["@semantic-release/release-notes-generator", { "preset": "conventionalcommits" }],
    "@semantic-release/changelog",
    "@semantic-release/npm",
    ["@semantic-release/git", {
      "assets": ["package.json", "package-lock.json", "CHANGELOG.md"],
      "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
    }],
    "@semantic-release/github"
  ]
}
```

## Guardrails

- One release pipeline per repo. If the repo already has a tag-driven backstop workflow, document why; do not silently introduce a second active path.
- Verify is the only gate to publish. Do not move guardrails into the release job, do not bypass via `workflow_dispatch`, do not weaken `needs: [verify]`.
- The bump commit is sacred: bot-authored, `[skip ci]` in the message, respected by both jobs' `if:` guards. Breaking any of those re-triggers the pipeline infinitely.
