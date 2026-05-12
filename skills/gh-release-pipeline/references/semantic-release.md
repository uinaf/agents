# Semantic Release

Use this reference for the semantic-release configuration and the commit conventions that drive it.

## Conventional Commits

Semantic-release derives the next version from commit messages. The repo must commit to Conventional Commits before this pipeline is reliable.

- `feat:` → minor bump
- `fix:` → patch bump
- `feat!:` / `fix!:` / `BREAKING CHANGE:` footer → major bump
- `chore:`, `docs:`, `refactor:`, `test:`, `build:`, `ci:` → no release (unless flagged via release rules)

Enforce locally with a commit-msg hook (`commitlint` for Node, `convco` for Go, etc.) so PRs cannot land non-conforming subjects. The release pipeline assumes the convention; it does not enforce it.

## Plugin Order

Order matters — semantic-release runs plugins in declaration order. Canonical order for an npm package:

1. `@semantic-release/commit-analyzer` — decides next version from commit history
2. `@semantic-release/release-notes-generator` — builds the release notes body
3. `@semantic-release/changelog` — writes/updates `CHANGELOG.md` (optional)
4. Publish plugin(s) — `@semantic-release/npm`, `@semantic-release/exec`, etc.
5. `@semantic-release/git` — commits version-bumped files back with `[skip ci]`
6. `@semantic-release/github` — creates the GitHub Release and uploads assets

Place `@semantic-release/git` **before** `@semantic-release/github` so the bump commit exists when the GitHub Release is created (the Release points at that commit's tag).

## Preset

Always pass the same preset to both analyzer and notes generator:

```json
["@semantic-release/commit-analyzer", { "preset": "conventionalcommits" }],
["@semantic-release/release-notes-generator", { "preset": "conventionalcommits" }]
```

Mismatched presets produce inconsistent version decisions and notes.

## `@semantic-release/git` Configuration

```json
["@semantic-release/git", {
  "assets": ["package.json", "package-lock.json", "CHANGELOG.md"],
  "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
}]
```

- `assets` is the explicit list of files the bump commit includes. Add `pnpm-lock.yaml`, `Package.swift`, `<podname>.podspec`, or other manifests as needed.
- Keep the `[skip ci]` token in the message; it gates re-triggering.
- For a tag-only release (no source bump — see GoReleaser flows), omit this plugin entirely.

## Branch Configuration

```json
{ "branches": ["main"] }
```

Add prerelease channels only when the repo actually publishes them:

```json
{
  "branches": [
    "main",
    { "name": "next", "prerelease": true },
    { "name": "beta", "prerelease": true }
  ]
}
```

A prerelease branch creates a separate npm dist-tag and GitHub Release. Enable it when the repo has an actual prerelease lane.

## Config File Location

- Node packages: `.releaserc.json` at repo root, or a `"release"` block in `package.json`. Pick one.
- Monorepos: per-package `.releaserc.json` next to the package, paired with `working_directory:` on the action.
- Non-Node repos (Swift, Go): `.releaserc.json` at root works fine — semantic-release is a Node tool but only needs Node available on the runner.

## Dry-Run Verification

Before the first real release, dry-run on a topic branch:

```bash
GITHUB_TOKEN=… npx semantic-release --dry-run --no-ci --branches=$(git branch --show-current)
```

The dry-run prints the computed version and notes without tagging or publishing. Confirm both look right before merging the first `feat:` commit to main.

## Action Wrapper

Use `cycjimmy/semantic-release-action@<full-sha> # v4.x.y` (or a full-SHA-pinned v6 line if the repo is already on it). Inputs worth knowing:

- `working_directory` — for monorepo packages.
- `extra_plugins` — install CI/CD-only release plugins without polluting the repo's runtime or dev dependency graph. Pin every entry to an exact version such as `@semantic-release/npm@13.1.5`; use exact package specs in secret-bearing release jobs.
- `semantic_version` — pin the semantic-release major to keep release behavior reproducible.

Keep semantic-release dependencies in `package.json` only when the repo intentionally owns local release execution, such as a documented `release` script developers run or a lockfile-owned release wrapper. For normal GitHub Actions release jobs, keep release-only plugins in the action's `extra_plugins` input and pin them there.
