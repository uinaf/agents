---
name: gh-release-pipeline
description: "Set up or align a GitHub Actions release pipeline for a versioned package, library, CLI, or marketplace action. Use when standardizing repos around the verify-then-release shape: push to main → guardrails → semantic-release tags + publishes → version-bump commit back to main with `[skip ci]`. Pairs with `gh-deploy-pipeline` for running apps; use for publishing versioned artifacts to a registry, not deploying a running service."
---

# Release Pipeline

Push-to-main, semantic-release driven, self-bumping. Only the publish plumbing varies by target (npm, SwiftPM/CocoaPods, Go, Rust, GitHub Action, Homebrew tap). Rust uses `release-plz` in place of semantic-release; the pipeline shape is identical.

Do not use this for Pages, SST, Cloudflare, or other running-app deploys unless the same change also publishes a versioned package. Use `gh-deploy-pipeline` for deploy surfaces.

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
2. Confirm prerequisites: `main` is the release branch, commits follow Conventional Commits, the default branch has a merge policy that fits release automation, and the target registry has a trusted publishing/OIDC path or another narrowly scoped publish credential.
3. Pick the publish target — [references/targets.md](references/targets.md) covers npm, CocoaPods/SwiftPM, Go (GoReleaser), Rust (release-plz + cargo-dist), GitHub Actions marketplace, and Homebrew tap automation. Prefer an existing working repo pattern over a generic marketplace action.
4. Before authoring workflow YAML, identify the repo's tooling version sources. Node should come from `.node-version`/`.nvmrc`/`.tool-versions`; package managers from `package.json#packageManager`; Vite+ from `package.json` or the workspace catalog. Preserve or create one checked-in owner instead of repeating Node, pnpm, or Vite+ versions inside jobs.
5. Author `.github/workflows/ci.yml` with verify and release jobs per [references/workflows.md](references/workflows.md).
6. Add release config (`.releaserc.json`, `release.config.js`, or a `"release"` block in `package.json`) per [references/semantic-release.md](references/semantic-release.md).
7. Prefer OIDC trusted publishing for npm. Use long-lived publish tokens only when the registry or target does not support trusted publishing, and keep those secrets in a protected `release` Environment (`COCOAPODS_TRUNK_TOKEN`, `TAP_GITHUB_TOKEN`, etc.). Package/library/CLI/marketplace publishes use the Environment as a secret boundary with `deployment: false`.
8. Add the `[skip ci]` short-circuit to both jobs so the bump commit does not retrigger.
9. For secret-bearing release/backfill jobs, use trusted checkout refs and validated manual inputs per [references/workflows.md](references/workflows.md).
10. Set bot identity (`GIT_AUTHOR_NAME`/`GIT_COMMITTER_NAME` + emails) so the bump commit is attributed to the token actor or release bot, not the last human pusher.
11. Validate end-to-end: PR (verify only) → merge a `feat:` / `fix:` → watch verify→release run → confirm tag, GitHub Release, published artifact, and the `chore(release): … [skip ci]` commit on `main`.
12. Cross-check [references/troubleshooting.md](references/troubleshooting.md) when verify or release misbehaves before assuming the repo is at fault.

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

- Keep one release pipeline per repo. If the repo already has a tag-driven backstop workflow, document why that second path exists.
- Repo precedent beats generic advice. If a sibling repo already ships the same artifact class successfully, preserve that action and shape unless you can point to a concrete mismatch.
- Default branch merge policy is part of the release surface. If direct pushes to `main` must remain allowed, prefer branch protection with only `required_conversation_resolution` enabled. Use organization or repository rulesets for conversation resolution only when making default-branch changes go through pull requests is intended. Preserve existing approvals, status checks, signed-commit, and actor restrictions when changing branch policy.
- Keep verify as the only gate to publish: release depends on verify, manual paths preserve the same gate, and guardrails stay before publish.
- Keep tooling versions single-sourced. Use `node-version-file` for Node, let package-manager bootstrap read `package.json#packageManager`, and derive tool-specific action inputs from package metadata with structured tools such as `jq` instead of copying literals into workflows. Action SHA pins and same-line action version comments are allowed.
- The bump commit is an invariant: bot-authored, `[skip ci]` in the message, and respected by both jobs' `if:` guards.
- Do not use GitHub Actions artifacts as a release-to-deploy registry when a real release asset, package registry, image digest, or provider-native package exists. Actions artifacts are temporary CI storage and can fail deploys on quota or retention. If a deploy follows a versioned release, consume the published release asset or package directly and verify it before promotion.
- When push-back is restricted, check the repo's branch rules and allowed actors before choosing credentials. A ruleset `pull_request` rule with `required_review_thread_resolution: true` requires default-branch changes to go through PRs; account for that before relying on a release bump commit pushed by Actions. Use the default Actions actor when it can be allowed cleanly; otherwise use a dedicated release bot or GitHub App token that branch rules explicitly allow, plus matching author/committer metadata. Metadata alone does not authorize the write, and broad admin-style exceptions are not the default answer.
- Pin high-trust release, publish, upload, and signing actions to full commit SHAs with a trailing same-line version comment when the repo's maintenance model can support Dependabot or scheduled pin refreshes. Prefer exact comments such as `# v1.10.0`; verify the SHA resolves upstream before committing it.
