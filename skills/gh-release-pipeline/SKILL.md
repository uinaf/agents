---
name: gh-release-pipeline
description: "Set up or align a GitHub Actions release pipeline for a versioned package, library, CLI, or marketplace action. Use when standardizing repos around the verify-then-release shape: push to main → guardrails → semantic-release tags + publishes → version-bump commit back to main with `[skip ci]`. Pairs with `gh-deploy-pipeline` for running apps; use for publishing versioned artifacts to a registry, not deploying a running service."
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

1. Inspect the current repo first: existing `.github/workflows/*`, release config, tap formula, package metadata, and any failed PR/check logs. If the org has a known-good sibling repo for the same target, read that workflow before choosing an action.
2. Confirm prerequisites: `main` is the release branch, commits follow Conventional Commits, and a publish token for the target registry exists.
3. Pick the publish target — [references/targets.md](references/targets.md) covers npm, CocoaPods/SwiftPM, Go (GoReleaser), Rust (release-plz + cargo-dist), GitHub Actions marketplace, and Homebrew tap automation. Prefer an existing working repo pattern over a generic marketplace action.
4. Author `.github/workflows/ci.yml` with verify and release jobs per [references/workflows.md](references/workflows.md).
5. Add release config (`.releaserc.json`, `release.config.js`, or a `"release"` block in `package.json`) per [references/semantic-release.md](references/semantic-release.md).
6. Wire publish secrets in repo settings (`NPM_TOKEN`, `COCOAPODS_TRUNK_TOKEN`, `TAP_GITHUB_TOKEN`, etc.) and scope `permissions:` per job — never broaden the default token.
7. Add the `[skip ci]` short-circuit to both jobs so the bump commit does not retrigger.
8. For secret-bearing release/backfill jobs, use trusted checkout refs and validated manual inputs per [references/workflows.md](references/workflows.md).
9. Set bot identity (`GIT_AUTHOR_NAME`/`GIT_COMMITTER_NAME` + emails) so the bump commit is attributed to the token actor or release bot, not the last human pusher.
10. Validate end-to-end: PR (verify only) → merge a `feat:` / `fix:` → watch verify→release run → confirm tag, GitHub Release, published artifact, and the `chore(release): … [skip ci]` commit on `main`.
11. Cross-check [references/troubleshooting.md](references/troubleshooting.md) when verify or release misbehaves before assuming the repo is at fault.

## Examples

Load workflow snippets from [references/workflows.md](references/workflows.md), target-specific release shape from [references/targets.md](references/targets.md), and semantic-release config from [references/semantic-release.md](references/semantic-release.md) only after the package type is known.

Minimal release anchors:

```yaml
release:
  needs: [verify]
  if: ${{ github.event_name == 'push' && github.ref == 'refs/heads/main' && !contains(github.event.head_commit.message, '[skip ci]') }}
  concurrency: { group: release-${{ github.repository }}-main, cancel-in-progress: false }
```

```json
{
  "branches": ["main"],
  "plugins": [
    ["@semantic-release/commit-analyzer", { "preset": "conventionalcommits" }],
    ["@semantic-release/git", { "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}" }]
  ]
}
```

## Guardrails

- One release pipeline per repo. If the repo already has a tag-driven backstop workflow, document why; do not silently introduce a second active path.
- Repo precedent beats generic advice. If a sibling repo already ships the same artifact class successfully, preserve that action and shape unless you can point to a concrete mismatch.
- Verify is the only gate to publish. Do not move guardrails into the release job, do not bypass via `workflow_dispatch`, do not weaken `needs: [verify]`.
- The bump commit is an invariant: bot-authored, `[skip ci]` in the message, and respected by both jobs' `if:` guards.
- When push-back is restricted, use the allowed bot/app token and matching author/committer metadata. Metadata alone does not authorize the write.
- Pin high-trust release, publish, upload, and signing actions to full commit SHAs with a trailing human version comment when the repo's maintenance model can support Dependabot or scheduled pin refreshes.
