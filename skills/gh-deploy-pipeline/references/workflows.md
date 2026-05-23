# Workflows

Conventions for deploy workflow files. Two files cover the common cases; only add a third for preview deploys (PR-driven).

Start by reading the repo's existing workflow/action files and any same-org repo that deploys to the same host. Preserve proven composite actions, token names, and deploy scripts when the target matches. Marketplace examples are fallback material, not the first source of truth.

## File layout

```
.github/
├── workflows/
│   ├── main.yml      # push to main → detect → verify → e2e → deploy → smoke
│   ├── deploy.yml    # workflow_dispatch -> re-deploy a verified payload ref
│   └── verify.yml    # pull_request + merge_group → verify only (no deploy)
└── actions/
    ├── setup-workspace/        # one place to bootstrap (Node, pnpm/vite+, cache)
    ├── assume-deploy-identity/ # optional OIDC/provider federation wrapper
    ├── deploy-<lane>/          # repo-owned provider-thin deploy primitive, often SST
    └── smoke-<lane>/           # credential-free environment health check
```

Composite actions can be useful for repo-owned deploy primitives, but do not turn this skill into a host cookbook. Keep provider mechanics in SST, scripts, infrastructure code, or a small local action whose inputs are payload reference or path, environment, lane, immutable version, and explicit deploy config path.

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
      ref:         { type: string, required: true, description: "Verified git ref or SHA to promote" }
      environment: { type: choice, options: [staging, production], required: true }
      lane:        { type: choice, options: [web, api], required: true }
```

- `merge_group:` covers the GitHub merge queue. Without it the queue blocks PRs that depend on green checks from this workflow.
- `pull_request: { types: [...ready_for_review] }` keeps draft PRs out of CI but picks them up the moment they're marked ready.
- Do **not** add `push:` to `verify.yml` — the verify gate runs inside `main.yml` for push events.
- Secret-bearing manual deploys validate `inputs.ref`, `inputs.environment`, and `inputs.lane` in a secretless step before checkout or secret loading. Prefer `main`, protected release tags, or exact SHAs with a matching durable payload.
- Environment branch/tag rules constrain the workflow run ref; validate any separately checked-out `inputs.ref` as its own trust boundary.
- Manual redeploys consume an existing release asset, package version, provider package, or image by immutable digest/SHA in the secret-bearing job.
- Pass manual inputs through `env:`, validate them, emit sanitized step outputs, and use those outputs for checkout or payload lookup.
- Do not use `pull_request_target` for any workflow that checks out, installs, builds, tests, packages, deploys, or otherwise executes project code. Keep fork and outsider code on `pull_request` with read-only credentials and no deploy secrets.

## Standard hardening gates

Run standard scanners before adding repo-specific workflow guard scripts:

```yaml
workflow-hardening:
  runs-on: ubuntu-latest
  permissions:
    contents: read
  steps:
    - uses: actions/checkout@<full-sha> # v6.x.y
    - run: actionlint
    - uses: zizmorcore/zizmor-action@5f14fd08f7cf1cb1609c1e344975f152c7ee938d # v0.5.6
      with:
        advanced-security: false
        annotations: true
        min-severity: medium
        min-confidence: medium
```

- Prefer `actionlint` for workflow syntax/expression checks and `zizmor` for GitHub Actions security issues.
- Prefer scanner-backed checks over bespoke grep/awk scripts for shell injection, token exposure, dangerous triggers, and credential flow.
- If GitHub Advanced Security is enabled, set `advanced-security: true` and keep `security-events: write`; otherwise use annotations and omit `security-events: write`.
- Install `actionlint` through the repo's normal tool bootstrap or a pinned setup action; do not replace it with a hand-rolled YAML parser.

## Manual staging deploy from PR branch

Use this when humans need to exercise a same-repo PR branch in staging before merge.

- The workflow file itself lives on the default branch.
- Inputs accept a same-repo branch name or a full 40-character SHA.
- Validate input in a secretless job before checkout and before any Environment credentials.
- Resolve the input to one SHA once, emit that SHA as an output, and use only that output downstream.
- App deploys may deploy the resolved branch SHA to staging.
- Zone/domain/IaC changes only deploy from the default branch unless the repo has a proven isolated staging state boundary.
- Production deploy accepts only the default branch name or the current default-branch SHA.

```yaml
on:
  workflow_dispatch:
    inputs:
      ref:
        type: string
        required: true
        description: "Same-repo branch or full SHA"
      environment:
        type: choice
        options: [staging, production]
        required: true

jobs:
  validate-ref:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    outputs:
      sha: ${{ steps.resolve.outputs.sha }}
      environment: ${{ steps.validate.outputs.environment }}
    steps:
      - uses: actions/checkout@<full-sha> # v6.x.y
        with:
          fetch-depth: 0
      - id: validate
        env:
          INPUT_REF: ${{ inputs.ref }}
          INPUT_ENVIRONMENT: ${{ inputs.environment }}
          DEFAULT_BRANCH: ${{ github.event.repository.default_branch }}
        run: |
          case "$INPUT_ENVIRONMENT" in staging|production) ;; *) exit 1 ;; esac
          if [ "$INPUT_ENVIRONMENT" = production ] && [ "$INPUT_REF" != "$DEFAULT_BRANCH" ]; then
            git rev-parse "$DEFAULT_BRANCH" | grep -qx "$INPUT_REF" || exit 1
          fi
          echo "environment=$INPUT_ENVIRONMENT" >> "$GITHUB_OUTPUT"
      - id: resolve
        env:
          INPUT_REF: ${{ inputs.ref }}
        run: |
          git fetch origin "$INPUT_REF" --depth=1
          sha="$(git rev-parse FETCH_HEAD)"
          echo "sha=$sha" >> "$GITHUB_OUTPUT"
```

## Concurrency

Three different shapes, each tuned to the job's blast radius:

```yaml
# verify / e2e — kill in-flight runs when the user pushes again
concurrency:
  group: ${{ github.workflow }}-verify-${{ github.ref }}-${{ matrix.lane }}
  cancel-in-progress: true

# deploy — serialize per (env, lane)
concurrency:
  group: deploy-${{ inputs.environment || 'production' }}-${{ matrix.lane }}
  cancel-in-progress: false

# top-level workflow guard for verify.yml only
concurrency:
  group: verify-${{ github.event.pull_request.number || github.run_id }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

The deploy group must be **the same key in `main.yml` and `deploy.yml`**. That's how a manual re-deploy serializes against an in-flight push deploy. Mismatched keys -> both run, and whichever finishes second wins on the host but loses the provenance trail.

## Permissions

Default to least privilege at the workflow root, then re-grant per job:

```yaml
permissions:
  contents: read

jobs:
  deploy-web:
    permissions:
      contents: read
      id-token: write          # provider OIDC / deploy federation / GitHub attestations
      pull-requests: write     # only if posting preview comments
```

- `id-token: write` is required for OIDC-backed provider auth and keyless attestations.
- Add registry-specific write permissions only when the verified build job publishes a release asset, package, provider package, or image to that registry.
- Keep verify jobs read-only for pull requests.
- Smoke jobs are read-only and should not receive OIDC or deploy-provider credentials.

## Checkout

```yaml
- uses: actions/checkout@<full-sha> # v6.x.y
  with:
    fetch-depth: 0      # required for paths-filter and turbo --affected
    persist-credentials: true   # default; keep on if a later step pushes
```

`fetch-depth: 0` is non-negotiable for the `changes` job. Without git history, `paths-filter` cannot diff against the previous commit and `turbo run --affected` cannot resolve the merge base.

## Change detection

Two patterns; pick by repo shape.

### `dorny/paths-filter` (per-app rules, simple repos)

```yaml
- id: filter
  uses: dorny/paths-filter@<full-sha> # v4.x.y
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

## Payload pass-through

The same deploy payload must flow `verify -> e2e -> deploy`. Prefer the most durable payload boundary the repo already owns: a container image digest, package/release asset, provider-native deployment package, or same-job filesystem handoff for simple static deploys.

Do not reflexively add `actions/upload-artifact` / `actions/download-artifact` between build and deploy. GitHub Actions artifacts are quota- and retention-coupled CI storage. They are acceptable only as same-run scratch handoff when quota/retention are understood, but they are a weak default for production deploy or release promotion when a registry, GitHub Release asset, image digest, or provider-native package exists.

For a simple static app where build, e2e, and deploy can safely share one trusted job, keep the payload on disk and deploy after tests. Preserve security by loading deploy credentials only in the environment-scoped job and keeping smoke in a downstream read-only job.

Treat Actions artifacts as an exception, not the recipe. If a repo truly has no durable payload store and accepts same-run quota/retention coupling, document that tradeoff beside the workflow and keep artifact names unique per lane. Otherwise choose one of these shapes:

- Same-job static handoff: build the static payload, run e2e against that local output, deploy from the same runner filesystem, then run smoke in a separate read-only job.
- Release/registry handoff: publish the verified payload to a GitHub Release, package registry, provider package, or image registry, output its immutable ref, and have deploy consume that ref.
- Provider-native handoff: ask the hosting provider to create a deployment package or deployment id, then promote that id through the environment.

## Caches

- Caches speed dependency downloads and tool setup; they are not deployment payloads.
- Secret-bearing deploy and promotion jobs should prefer immutable payload refs produced by the verified trusted run over fresh package-manager cache restores.
- Do not share package-manager caches between `pull_request` and privileged `push: main`, `workflow_dispatch`, or tag-driven jobs.
- Rebuild or verify generated app output, package/vendor trees, container layers, and built bundles inside the trusted deploy path.
- If deploy-time setup needs a cache, namespace by workflow, event/trust level, platform, and lockfile. Privileged jobs consume only caches from the same trusted event class. The deployed payload still comes from the current verified payload ref.

## Job dependencies

```yaml
deploy-web:
  needs: [verify-web, e2e-web]
  if: ${{ needs.verify-web.result == 'success' && needs.e2e-web.result == 'success' }}

smoke-web:
  needs: deploy-web
  if: ${{ needs.deploy-web.result == 'success' }}
```

Use explicit `result == 'success'` checks for deploy gates. `if: success()` treats skipped upstream jobs as success when the lane was not affected, while `always() && (...)` belongs on final summary jobs.

## SST deploy action shape

For an SST-backed static or app surface, keep deploy and smoke separate:

```yaml
# .github/actions/deploy-surface/action.yml
inputs:
  payload-path: { required: true }
  role-to-assume: { required: true }
  aws-region: { required: true }
  role-session-name: { required: true }
  sst-config: { required: true }

runs:
  using: composite
  steps:
    - shell: bash
      env:
        PAYLOAD_PATH: ${{ inputs.payload-path }}
      run: test -d "$PAYLOAD_PATH"
    - uses: aws-actions/configure-aws-credentials@<full-sha> # v6.x.y
      with:
        role-to-assume: ${{ inputs.role-to-assume }}
        role-session-name: ${{ inputs.role-session-name }}
        aws-region: ${{ inputs.aws-region }}
    - shell: bash
      env:
        SST_CONFIG: ${{ inputs.sst-config }}
      run: vp exec -- sst --config "${SST_CONFIG}" deploy --stage production
```

- Prepare `payload-path` before calling the action. For a simple static surface this may be the same job's build output; for a versioned release it may be a checked, unpacked release asset.
- Pass `sst-config` explicitly per lane, for example `infra/web/sst.config.ts`.
- Disable dependency and build caches in the credential-bearing deploy setup unless the cache is scoped to trusted deploy events.
- Put smoke checks in a downstream job with only `contents: read`; assert cloud credentials are absent before Playwright or HTTP probes.
- Make `prod` and `staging` explicit SST stages/projects. Avoid one shared app/state with branch-dependent behavior unless state ownership and deletion boundaries are proven.
- When Cloudflare tokens are static, load them from the selected GitHub Environment and never from repository-level secrets.

## Composite-action shell safety

Never interpolate `${{ inputs.* }}` directly inside a `run:` block. Pass inputs through `env:` and let the shell quote normal variables:

```yaml
runs:
  using: composite
  steps:
    - shell: bash
      env:
        DIST_DIR: ${{ inputs.dist-dir }}
        PROJECT_NAME: ${{ inputs.project-name }}
      run: |
        wrangler pages deploy "$DIST_DIR" --project-name "$PROJECT_NAME"
```

`zizmor` catches this class of injection issue quickly; fix the shell shape instead of suppressing the finding.

## Bootstrap snippets

For a Vite+ workspace:

```yaml
- uses: voidzero-dev/setup-vp@<full-sha> # v1.x.y
  with:
    version: ${{ env.VITE_PLUS_VERSION }}
    node-version-file: .node-version
    cache: true
- run: vp env current
```

For a plain pnpm + Node workspace:

```yaml
- uses: actions/setup-node@<full-sha> # v6.x.y
  with:
    node-version-file: .node-version
    cache: pnpm
- uses: pnpm/action-setup@<full-sha> # v6.x.y
  with: { run_install: false }
- run: pnpm install --frozen-lockfile
```

For a container build (api/backend lane), push to the repo's chosen registry with the narrowest write token or OIDC-supported identity available:

```yaml
- uses: docker/setup-buildx-action@<full-sha> # v4.x.y
- uses: docker/login-action@<full-sha> # v4.x.y
  with:
    registry: ${{ vars.CONTAINER_REGISTRY }}
    username: ${{ vars.CONTAINER_REGISTRY_USER }}
    password: ${{ secrets.CONTAINER_REGISTRY_TOKEN }}
- uses: docker/build-push-action@<full-sha> # v7.x.y
  with:
    context: .
    push: true
    tags: |
      ${{ vars.CONTAINER_REGISTRY_IMAGE }}:${{ github.sha }}
      ${{ vars.CONTAINER_REGISTRY_IMAGE }}:main
    cache-from: type=gha
    cache-to:   type=gha,mode=max
```

Deploy jobs consume the resulting immutable image digest or commit-SHA tag. They do not rebuild the image.

## Step summary

End every deploy run with a `GITHUB_STEP_SUMMARY` block listing what shipped, which environment received it, where to inspect it, and which commit produced it. That summary is the human handoff during an incident, not the raw job log.

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
