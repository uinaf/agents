# Troubleshooting

Common failure modes when standing up or operating this pipeline. Check here before rewriting the workflow.

## Release ran but produced no version

- Likely cause: no commits since the last tag matched a release-bumping type (`feat:`, `fix:`, breaking). `chore:`/`docs:`/etc. are no-ops by default.
- Verify: `npx semantic-release --dry-run --no-ci` from the release branch. The output lists analyzed commits and the decision.
- Fix: either land a `feat:` / `fix:` commit, or extend `commit-analyzer` `releaseRules` to bump on the type you care about.

## Bump commit triggers a second release (infinite loop)

- Cause: the `[skip ci]` guard is missing on the release job's `if:`, or the bump message no longer contains `[skip ci]`.
- Verify: open the bump commit on `main`. Message must contain `[skip ci]`. Workflow must have `if: ${{ … !contains(github.event.head_commit.message, '[skip ci]') }}` on **both** verify and release.

## "fatal: could not read Username for 'https://github.com'" during `@semantic-release/git` push

- Cause: the checkout step omitted `persist-credentials: true` (or set it to false), or the workflow's default token does not have `contents: write`.
- Fix: ensure `actions/checkout@<full-sha> # v6.x.y` keeps credentials and the release job declares `permissions: { contents: write }`.

## Tag created but no GitHub Release / no published artifact

- Cause: `@semantic-release/github` (or the publish plugin) ran but failed silently because `GITHUB_TOKEN` / `NPM_TOKEN` was not exported into the step's `env:`.
- Verify: action logs show "no GH token" or "ENEEDAUTH" near the publish step.
- Fix: declare every secret on the **step**, not the job. `cycjimmy/semantic-release-action` reads from the step's `env:`.

## Two releases racing produced duplicate tags or a dangling release

- Cause: the release job's concurrency group is missing or has `cancel-in-progress: true`.
- Fix: set `concurrency: { group: release-${{ github.repository }}-main, cancel-in-progress: false }` at the **job** level. The verify job's cancellable group is separate.

## Verify passes locally but fails on the bot's bump commit

- Cause: the verify job is not skipping `[skip ci]` commits and is re-running the suite on the bump.
- Fix: add the `[skip ci]` guard to verify too. The bot commit changes generated files (`CHANGELOG.md`, lockfiles); re-running verify on it is wasted CI minutes at best and a flake source at worst.

## Semantic-release computes the wrong version

- Cause: shallow checkout — semantic-release walks history, and `fetch-depth: 1` (the default) hides previous tags.
- Fix: `actions/checkout@<full-sha> # v6.x.y` with `fetch-depth: 0` on **both** verify and release.

## npm publish fails with "ENEEDAUTH" or 403

- `setup-node` did not write the auth file. Add `registry-url: "https://registry.npmjs.org"` to the action.
- For scoped packages on the public registry, `package.json` needs `"publishConfig": { "access": "public" }`.
- Token type: a classic automation token, or a granular token scoped to publish for the package.

## CocoaPods publish fails with "Unable to accept duplicate entry"

- The version was already pushed to trunk on a previous attempt that failed mid-flight. Trunk does not allow re-pushing the same version.
- Fix: bump the version (land another `feat:` / `fix:`), or `pod trunk delete <podname> <version>` (requires owner) and re-run.

## GoReleaser fails with "git is dirty"

- Generated files (`dist/`, `Package.swift` rewrite) leak into the working tree before goreleaser runs.
- Fix: ensure `goreleaser release --clean` flag is set, and that any pre-release script writes its output outside the working tree or stages it before goreleaser starts.

## Marketplace consumers pinning `@v1` see no updates

- The moving major tag was not force-updated after the release.
- Fix: add the `git tag -f v1 && git push -f origin v1` step (see [targets.md](targets.md) → GitHub Action). Verify by clicking the tag on the GitHub release page — it should match the latest `v1.x.y`.

## "GH_TOKEN env or githubToken provided" with semantic-release action v6

- v6 renamed some inputs. Use a full-SHA-pinned v4 line unless the repo has explicitly migrated to a full-SHA-pinned v6 line and confirmed token plumbing.
