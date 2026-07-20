# Publish Targets

Use this reference when wiring the publish step. The verify→release shape stays identical across targets; only the publish plumbing and secrets change.

Before picking an action, inspect the repo's current release files and at least one known-good sibling repo when the organization has one. Release and tap actions have subtle defaults around forks, direct pushes, generated formulae, and token scopes; copying the nearest working pattern is usually safer than inventing a new one.

## npm (Library or CLI)

Default to npm Trusted Publishing from GitHub Actions. Configure the package on npm with the GitHub organization/repo, workflow filename, and `release` Environment when used; then grant the release job `id-token: write` and remove `NPM_TOKEN`. Trusted publishing uses short-lived OIDC credentials and automatically produces npm provenance for public packages from public repos.

Use the npm CLI when enabling trusted publishing for one or many packages. `npm trust` requires npm `11.10.0` or newer; use the local npm when it meets that floor, otherwise pin the operator command with `npx -y npm@^11.10.0`. Login once with a package owner/admin account, then register each package's GitHub workflow identity:

```bash
npm login
npm trust github <package-name> --repo <owner>/<repo> --file <workflow-file> --env <environment> --allow-publish --yes
```

Examples:

```bash
npm trust github @scope/library --repo scope/library --file ci.yml --env release --allow-publish --yes
npm trust github cli-package --repo scope/cli-package --file release.yml --allow-publish --yes
```

- At least one permission flag is required or `npm trust` errors: `--allow-publish` for regular publishes, `--allow-stage-publish` only when the workflow uses npm's staged-release flow.
- Use `--env release` when the release job declares `environment: release` or `environment: { name: release }`. Omit `--env` only when the publishing job does not use a GitHub Environment.
- `npm trust` registers publishers on existing packages only; it fails with "package not found" for a first release. Bootstrap order for a new package: ensure the scope's npm org exists, do a one-time manual `npm publish` from a clean clone with 2FA/web login (no automation token — a `prepack` script should own verify plus a clean build), then register the trusted publisher and let the workflow own every later release.

Plugins:

```json
"@semantic-release/npm",
"@semantic-release/git",
"@semantic-release/github"
```

Workflow step:

```yaml
- uses: actions/setup-node@<full-sha> # v6.4.0
  with:
    node-version-file: ".node-version"
    package-manager-cache: false
- run: npm ci
- uses: cycjimmy/semantic-release-action@<full-sha> # v6.0.0
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- For npm package repos, check in `.node-version` with the latest active LTS line, currently Node 24.x. Migrate Node version-file examples and workflow setup to `.node-version`.
- Do not set `registry-url` for semantic-release npm publishing. With trusted publishing, npm authenticates from the job's OIDC identity rather than a registry token written by `setup-node`.
- If the package cannot use trusted publishing, use a granular automation token only as a fallback, scope it to the package, store it in the `release` Environment, and expose `NPM_TOKEN` only on the semantic-release step.
- Do not enable package-manager caches in the npm publish job. Install fresh in the secret-bearing job, then run `npm pack --dry-run` or the repo's pack smoke before publishing when the package surface is non-trivial.
- For scoped public packages set `"publishConfig": { "access": "public" }` in `package.json`.
- Ensure `package.json` has a public `repository` URL that exactly matches the GitHub repo used in the trusted publisher configuration.
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
- Secrets: `COCOAPODS_TRUNK_TOKEN` exported as env on the publish step. Generate the trunk token with `pod trunk register` once, then store it as a `release` Environment secret by default. Use a repository secret only when the repo has an explicit reason not to use a release Environment.
- SwiftPM consumers pull from the git tag — no separate publish step needed.
- Cache download artifacts only inside a single trust class. Regenerate or verify generated dependency trees such as full `Pods/` inside signed or publishing jobs before signing or publishing.

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
- uses: cycjimmy/semantic-release-action@<full-sha> # v6.0.0
  id: release
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

- if: steps.release.outputs.new_release_published == 'true'
  uses: goreleaser/goreleaser-action@<full-sha> # v7.2.2
  with:
    version: v2.15.4
    args: release --clean
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    TAP_GITHUB_TOKEN: ${{ secrets.TAP_GITHUB_TOKEN }}

- if: steps.release.outputs.new_release_published == 'true'
  uses: actions/attest-build-provenance@<full-sha> # v4.1.0
  with:
    subject-path: 'dist/*.tar.gz,dist/*.zip'
```

- `TAP_GITHUB_TOKEN` is needed only if GoReleaser publishes to a Homebrew tap in another repo (see Homebrew Tap below).
- Add `id-token: write` and `attestations: write` to the job's `permissions:` for the attestation step.
- `--clean` wipes `dist/` before building so a previous run cannot poison the new release.
- Build and upload release artifacts from the release tag or verified release commit. If a workflow intentionally promotes an existing artifact, require recorded provenance: source commit, tag, build number/version, artifact digest, and producing workflow run.
- If a later deploy job needs the released bits, download them from the published GitHub Release, registry, image digest, or provider-native package. Do not re-upload the release payload as a GitHub Actions artifact just to bridge release and deploy jobs.

## Rust

Two flavors depending on whether you publish to crates.io. Both pair with **[`cargo-dist`](https://opensource.axo.dev/cargo-dist/)** for cross-platform binaries + Homebrew formula generation (cargo-dist is GoReleaser's Rust equivalent).

### Flavor A — CLI without crates.io (Homebrew/binaries only)

Mirrors the Go/GoReleaser shape at the release boundary, but let cargo-dist own the binary distribution workflow. Keep semantic-release as the version-decider (tag-only, no source bump), then let the cargo-dist generated tag workflow build, host, publish, and announce the artifacts.

Plugins (no `@semantic-release/git`):

```json
"@semantic-release/commit-analyzer",
"@semantic-release/release-notes-generator",
"@semantic-release/github"
```

Semantic-release job:

```yaml
- uses: dtolnay/rust-toolchain@<full-sha> # stable
- uses: cycjimmy/semantic-release-action@<full-sha> # v6.0.0
  id: release
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- No `CARGO_REGISTRY_TOKEN` needed — nothing publishes to crates.io.
- `cargo-dist` is a CLI and generated workflow system, not a maintained GitHub Action. Do not use stale `axodotdev/cargo-dist-action` snippets.
- Run `cargo dist init` or `dist generate` in the repo so cargo-dist owns the tag-triggered workflow. That generated workflow should cover the plan, build, host, publish, and announce phases; do not replace it with only `cargo dist build`, which leaves artifacts local to the runner.
- `cargo dist init` writes `[workspace.metadata.dist]` in `Cargo.toml`. Set `tap = "<org>/homebrew-tap"` and `installers = ["shell", "powershell", "homebrew"]`.
- Default targets: `x86_64-unknown-linux-gnu`, `aarch64-apple-darwin`, `x86_64-apple-darwin`, `x86_64-pc-windows-msvc`. Add `x86_64-unknown-linux-musl` for static Linux; `aarch64-unknown-linux-gnu` for ARM64 Linux.
- `cargo-binstall` works out of the box — cargo-dist follows binstall's naming conventions.
- Simpler alternative if you don't need installers or Homebrew: `taiki-e/upload-rust-binary-action@<full-sha> # v1.30.2` in a matrix job.

### Flavor B — Library or dual-distribution (crates.io)

When you do publish to crates.io, swap semantic-release for **[`release-plz`](https://release-plz.dev/)**. It understands `Cargo.toml`, handles workspaces, runs `cargo publish` in dependency order, and generates `CHANGELOG.md`.

```yaml
- uses: dtolnay/rust-toolchain@<full-sha> # stable
- uses: release-plz/action@<full-sha> # v0.5.129
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

- Default mode opens a "Release PR" that bumps `Cargo.toml` + `CHANGELOG.md`. Merging the PR triggers tag + crates.io publish. Replaces the `[skip ci]` bump-back loop with an explicit-merge gate.
- For the auto-push variant (matching the semantic-release `[skip ci]` shape), set `git_release_enable = true` in `release-plz.toml` only when the repo can push through branch rules with `GITHUB_TOKEN`, a dedicated release bot, or a narrowly scoped GitHub App token that is explicitly allowed for release pushback. If no narrow release actor can be allowed, keep the default Release PR flow.
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
- Store it as `TAP_GITHUB_TOKEN` (or similar) in the source repo's `release` Environment secrets by default. Use a repository secret only when an Environment is intentionally not part of the publish boundary.
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

For script or binary CLIs whose Homebrew formula can be generated from the GitHub Release archive, [`Justintime50/homebrew-releaser`](https://github.com/Justintime50/homebrew-releaser) is the boring direct-to-tap pattern. It clones the source repo and tap repo, generates or updates the formula, and commits straight to the tap branch using the supplied token. Pin the action to a full commit SHA with a same-line version comment matching the version line the working sibling repo uses.

```yaml
- if: steps.release.outputs.new_release_published == 'true'
  uses: Justintime50/homebrew-releaser@<full-sha> # v3.3.0
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
  uses: dawidd6/action-homebrew-bump-formula@<full-sha> # v7
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
- For a moving major tag (`@v1` always pointing at the latest `v1.x.y`), use a maintained semantic-release plugin or a tiny repo-owned release action. Do not paste tag parsing and force-push shell into workflow YAML.

  ```yaml
  - if: steps.release.outputs.new_release_published == 'true'
    uses: ./.github/actions/update-major-action-tag
    with:
      version: ${{ steps.release.outputs.new_release_version }}
  ```

  The local action should do one thing: update `v<major>` to the release commit and push it with the release token. If a maintained semantic-release major-tag plugin fits the repo, prefer that.

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
- uses: cycjimmy/semantic-release-action@<full-sha> # v6.0.0
  with:
    working_directory: packages/<package-name>
```

- Tag prefix prevents collisions when multiple packages release independently.
- For coordinated releases across packages, prefer changesets or release-please; this pipeline pattern targets independent per-package releases.
