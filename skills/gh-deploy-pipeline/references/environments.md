# Environments

Use this reference when wiring deploy credentials, target selection, and manual promotion. The skill intentionally avoids provider cookbooks. Keep platform-specific deployment logic in repo-owned scripts, SST, or infrastructure code, and keep the GitHub Actions contract small.

## Environment Contract

Every deploy lane declares a GitHub Environment:

```yaml
deploy-web:
  environment:
    name: production
    url: ${{ steps.smoke.outputs.url }}
  concurrency:
    group: deploy-production-web
    cancel-in-progress: false
```

- Use one environment per blast radius: `staging`, `production`, `preview`, or a repo-specific equivalent.
- Put production-only secrets and variables on the Environment, not at repository scope.
- Use Environment protection rules when humans must approve production promotion.
- Do not rely on Environment branch policies as the only trust boundary. If a job checks out a manual `inputs.ref`, validate that ref separately before checkout or credential loading.

## Identity

Prefer short-lived identity over static tokens:

```yaml
permissions:
  contents: read
  id-token: write

steps:
  - name: Assume deploy identity
    run: ./scripts/ci/assume-deploy-identity --environment production
```

- Use OIDC or provider federation when the provider supports it.
- Scope the provider trust policy to the repository, environment, branch or protected tag, and intended audience.
- Use separate identities for staging and production.
- Static provider tokens are a fallback, not the default. If required, store them on the GitHub Environment and document why OIDC is not available.

## SST

SST is a good deploy layer when the repo owns both app code and infrastructure. Treat it as the provider-thin promotion step, not as a reason to weaken the workflow boundary:

```yaml
- run: pnpm sst deploy --stage production
```

- Run SST after the GitHub Environment is selected and OIDC/provider identity is available.
- Map SST stages to GitHub Environments (`staging`, `production`, preview names) so secrets and approvals stay visible in GitHub.
- Keep runtime secrets in SST/provider secret stores or GitHub Environment secrets; do not pass them as CLI flags.
- Prefer deploying the already verified build artifact or immutable image. If SST must build internally, document why the artifact pass-through rule does not fit and add an equivalent build provenance check.
- Disable dependency/build caches in the credential-bearing SST deploy path unless the cache is scoped to the same trusted event class.
- Smoke the deployed endpoint from a separate read-only job after `sst deploy`; the deploy command succeeding is not enough proof.
- Add an assertion in the smoke job that cloud credential variables are absent before running browser or HTTP checks.

## Artifact Promotion

Deploy jobs promote an artifact or immutable image produced by verify:

```yaml
- uses: actions/download-artifact@<full-sha> # v8.x.y
  with:
    name: web-dist
    path: apps/web/dist

- run: ./scripts/deploy-web --artifact apps/web/dist --environment production
```

- Do not rebuild in the deploy job.
- Use immutable image digests or commit-SHA tags for containers; mutable tags are browsing hints only.
- If a manual deploy promotes an older artifact or image, record source commit, producing workflow run, artifact name, and digest or checksum.
- Verify artifact existence before loading deploy credentials.

## Secrets

Separate three layers:

- CI identity: OIDC role names, provider audience, or a bootstrap token when federation is unavailable.
- Deploy configuration: non-sensitive identifiers such as account IDs, project IDs, regions, service names, and URLs.
- Runtime secrets: database URLs, API keys, signing keys, and internal service tokens.

Rules:

- Keep non-sensitive identifiers in Environment vars.
- Keep production runtime secrets in the provider secret store or GitHub Environment secrets, never in workflow YAML.
- Pass secret values via env vars or stdin, not command-line flags.
- Never print rendered env files or provider token responses.

## Manual Deploys

Manual `workflow_dispatch` deploys are promotion paths, not build paths:

```yaml
on:
  workflow_dispatch:
    inputs:
      ref: { type: string, required: true }
      environment: { type: choice, options: [staging, production], required: true }
      lane: { type: choice, options: [web, api], required: true }
```

- Validate `inputs.ref`, `inputs.environment`, and `inputs.lane` in a secretless job.
- Allow `main`, protected release tags, or exact SHAs with an existing verified artifact/image.
- Emit sanitized outputs and use only those outputs downstream.
- Use the same deploy concurrency key as `main.yml`.
- Load credentials only after validation and artifact provenance checks pass.
