---
name: gh-deploy-pipeline
description: "Set up or align a GitHub Actions deploy pipeline for a running app or service. Use when standardizing repos around the verify-then-deploy shape: push to main -> detect affected lanes -> verify and build artifacts -> e2e -> deploy each lane through a GitHub Environment using OIDC or environment-scoped credentials, with non-cancellable per-environment deploy concurrency. Pairs with `gh-release-pipeline` for versioned packages; use for deploying running apps, not publishing artifacts to a registry."
---

# Deploy Pipeline

Push-to-main, lane-aware, artifact-driven. Detect what changed, build it once, run e2e against the built artifact, then promote that same artifact through a GitHub Environment. Deployment specifics belong in the target platform or infrastructure repo; this skill owns the workflow contract, trust boundaries, and verification loop.

## Pipeline Shape

```text
push to main
  -> detect-changes       (paths-filter or graph-aware affected detection)
  -> verify-<lane>        (lint + typecheck + test + build -> upload artifact)
  -> e2e-<lane>           (download artifact, run e2e against it)
  -> deploy-<env>-<lane>  (environment-scoped credentials + OIDC -> promote artifact)
  -> smoke-<env>-<lane>   (read-only job, no deploy credentials -> hit deployed URL)
```

Each lane is independent: a web-only change builds and deploys only web, leaving api untouched. Verify and e2e jobs may cancel superseded runs; deploy jobs use a non-cancellable concurrency group per `(environment, lane)` so two pushes never race the same target.

A separate `deploy.yml` (`workflow_dispatch`) may re-deploy an existing artifact or image for a validated ref, environment, and lane. It reuses the same environment, concurrency group, and provenance checks; it does not rebuild arbitrary input code.

## Workflow

1. Inspect the repo first: existing `.github/workflows/*`, environment names, deploy scripts, infra entrypoints, release dashboards, and recent failing runs. Preserve a proven workflow contract only when it already uses environment gates, OIDC or scoped credentials, immutable artifacts, and post-deploy proof.
2. Confirm prerequisites: deploy branch, target environments, environment protection rules, OIDC trust policy or scoped environment credentials, artifact/image retention, and smoke endpoint.
3. Author `.github/workflows/main.yml` and optionally `.github/workflows/deploy.yml` per [references/workflows.md](references/workflows.md). Keep `changes -> verify -> e2e -> deploy -> smoke`; manual dispatch promotes existing verified artifacts/images.
4. Stand up change detection: `dorny/paths-filter` pinned to a full SHA for simple per-app rules, or a graph-aware affected walker for monorepos. Output one boolean per deploy lane.
5. Wire trust boundaries via [references/environments.md](references/environments.md) and [references/secrets.md](references/secrets.md): GitHub Environments hold deploy-scoped secrets/vars, OIDC handles cloud identity where available, and repo-level secrets remain bootstrap-only.
6. Keep deploy steps provider-thin. Prefer a repo-owned deploy layer such as SST, an IaC apply, release-environment promotion API, or small platform CLI wrapper only after credentials are loaded for the environment and the artifact provenance is checked.
7. Set concurrency: cancellable for verify/e2e, non-cancellable for deploy. Group by `(environment, lane)` so a staging web deploy does not block production web, but two production web deploys serialize.
8. Add a separate smoke job after deploy: hit the environment URL or health endpoint without cloud/deploy credentials and fail if it is not healthy. A green deploy that does not serve traffic is a failed deploy.
9. Validate end-to-end: PR (verify only, no deploy) -> merge a lane-scoped change -> watch detect -> verify -> e2e -> deploy -> smoke -> summary. Confirm only the touched lane and intended environment ran.
10. Cross-check [references/troubleshooting.md](references/troubleshooting.md) when a deploy is stuck, racing, or shipping the wrong artifact.

## Minimal Anchor

```yaml
deploy-web:
  needs: [verify-web, e2e-web]
  if: ${{ needs.verify-web.result == 'success' && needs.e2e-web.result == 'success' }}
  environment:
    name: production
    url: ${{ steps.smoke.outputs.url }}
  concurrency:
    group: deploy-production-web
    cancel-in-progress: false
  permissions:
    contents: read
    id-token: write
  env:
    AWS_DEPLOY_ROLE_ARN: ${{ vars.AWS_DEPLOY_ROLE_ARN }}
    AWS_REGION: ${{ vars.AWS_REGION }}
  steps:
    - uses: actions/download-artifact@<full-sha> # v8.x.y
      with: { name: web-dist, path: apps/web/dist }
    - run: vp exec -- sst --config infra/web/sst.config.ts deploy --stage production

smoke-web:
  needs: deploy-web
  if: ${{ needs.deploy-web.result == 'success' }}
  runs-on: ubuntu-latest
  permissions:
    contents: read
  steps:
    - run: ./scripts/assert-no-cloud-credentials
    - run: ./scripts/smoke-web --environment production
```

## Guardrails

- One artifact end-to-end: e2e and deploy both consume the artifact verify uploaded.
- Deploy credentials are environment-scoped. Prefer OIDC or short-lived federation; use static tokens only when the provider has no supported federation path.
- SST is a good default when the repo already uses it or wants app-owned infrastructure. Run it as the deploy layer behind the same Environment, OIDC, artifact provenance, concurrency, and separate no-credential smoke rules.
- Repo-level secrets are bootstrap-only. Runtime and production deploy secrets live on GitHub Environments or the provider's secret system.
- Deploy concurrency is non-cancellable per `(environment, lane)` and shared between `main.yml` and `deploy.yml`.
- A deploy pipeline is not green until a separate read-only smoke job has hit the deployed environment.
- Secret-bearing manual deploy jobs validate inputs before checkout or credential loading, then deploy a previously built artifact or immutable image with known provenance.
