# Workflows

Conventions for deploy workflow files. The common shape uses `main.yml`, `verify.yml`, and `deploy.yml`; add preview-specific workflows only when PR-driven preview deploys need their own lifecycle.

Start by reading the repo's existing workflow/action files and any same-org repo that deploys to the same host. Preserve proven composite actions, token names, and deploy scripts when the target matches. Marketplace examples are fallback material, not the first source of truth.

## File layout

```
.github/
├── workflows/
│   ├── main.yml      # push to main → detect → verify → e2e → deploy → summary
│   ├── deploy.yml    # workflow_dispatch -> re-deploy a verified payload ref
│   └── verify.yml    # pull_request + merge_group → verify only (no deploy)
└── actions/
    ├── setup-workspace/        # one place to bootstrap (Node, pnpm/vite+, cache)
    ├── assume-deploy-identity/ # optional OIDC/provider federation wrapper
    └── deploy-<lane>/          # repo-owned provider-thin deploy primitive, often SST
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

jobs:
  verify:
    # Event types select PR activities; they do not exclude draft PRs.
    if: github.event_name != 'pull_request' || github.event.pull_request.draft == false
    # ...

# deploy.yml
on:
  workflow_dispatch:
    inputs:
      ref:         { type: string, required: true, description: "Verified git ref or SHA to promote" }
      environment: { type: choice, options: [staging, production], required: true }
      lane:        { type: choice, options: [web, api], required: true }
```

- `merge_group:` covers the GitHub merge queue. Without it the queue blocks PRs that depend on green checks from this workflow.
- Pull-request activity types do not filter by draft state: `opened`, `synchronize`, and `reopened` can still fire for draft PRs. Gate each PR entry job, or a shared root job and all of its dependents, on `github.event.pull_request.draft == false`; keep `ready_for_review` so verification starts when the PR becomes ready.
- Do **not** add `push:` to `verify.yml` — the verify gate runs inside `main.yml` for push events.
- Secret-bearing manual deploys validate `inputs.ref`, `inputs.environment`, and `inputs.lane` in a secretless step before checkout or secret loading. Prefer `main`, protected release tags, or exact SHAs with a matching durable payload.
- Environment branch/tag rules constrain the workflow run ref; validate any separately checked-out `inputs.ref` as its own trust boundary.
- Manual redeploys consume an existing release asset, package version, provider package, or image by immutable digest/SHA in the secret-bearing job.
- Avoid arbitrary ref inputs when a standard selector will do. Prefer a release tag, package version, image digest, artifact/run id, or `environment`/`lane` choice input over accepting free-form branch names.
- When free-form refs are unavoidable, validate them through a maintained action or a small repo-owned action/script with tests. Keep the workflow YAML as the call site, not the validator implementation.
- Do not use `pull_request_target` for any workflow that checks out, installs, builds, tests, packages, deploys, or otherwise executes project code. Keep fork and outsider code on `pull_request` with read-only credentials and no deploy secrets.

## Keep Workflow Logic Boring

Do not add inline shell or JavaScript blocks to satisfy a scanner. Use standard actions first; use repo-owned actions or scripts only when the repo has a real product-specific boundary.

- Standard checks: use `actionlint`, `zizmor`, secret scanners, CodeQL, and dependency scanners instead of bespoke grep/awk/YAML parsers.
- Change detection: use `dorny/paths-filter`, GitHub path filters, or the repo's existing monorepo tool entrypoint.
- Auth and cloud setup: use maintained setup/auth actions such as `aws-actions/configure-aws-credentials`, `docker/login-action`, or provider-owned OIDC actions.
- Complex validation: put it in `.github/actions/<name>` or `scripts/ci/<name>` with a narrow contract and tests; call it from YAML with inputs and outputs.
- Inline `run:` is fine for simple commands like `make verify`, `vp test`, `docker buildx imagetools inspect`, or calling a repo-owned script. It is not fine for multi-branch policy logic, hand-rolled ref parsing, secret scanning, or YAML analysis.

## Standard hardening gates

Run standard scanners before adding repo-specific workflow guard scripts:

```yaml
workflow-hardening:
  runs-on: ubuntu-latest
  permissions:
    contents: read
  steps:
    - uses: actions/checkout@<full-sha> # v6.0.2
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
- Prefer not to expose this workflow at all when a preview environment, release asset, image digest, or provider-native deploy id can be selected instead.

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
      environment: ${{ steps.resolve.outputs.environment }}
    steps:
      - uses: actions/checkout@<full-sha> # v6.0.2
        with:
          fetch-depth: 0
      - id: resolve
        uses: ./.github/actions/resolve-deploy-ref
        with:
          ref: ${{ inputs.ref }}
          environment: ${{ inputs.environment }}
          default-branch: ${{ github.event.repository.default_branch }}
```

The local action should be small and covered by tests. If the repo does not already own that action or script, prefer a safer input model instead of pasting ref-parsing shell into the workflow.

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

## Pipeline optimization

Optimize for short, predictable feedback without weakening the deploy contract.

- Do not use trigger-level `paths` or `paths-ignore` on workflows whose checks are required by branch protection. Keep the workflow scheduled, detect affected lanes inside it, and let a stable result job report success for docs-only or no-op changes.
- Add explicit `timeout-minutes` on every non-trivial job. Start conservative: `10-15` for lint/typecheck, `20-30` for builds, `30-45` for e2e, and the smallest proven window for deploy.
- Use matrix `fail-fast: false` when full lane/browser/platform evidence matters. Use `max-parallel` when external capacity is constrained by browser grids, preview environments, device farms, or provider rate limits.
- Required workflows with conditional lanes should end in a stable `delivery-result` or `verify-result` job that uses `always()` plus explicit `needs.*.result` checks. Make branch protection require that stable job, not every conditional lane.
- A no-op result is valid only when the changes job proves no relevant lane changed. The summary should say which paths forced a full run and which paths made it a no-op.
- If a repo both releases an artifact and deploys an app, do not build from source twice. Release produces the immutable package, image digest, release asset, or provider artifact; deploy consumes that ref.

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
- Monitoring, incident, and notification jobs are read-only and should not receive OIDC or deploy-provider credentials.

## Checkout

```yaml
- uses: actions/checkout@<full-sha> # v6.0.2
  with:
    fetch-depth: 0      # required for paths-filter and turbo --affected
    persist-credentials: false  # add write credentials only at the exact push step, if one exists
```

`fetch-depth: 0` is non-negotiable for the `changes` job. Without git history, `paths-filter` cannot diff against the previous commit and `turbo run --affected` cannot resolve the merge base.

Keep checkout credentials unpersisted through install, build, e2e, package, and deploy setup. If a workflow truly must push a tag, comment, release note, or version bump, configure the narrow write token immediately before that step and do not expose it to dependency install or project-code execution.

## Change detection

Two patterns; pick by repo shape.

### `dorny/paths-filter` (per-app rules, simple repos)

```yaml
- id: filter
  uses: dorny/paths-filter@<full-sha> # v4.0.1
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
  run: pnpm exec repo-detect-affected --format=github-output
```

Turbo follows the `dependsOn` graph; it catches transitive changes that a flat path-filter misses. Keep the JSON parsing and package-to-lane mapping inside a repo-owned CLI/script instead of inlining `jq` and `grep` in the workflow. Pair it with a "force lanes if these CI/hosting paths changed" rule (e.g. `.github/workflows/**`, `Dockerfile`, `infrastructure/**`) so a CI-only change still runs the full lane.

## Payload pass-through

The same deploy payload must flow `verify -> e2e -> deploy`. Prefer the most durable payload boundary the repo already owns: a container image digest, package/release asset, provider-native deployment package, or same-job filesystem handoff for simple static deploys.

Do not reflexively add `actions/upload-artifact` / `actions/download-artifact` between build and deploy. GitHub Actions artifacts are quota- and retention-coupled CI storage. They are acceptable only as same-run scratch handoff when quota/retention are understood, but they are a weak default for production deploy or release promotion when a registry, GitHub Release asset, image digest, or provider-native package exists.

For a simple static app where build, e2e, and deploy can safely share one trusted job, keep the payload on disk and deploy after tests. Preserve security by loading deploy credentials only in the environment-scoped job. Do not add a separate curl-style smoke job unless the repo already owns meaningful synthetic checks.

Treat Actions artifacts as an exception, not the recipe. If a repo truly has no durable payload store and accepts same-run quota/retention coupling, document that tradeoff beside the workflow and keep artifact names unique per lane. Otherwise choose one of these shapes:

- Same-job static handoff: build the static payload, run e2e against that local output, deploy from the same runner filesystem, then link monitoring, alerts, and rollback instructions in the deploy summary.
- Release/registry handoff: publish the verified payload to a GitHub Release, package registry, provider package, or image registry, output its immutable ref, and have deploy consume that ref.
- Provider-native handoff: ask the hosting provider to create a deployment package or deployment id, then promote that id through the environment.

When same-run Actions artifacts are the accepted exception:

- Use `actions/upload-artifact` with `if-no-files-found: error`.
- Set `retention-days: 1`, `2`, or `3`; do not keep deployment scratch artifacts for weeks.
- Name artifacts with lane, platform, and source SHA or run id.
- Capture the artifact digest output and include it in the deploy summary or payload metadata.
- Avoid `include-hidden-files: true` unless the repo has explicitly audited hidden files for secrets.

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

deploy-summary:
  needs: deploy-web
  if: ${{ always() && needs.deploy-web.result == 'success' }}
```

Use explicit `result == 'success'` checks for deploy gates. `if: success()` treats skipped upstream jobs as success when the lane was not affected, while `always() && (...)` belongs on final summary jobs.

## SST deploy action shape

For an SST-backed static or app surface, keep deploy provider-thin and let monitoring prove runtime health. The workflow should call a repo-owned deploy action or script; it should not inline provider command wiring:

```yaml
- uses: ./.github/actions/deploy-surface
  with:
    payload-path: ${{ needs.e2e-web.outputs.payload_path }}
    role-to-assume: ${{ vars.AWS_DEPLOY_ROLE_ARN }}
    aws-region: ${{ vars.AWS_REGION }}
    role-session-name: deploy-web-${{ github.run_id }}
    sst-config: infra/web/sst.config.ts
```

- Prepare `payload-path` before calling the action. For a simple static surface this may be the same job's build output; for a versioned release it may be a checked, unpacked release asset.
- Pass `sst-config` explicitly per lane, for example `infra/web/sst.config.ts`.
- Inside the local action, prefer maintained auth/setup actions such as `aws-actions/configure-aws-credentials`; keep shell to direct repo commands such as `vp exec -- sst ...`.
- Disable dependency and build caches in the credential-bearing deploy setup unless the cache is scoped to trusted deploy events.
- Put monitoring links, alert runbooks, release markers, and rollback pointers in the deploy summary. If the repo already has real synthetic checks, trigger or link them from a read-only follow-up job; do not create a shallow HTTP smoke job as a substitute for monitoring.
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
      run: wrangler pages deploy "$DIST_DIR" --project-name "$PROJECT_NAME"
```

`zizmor` catches this class of injection issue quickly; fix the shell shape instead of suppressing the finding.

## Bootstrap snippets

For Node deploy workflows, check in `.node-version` with the latest active LTS line, currently Node 24.x. Use `.node-version` consistently across local setup and CI.

For a workspace using the Vite+ toolchain:

```yaml
- uses: voidzero-dev/setup-vp@<full-sha> # v1.10.0
  with:
    version: ${{ env.VITE_PLUS_VERSION }}
    node-version-file: .node-version
    cache: true
- run: vp env current
```

For a plain pnpm + Node workspace:

```yaml
- uses: pnpm/action-setup@<full-sha> # v6.0.8
  with: { run_install: false }
- uses: actions/setup-node@<full-sha> # v6.4.0
  with:
    node-version-file: .node-version
    cache: pnpm
- run: pnpm install --frozen-lockfile
```

Install pnpm before asking `setup-node` to cache its store; the cache integration invokes the selected package manager to discover that store.

For a container build (api/backend lane), push to the repo's chosen registry with the narrowest write token or OIDC-supported identity available:

```yaml
- uses: docker/setup-buildx-action@<full-sha> # v4.1.0
- uses: docker/login-action@<full-sha> # v4.2.0
  with:
    registry: ${{ vars.CONTAINER_REGISTRY }}
    username: ${{ vars.CONTAINER_REGISTRY_USER }}
    password: ${{ secrets.CONTAINER_REGISTRY_TOKEN }}
- uses: docker/build-push-action@<full-sha> # v7.2.0
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

## Monitoring handoff and summary

End every deploy run with a summary listing what shipped, which environment received it, where to inspect telemetry, which alerts or synthetic checks cover it, how to roll back, and which commit produced it. That summary is the human handoff during an incident, not the raw job log.

```yaml
- run: scripts/ci/write-deploy-summary
  env:
    DEPLOY_ENVIRONMENT: production
    DEPLOY_COMMIT: ${{ github.sha }}
    WEB_RESULT: ${{ needs.deploy-web.result }}
    API_RESULT: ${{ needs.deploy-api.result }}
    MONITORING_URL: ${{ vars.PRODUCTION_MONITORING_URL }}
    ROLLBACK_RUNBOOK_URL: ${{ vars.PRODUCTION_ROLLBACK_RUNBOOK_URL }}
```

Keep formatting in a repo-owned script or local action once it is more than a couple of lines. Do not let incident handoff formatting turn into a large inline YAML block.
