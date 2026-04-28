# Workflows

Conventions for deploy workflow files. Two files cover the common cases; only add a third for preview deploys (PR-driven).

Start by reading the repo's existing workflow/action files and any same-org repo that deploys to the same host. Preserve proven composite actions, token names, and deploy scripts when the target matches. Marketplace examples are fallback material, not the first source of truth.

## File layout

```
.github/
├── workflows/
│   ├── main.yml      # push to main → detect → verify → e2e → deploy → smoke
│   ├── deploy.yml    # workflow_dispatch → re-deploy a ref + lane (no verify)
│   └── verify.yml    # pull_request + merge_group → verify only (no deploy)
└── actions/
    ├── setup-workspace/        # one place to bootstrap (Node, pnpm/vite+, cache)
    ├── load-1password-env/     # secret rendering, see references/secrets.md
    ├── <host>-deploy/          # cloudflare-pages-deploy / amplify-deploy / vps-deploy
    └── publish-preview-comment/  # only if you do PR previews
```

Composite actions, not reusable workflows, for the deploy primitives. Reusable workflows are useful when you have many lanes that share the *whole* job graph (build → e2e → deploy); composite actions are right when only the deploy step itself is shared. A larger uinaf app may use both: `lane.yml` as a reusable workflow that calls `deploy-hosted-app` (composite). A smaller app can stay simpler with composite actions only and duplicated jobs per lane.

## Triggers

```yaml
# main.yml
on:
  push:
    branches: [main]

# verify.yml
on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
  merge_group:

# deploy.yml
on:
  workflow_dispatch:
    inputs:
      ref:  { type: string, default: main, description: "Git ref to deploy" }
      lane: { type: choice, options: [all, <lane-1>, <lane-2>], default: all }
```

- `merge_group:` covers the GitHub merge queue. Without it the queue blocks PRs that depend on green checks from this workflow.
- `pull_request: { types: [...ready_for_review] }` keeps draft PRs out of CI but picks them up the moment they're marked ready.
- Do **not** add `push:` to `verify.yml` — the verify gate runs inside `main.yml` for push events.

## Concurrency

Three different shapes, each tuned to the job's blast radius:

```yaml
# verify / e2e — kill in-flight runs when the user pushes again
concurrency:
  group: ${{ github.workflow }}-verify-${{ github.ref }}-${{ matrix.lane }}
  cancel-in-progress: true

# deploy — never cancel; serialize per (env, lane)
concurrency:
  group: deploy-${{ inputs.environment || 'production' }}-${{ matrix.lane }}
  cancel-in-progress: false

# top-level workflow guard for verify.yml only
concurrency:
  group: verify-${{ github.event.pull_request.number || github.run_id }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

The deploy group must be **the same key in `main.yml` and `deploy.yml`**. That's how a manual re-deploy serializes against an in-flight push deploy. Mismatched keys → both run, and whichever finishes second wins on the host but loses on the artifact log.

## Permissions

Default to least privilege at the workflow root, then re-grant per job:

```yaml
permissions:
  contents: read

jobs:
  deploy-web:
    permissions:
      contents: read
      id-token: write          # AWS OIDC / Cloudflare with OIDC / GitHub attestations
      pull-requests: write     # only if posting preview comments
```

- `id-token: write` is required for any OIDC-backed cloud auth (`aws-actions/configure-aws-credentials`, GHCR's keyless tokens, Cloudflare's API-token-via-OIDC).
- `packages: write` is required for `docker/build-push-action` to push to GHCR.
- Never put `pull-requests: write` on the verify job — it should not be able to mutate the PR.

## Checkout

```yaml
- uses: actions/checkout@v6
  with:
    fetch-depth: 0      # required for paths-filter and turbo --affected
    persist-credentials: true   # default; keep on if a later step pushes
```

`fetch-depth: 0` is non-negotiable for the `changes` job. Without git history, `paths-filter` cannot diff against the previous commit and `turbo run --affected` cannot resolve the merge base.

## Change detection

Two patterns; pick by repo shape.

### `dorny/paths-filter@v4` (per-app rules, simple repos)

```yaml
- id: filter
  uses: dorny/paths-filter@v4
  with:
    filters: |
      web:
        - 'apps/web/**'
        - 'packages/**'
        - 'package.json'
        - 'pnpm-lock.yaml'
      api:
        - 'apps/api/**'
        - 'packages/**'
        - 'Dockerfile'
```

Always include the lockfile and shared `packages/`. A dep bump must rebuild every lane that consumes it.

### Turbo `--affected` (monorepo with package graph)

```yaml
- id: detect
  run: |
    pnpm exec turbo run build --affected --dry=json \
      | jq -r '.tasks[].package' | sort -u > /tmp/affected.txt

    grep -q '^@org/web$'  /tmp/affected.txt && echo "web=true"  >> "$GITHUB_OUTPUT" || true
    grep -q '^@org/api$'  /tmp/affected.txt && echo "api=true"  >> "$GITHUB_OUTPUT" || true
```

Turbo follows the `dependsOn` graph; it catches transitive changes that a flat path-filter misses. Pair it with a "force lanes if these CI/hosting paths changed" rule (e.g. `.github/workflows/**`, `Dockerfile`, `infrastructure/**`) so a CI-only change still runs the full lane.

## Artifact pass-through

The same artifact must flow `verify → e2e → deploy`. Upload once, download twice.

```yaml
# verify-<lane>
- uses: actions/upload-artifact@v7
  with:
    name: <lane>-dist
    path: apps/<lane>/dist
    if-no-files-found: error
    include-hidden-files: true   # next/_next/, vite ssr manifests, etc.

# e2e-<lane>, deploy-<lane>
- uses: actions/download-artifact@v8
  with:
    name: <lane>-dist
    path: apps/<lane>/dist
```

- `if-no-files-found: error` catches a build that silently emits zero files into the wrong directory.
- `include-hidden-files: true` is required for any framework that emits a leading-dot directory (`.next/`, `.output/`, `.amplify-artifacts/`).
- Artifact names must be unique per lane (`web-dist`, `tv-dist`, `api-image-meta`); GitHub will not overwrite same-name artifacts within a run.

## Job dependencies

```yaml
deploy-web:
  needs: [verify-web, e2e-web]
  if: ${{ needs.verify-web.result == 'success' && needs.e2e-web.result == 'success' }}
```

Avoid `if: success()` — it does not catch the case where `verify-web` was *skipped* (the lane wasn't affected). Explicit `result == 'success'` makes the gate exact and readable. The `always() && (...)` form is for the final summary job, not for deploy gates.

## Bootstrap snippets

For a Vite+ workspace:

```yaml
- uses: voidzero-dev/setup-vp@v1
  with:
    version: ${{ env.VITE_PLUS_VERSION }}
    node-version-file: .node-version
    cache: true
- run: vp env && vp install
```

For a plain pnpm + Node workspace:

```yaml
- uses: actions/setup-node@v5
  with:
    node-version-file: .node-version
    cache: pnpm
- uses: pnpm/action-setup@v4
  with: { run_install: false }
- run: pnpm install --frozen-lockfile
```

For a Docker build (api/backend lane):

```yaml
- uses: docker/setup-buildx-action@v3
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
- uses: docker/build-push-action@v6
  with:
    context: .
    push: true
    tags: |
      ghcr.io/${{ github.repository }}:${{ github.sha }}
      ghcr.io/${{ github.repository }}:main
    cache-from: type=gha
    cache-to:   type=gha,mode=max
```

## Step summary

End every deploy run with a `GITHUB_STEP_SUMMARY` block listing what shipped, where, and at which commit. That is the artifact the on-call human reads when something is on fire — not the raw job log.

```yaml
- run: |
    {
      echo "## Production deploy"
      echo
      echo "- Commit: \`${GITHUB_SHA}\`"
      echo "- Web:    [https://web.example.com](https://web.example.com) (\`${{ needs.deploy-web.result }}\`)"
      echo "- API:    [https://api.example.com](https://api.example.com) (\`${{ needs.deploy-api.result }}\`)"
    } >> "${GITHUB_STEP_SUMMARY}"
```
