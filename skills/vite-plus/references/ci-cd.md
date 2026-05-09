# CI/CD

Use this reference before changing GitHub Actions or release automation.

Prefer the documented Vite+ setup:

```yaml
- uses: voidzero-dev/setup-vp@v1
  with:
    node-version-file: ".node-version"
    cache: true
- run: vp install
- run: vp check
- run: vp test
- run: vp build
```

## Action Inputs

`voidzero-dev/setup-vp@v1` exposes:

| Input | Purpose |
| ----- | ------- |
| `version` | Pin a specific Vite+ release. Defaults to latest; pin when CI must stay aligned with a chosen release. |
| `node-version` | Node.js version to install via `vp env use`. |
| `node-version-file` | Read the Node.js version from a file (`.node-version`, `.nvmrc`, etc.). |
| `working-directory` | Project root for path resolution and lockfile detection. |
| `run-install` | Run `vp install` after setup. Boolean or YAML config. |
| `cache` | Cache project dependencies. Auto-detects pnpm/npm/yarn/bun lockfiles. |
| `cache-dependency-path` | Override the lockfile path used for cache key generation. |
| `registry-url` / `scope` | Configure scoped npm registry authentication. |

## Defaults

- Prefer `voidzero-dev/setup-vp@v1` over hand-rolled Node/Corepack bootstrapping unless the repo has a proven exception.
- Prefer `setup-vp`'s built-in Node and package-manager bootstrap over adding separate CI-time `vp env` setup steps unless the repo has a specific environment need the action does not cover.
- Prefer `vp install` over separate package-manager bootstrap logic when Vite+ is the tool owner. The action's `run-install: true` input collapses setup + install into one step.
- Prefer `vp config` when the repo wants stock hooks or agent integration instead of hand-rolled hook setup.
- Prefer one repo-local verify entrypoint if CI needs extra repo-specific commands.
- Keep release orchestration in GitHub Actions when the repo has npm, GitHub Release, binary, or Homebrew automation that goes beyond stock Vite+.
- Vite+ can run repo scripts, but it does not make runtime-installed release plugins reproducible by itself. For semantic-release jobs, follow `gh-release-pipeline`: keep CI/CD-only plugins in the workflow's `extra_plugins` input with exact versions instead of adding release-only packages to repo `devDependencies`.
- When CI behavior must stay aligned with a repo's chosen Vite+ release, pin the `setup-vp` action's `version` input explicitly. Treat the local `vite-plus` dependency version in `package.json` as separate from the action's runtime version.

## Guardrails

- Prefer `vp run <script>` (or `vpr <script>`) when CI needs a repo-specific script that Vite+ does not replace.
- Preserve release-only steps while making the surrounding workflow more stock.
- Keep packaging and publish steps that Vite+ does not own.
