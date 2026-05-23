---
name: gh-deploy-pipeline
description: "Set up or align a GitHub Actions deploy pipeline for a running app or service. Use when standardizing repos around the verify-then-deploy shape: push to main -> detect affected lanes -> verify and build an immutable deploy payload -> e2e -> deploy each lane through a GitHub Environment using OIDC or environment-scoped credentials, with non-cancellable per-environment deploy concurrency. Pairs with `gh-release-pipeline` for versioned packages; use for deploying running apps, not publishing versioned packages."
---

# Deploy Pipeline

Push-to-main, lane-aware, immutable-payload driven. Detect what changed, build it once, run e2e against the built payload, then deploy that same payload through a GitHub Environment. Deployment specifics belong in the target platform or infrastructure repo; this skill owns the workflow contract, trust boundaries, and verification loop.

## Pipeline Shape

```text
push to main
  -> detect-changes       (paths-filter or graph-aware affected detection)
  -> verify-<lane>        (lint + typecheck + test + build deployable payload)
  -> e2e-<lane>           (run e2e against that payload)
  -> deploy-<env>-<lane>  (environment-scoped credentials + OIDC -> deploy same payload)
  -> smoke-<env>-<lane>   (read-only job, no deploy credentials -> hit deployed URL)
```

Each lane is independent: a web-only change builds and deploys only web, leaving api untouched. Verify and e2e jobs may cancel superseded runs; deploy jobs use a non-cancellable concurrency group per `(environment, lane)` so two pushes never race the same target.

A separate `deploy.yml` (`workflow_dispatch`) may re-deploy an existing payload reference for a validated ref, environment, and lane: a release asset, image digest, package version, provider-native package, or other durable immutable payload. It reuses the same environment, concurrency group, and provenance checks; it does not rebuild arbitrary input code.

## Workflow

1. Inspect the repo first: existing `.github/workflows/*`, environment names, deploy scripts, infra entrypoints, release dashboards, and recent failing runs. Preserve a proven workflow contract only when it already uses environment gates, OIDC or scoped credentials, immutable payloads, and post-deploy proof.
2. Confirm prerequisites: deploy branch, default-branch merge policy, target environments, environment protection rules, OIDC trust policy or scoped environment credentials, payload retention, and smoke endpoint.
3. Identify tooling version sources before writing job steps. Node should come from `.node-version`/`.nvmrc`/`.tool-versions`; package managers from `package.json#packageManager`; Vite+ from `package.json` or the workspace catalog. Workflows should read those owners rather than duplicating Node, pnpm, or Vite+ versions in each job.
4. Author `.github/workflows/main.yml` and optionally `.github/workflows/deploy.yml` per [references/workflows.md](references/workflows.md). Keep `changes -> verify -> e2e -> deploy -> smoke`; manual dispatch promotes an existing verified payload reference.
5. Add the standard hardening stack before inventing bespoke checks: `actionlint` for syntax, `zizmor` for GitHub Actions security, and scanner-backed gates for secret/security checks. See [references/workflows.md](references/workflows.md).
6. Stand up change detection: `dorny/paths-filter` pinned to a full SHA for simple per-app rules, or a graph-aware affected walker for monorepos. Output one boolean per deploy lane.
7. Wire trust boundaries via [references/environments.md](references/environments.md) and [references/secrets.md](references/secrets.md): GitHub Environments hold deploy-scoped secrets/vars, OIDC handles cloud identity where available, and repo-level secrets remain bootstrap-only.
8. Keep deploy steps provider-thin. Prefer a repo-owned deploy layer such as SST, an IaC apply, release-environment promotion API, or small platform CLI wrapper only after credentials are loaded for the environment and payload provenance is checked.
9. Set concurrency: cancellable for verify/e2e, non-cancellable for deploy. Group by `(environment, lane)` so a staging web deploy does not block production web, but two production web deploys serialize.
10. Add a separate smoke job after deploy: hit the environment URL or health endpoint without cloud/deploy credentials and fail if it is not healthy. A green deploy that does not serve traffic is a failed deploy.
11. Validate end-to-end: PR (verify only, no deploy) -> merge a lane-scoped change -> watch detect -> verify -> e2e -> deploy -> smoke -> summary. Confirm only the touched lane and intended environment ran.
12. Cross-check [references/troubleshooting.md](references/troubleshooting.md) when a deploy is stuck, racing, or shipping the wrong payload.

## Hardening Stack

- Run `actionlint` for workflow syntax and expression mistakes.
- Run `zizmor` for GitHub Actions security before writing custom grep, awk, or TypeScript workflow validators.
- Prefer scanner-backed gates (`zizmor`, `actionlint`, gitleaks, TruffleHog, CodeQL, dependency scanners) over repo-specific guard scripts unless a scanner cannot express the risk.
- Pin `zizmorcore/zizmor-action` by full SHA with a same-line version comment. Example: `zizmorcore/zizmor-action@5f14fd08f7cf1cb1609c1e344975f152c7ee938d # v0.5.6`.
- For repos without GitHub Advanced Security, set `advanced-security: false`, `annotations: true`, and block on at least `min-severity: medium` plus `min-confidence: medium`.

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
    VERIFIED_PAYLOAD_REF: ${{ needs.verify-web.outputs.payload-ref }}
  steps:
    - run: ./scripts/prepare-deploy-payload --ref "$VERIFIED_PAYLOAD_REF" --out apps/web/dist
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

- One payload end-to-end: e2e and deploy both consume the same verified build output, immutable image digest, release asset, or provider-native deployment package.
- Do not default to GitHub Actions artifacts as a durable deploy handoff. They are quota/retention-coupled CI storage, not a release registry. Use them only for same-run handoff when their retention and quota are acceptable, or when no better immutable payload store exists.
- For static sites that build/test/deploy in one trusted job, deploy from the runner filesystem after tests and keep smoke as a separate read-only job. For versioned releases, deploy from the published release asset, package registry, image digest, or provider-native package instead of re-uploading that payload as a GitHub Actions artifact.
- Keep toolchain versions single-sourced. Use `node-version-file`, package-manager metadata, and structured reads such as `jq` for package metadata instead of hardcoded workflow literals. GitHub Action SHA pins and their same-line version comments are separate from the project toolchain and should remain explicit.
- Default branch merge policy is part of the deploy surface. If direct pushes to `main` must remain allowed, prefer branch protection with only `required_conversation_resolution` enabled. Use organization or repository rulesets for conversation resolution only when making default-branch changes go through pull requests is intended. Preserve existing approvals, status checks, signed-commit, and actor restrictions when changing branch policy.
- Deploy credentials are environment-scoped. Prefer OIDC or short-lived federation; use static tokens only when the provider has no supported federation path.
- SST is a good default when the repo already uses it or wants app-owned infrastructure. Run it as the deploy layer behind the same Environment, OIDC, payload provenance, concurrency, and separate no-credential smoke rules.
- For Cloudflare/SST deployments with static Cloudflare tokens, keep tokens on the GitHub Environment and split `staging` and `production` stages/projects/state so one deploy path cannot delete or mutate the other environment's resources.
- Repo-level secrets are bootstrap-only. Runtime and production deploy secrets live on GitHub Environments or the provider's secret system.
- Deploy concurrency is non-cancellable per `(environment, lane)` and shared between `main.yml` and `deploy.yml`.
- A deploy pipeline is not green until a separate read-only smoke job has hit the deployed environment.
- Secret-bearing manual deploy jobs validate inputs before checkout or credential loading, then deploy a previously built payload with known provenance.
