# Publish Targets

Use this reference when wiring the publish step. The verify→release shape stays identical across targets; only the publish plumbing and secrets change.

Before picking an action, inspect the repo's current release files and at least one known-good sibling repo when the organization has one. Release and tap actions have subtle defaults around forks, direct pushes, generated formulae, and token scopes; copying the nearest working pattern is usually safer than inventing a new one.

## npm (Library or CLI)

Plugins:

```json
"@semantic-release/npm",
"@semantic-release/git",
"@semantic-release/github"
```

Workflow step:

```yaml
- uses: actions/setup-node@v5
  with: { node-version-file: ".nvmrc", registry-url: "https://registry.npmjs.org" }
- run: npm ci
- uses: cycjimmy/semantic-release-action@v4
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

- `registry-url` is required for `setup-node` to write the `_authToken` line. Without it, `@semantic-release/npm` cannot publish.
- For scoped public packages set `"publishConfig": { "access": "public" }` in `package.json`.
- For a CLI, set `"bin"` in `package.json` and verify the published tarball includes the entry. `npm pack --dry-run` locally before the first release.
- If the release builds standalone binaries, verify every downloaded runtime or toolchain archive by digest before extracting or embedding it. Pair functional smoke tests with provenance checks.

## CocoaPods + SwiftPM

Semantic-release tags via `@semantic-release/git`; CocoaPods publish runs via `@semantic-release/exec` shelling out to a repo script.

```json
["@semantic-release/exec", {
  "prepareCmd": "./scripts/prepare-release.sh ${nextRelease.version}",
  "publishCmd": "./scripts/publish-cocoapods.sh"
}],
["@semantic-release/git", {
  "assets": ["Package.swift", "<podname>.podspec"],
  "message": "chore(release): ${nextRelease.version} [skip ci]"
}],
"@semantic-release/github"
```

- `prepare-release.sh` rewrites the version string in `Package.swift` and the podspec.
- `publish-cocoapods.sh` runs `pod trunk push <podname>.podspec --allow-warnings`.
- Secrets: `COCOAPODS_TRUNK_TOKEN` exported as env on the publish step. Trunk token is generated with `pod trunk register` once and then stored as a repo secret.
- SwiftPM consumers pull from the git tag — no separate publish step needed.
- Cache download artifacts across trust boundaries. Regenerate or verify generated dependency trees such as full `Pods/` inside signed or publishing jobs before signing or publishing.

## Go (GoReleaser)

Semantic-release does not publish Go binaries. Use it as the version-decider, then hand off to GoReleaser.

Plugins (tag-only — no `@semantic-release/git`, no source bump):

```json
"@semantic-release/commit-analyzer",
"@semantic-release/release-notes-generator",
"@semantic-release/github"
```

Two-step release job:

```yaml
- uses: cycjimmy/semantic-release-action@v4
  id: release
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

- if: steps.release.outputs.new_release_published == 'true'
  uses: goreleaser/goreleaser-action@v7
  with:
    version: latest
    args: release --clean
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    TAP_GITHUB_TOKEN: ${{ secrets.TAP_GITHUB_TOKEN }}

- if: steps.release.outputs.new_release_published == 'true'
  uses: actions/attest-build-provenance@v4
  with:
    subject-path: 'dist/*.tar.gz,dist/*.zip'
```

- `TAP_GITHUB_TOKEN` is needed only if GoReleaser publishes to a Homebrew tap in another repo (see Homebrew Tap below).
- Add `id-token: write` and `attestations: write` to the job's `permissions:` for the attestation step.
- `--clean` wipes `dist/` before building so a previous run cannot poison the new release.
- Build and upload release artifacts from the release tag or verified release commit. If a workflow intentionally promotes an existing artifact, require recorded provenance: source commit, tag, build number/version, artifact digest, and producing workflow run.

## Rust

Two flavors depending on whether you publish to crates.io. Both pair with **[`cargo-dist`](https://opensource.axo.dev/cargo-dist/)** for cross-platform binaries + Homebrew formula generation (cargo-dist is GoReleaser's Rust equivalent).

### Flavor A — CLI without crates.io (Homebrew/binaries only)

Mirrors the Go/GoReleaser shape. Keep semantic-release as the version-decider (tag-only, no source bump), then cargo-dist publishes binaries and writes the Homebrew formula.

Plugins (no `@semantic-release/git`):

```json
"@semantic-release/commit-analyzer",
"@semantic-release/release-notes-generator",
"@semantic-release/github"
```

Two-step release job:

```yaml
- uses: dtolnay/rust-toolchain@stable
- uses: cycjimmy/semantic-release-action@v4
  id: release
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

- if: steps.release.outputs.new_release_published == 'true'
  uses: axodotdev/cargo-dist-action@v1
  with:
    tag: v${{ steps.release.outputs.new_release_version }}
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    HOMEBREW_TAP_TOKEN: ${{ secrets.TAP_GITHUB_TOKEN }}
```

- No `CARGO_REGISTRY_TOKEN` needed — nothing publishes to crates.io.
- `cargo dist init` writes `[workspace.metadata.dist]` in `Cargo.toml`. Set `tap = "<org>/homebrew-tap"` and `installers = ["shell", "powershell", "homebrew"]`.
- Default targets: `x86_64-unknown-linux-gnu`, `aarch64-apple-darwin`, `x86_64-apple-darwin`, `x86_64-pc-windows-msvc`. Add `x86_64-unknown-linux-musl` for static Linux; `aarch64-unknown-linux-gnu` for ARM64 Linux.
- `cargo-binstall` works out of the box — cargo-dist follows binstall's naming conventions.
- Simpler alternative if you don't need installers or Homebrew: `taiki-e/upload-rust-binary-action@v1` in a matrix job.

### Flavor B — Library or dual-distribution (crates.io)

When you do publish to crates.io, swap semantic-release for **[`release-plz`](https://release-plz.dev/)**. It understands `Cargo.toml`, handles workspaces, runs `cargo publish` in dependency order, and generates `CHANGELOG.md`.

```yaml
- uses: dtolnay/rust-toolchain@stable
- uses: MarcoIeni/release-plz-action@v0.5
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

- Default mode opens a "Release PR" that bumps `Cargo.toml` + `CHANGELOG.md`. Merging the PR triggers tag + crates.io publish. Replaces the `[skip ci]` bump-back loop with an explicit-merge gate.
- For the auto-push variant (matching the semantic-release `[skip ci]` shape), set `git_release_enable = true` in `release-plz.toml` and run with a bot PAT that bypasses branch protection.
- Workspace repos: release-plz handles per-crate independent versioning natively via `[[package]]` blocks in `release-plz.toml`.
- For dual-distribution (crates.io + binaries), pair release-plz with cargo-dist exactly as in Flavor A — release-plz creates the tag, cargo-dist builds binaries on it.

### Caveats

- Do **not** mix `release-plz` with `@semantic-release/git` — pick one version manager. Semantic-release does not understand `Cargo.toml` lockfile semantics.
- Commit `Cargo.lock` for CLI repos (reproducible binary builds); keep it ignored only for pure libraries that explicitly need it.
- crates.io publishes are immutable — a botched version cannot be re-pushed, only yanked. Validate via `release-plz update --dry-run` on a topic branch before the first release.

## Homebrew Tap

A Homebrew tap is just a separate GitHub repo named `homebrew-<tap>` (the `homebrew-` prefix is required) containing one Ruby formula per CLI under `Formula/<name>.rb`. End users install with `brew tap <org>/<tap>` then `brew install <name>`. The release pipeline's job is to keep the formula in the tap repo current.

### Cross-repo token

Whichever flow you pick, you need a token that can push to the tap repo from the source repo's release workflow. The default `GITHUB_TOKEN` is scoped to the source repo only.

- Create a fine-grained PAT (or GitHub App installation token) with `contents: write` on the tap repo only.
- Store it as `TAP_GITHUB_TOKEN` (or similar) in the source repo's secrets.
- Use one narrowly scoped token per org and purpose.

### Flow A — GoReleaser auto-update

GoReleaser writes the formula directly. Add a `brews:` block in `.goreleaser.yaml`:

```yaml
brews:
  - name: <cli-name>
    repository:
      owner: <org>
      name: homebrew-tap
      token: "{{ .Env.TAP_GITHUB_TOKEN }}"
    directory: Formula
    homepage: "https://github.com/<org>/<repo>"
    description: "<one-line description>"
    license: "MIT"
    test: |
      system "#{bin}/<cli-name>", "--version"
```

GoReleaser commits the updated `Formula/<cli-name>.rb` straight to the tap's default branch on every release. No extra workflow step needed.

### Flow B — Non-Go CLI (Node, Ruby, etc.)

First check whether the org already has a non-Go CLI publishing to the same tap. If it does, copy that action and input shape unless the packaging format is different.

For script or binary CLIs whose Homebrew formula can be generated from the GitHub Release archive, [`Justintime50/homebrew-releaser`](https://github.com/Justintime50/homebrew-releaser) is the boring direct-to-tap pattern. It clones the source repo and tap repo, generates or updates the formula, and commits straight to the tap branch using the supplied token. Pin the same major version the working sibling repo uses.

```yaml
- if: steps.release.outputs.new_release_published == 'true'
  uses: Justintime50/homebrew-releaser@v3
  with:
    homebrew_owner: <org>
    homebrew_tap: homebrew-tap
    formula_folder: Formula
    github_token: ${{ secrets.TAP_GITHUB_TOKEN }}
    commit_owner: release-bot
    commit_email: release-bot@users.noreply.github.com
    install: 'bin.install "<cli-name>"'
    test: 'system "#{bin}/<cli-name>", "--version"'
```

Use [`dawidd6/action-homebrew-bump-formula`](https://github.com/dawidd6/action-homebrew-bump-formula) when you explicitly want its version-bump workflow and have verified its fork/direct-push behavior against the tap repo. Default to the tap repo's expected release shape; some setups need a direct push to the tap.

```yaml
- if: steps.release.outputs.new_release_published == 'true'
  uses: dawidd6/action-homebrew-bump-formula@v5
  with:
    token: ${{ secrets.TAP_GITHUB_TOKEN }}
    tap: <org>/homebrew-tap
    formula: <cli-name>
    tag: v${{ steps.release.outputs.new_release_version }}
```

- The action computes the tarball sha256 from the GitHub-hosted release archive, so the source release must complete before this step runs.
- For a Node CLI distributed via npm rather than a GitHub release archive, write a custom formula that uses `Language::Node::Shebang` and a `resource` block; the bump action does not handle that shape.
- If the working sibling repo uses `Justintime50/homebrew-releaser`, keep that standard action. Use custom shell only after proving no maintained action fits.

### Tap repo conventions

- Keep formulae under `Formula/`. Homebrew also accepts repo root, but `Formula/` scales when you add more CLIs.
- Add a CI job to the tap repo that runs `brew audit --strict --online Formula/*.rb` on PR. Catches malformed formulae before they break user installs.
- Pin the tap to a release branch only if you need staged rollouts. Default to publishing straight to `main`.
- A formula update commit on the tap is itself a release event for users — bot identity and `[skip ci]` semantics apply there too if the tap repo has its own CI.

## GitHub Action (Marketplace)

A composite or JS action is "published" by tagging — the marketplace pulls from tags. No registry push.

Plugins:

```json
"@semantic-release/git",
"@semantic-release/github"
```

- The `git` plugin commits the bump (typically just `package.json` for a JS action) so consumers pinning to `@v1` follow the moving major tag.
- For a moving major tag (`@v1` always pointing at the latest `v1.x.y`), add a step after semantic-release:

  ```yaml
  - if: steps.release.outputs.new_release_published == 'true'
    run: |
      MAJOR="v$(echo '${{ steps.release.outputs.new_release_version }}' | cut -d. -f1)"
      git tag -f "$MAJOR"
      git push -f origin "$MAJOR"
  ```

- The action's `action.yml` `runs:` block must reference the **bundled** entrypoint (`dist/index.js`), not a TS source file. Build it in the verify path and either commit `dist/` or rebuild in the release job.

## Monorepo (Node)

One semantic-release run per package, each with its own `.releaserc.json` and tag prefix:

```json
{
  "tagFormat": "<package-name>-v${version}",
  "branches": ["main"]
}
```

Workflow:

```yaml
- uses: cycjimmy/semantic-release-action@v4
  with:
    working_directory: packages/<package-name>
```

- Tag prefix prevents collisions when multiple packages release independently.
- For coordinated releases across packages, prefer changesets or release-please; this pipeline pattern targets independent per-package releases.
