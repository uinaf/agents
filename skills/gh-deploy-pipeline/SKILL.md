---
name: gh-deploy-pipeline
description: "Set up or align a GitHub Actions deploy pipeline for an app or service. Use when standardizing repos around the verify-then-deploy shape: push to main → detect affected lanes → verify and build artifacts → e2e → deploy each lane to its host (Cloudflare Pages, AWS Amplify, GHCR + VPS, etc.) with a non-cancellable per-lane concurrency group. Pairs with `gh-release-pipeline` for versioned packages; use for deploying running apps, not publishing artifacts to a registry."
---

# Deploy Pipeline

Push-to-main, lane-aware, artifact-driven. Detect what changed, build it once, run e2e against the built artifact, then deploy that same artifact per host. Frontends ship to a static host (Cloudflare Pages, AWS Amplify); backends ship a container image to GHCR and cut over on the VPS. The shape is identical across both.

## Pipeline Shape

```
push to main
  └─► detect-changes      (paths-filter or turbo --affected → per-lane outputs)
        └─► verify-<lane> (lint + typecheck + test + build → upload artifact)
              └─► e2e-<lane>    (download artifact, run e2e against it)
                    └─► deploy-<lane> (download artifact + load env → ship to host)
                          └─► smoke / health-check  (hit the deployed URL)
```

Each lane is independent: a web-only change builds and deploys only web, leaving api untouched. Verify, e2e, and deploy run cancellable concurrency groups; the deploy job uses a **non-cancellable** group per `(env, lane)` so two pushes never race the same target.

A separate `deploy.yml` (`workflow_dispatch`) lets a human re-deploy an existing artifact or image for a validated ref + lane — same composite actions, same concurrency group, no path detection.

## Workflow

1. Inspect the current repo first: existing `.github/workflows/*`, `.github/actions/*`, hosting scripts, infra files, and recent failing runs. If the org has a known-good sibling repo for the same host, read that workflow before choosing actions or inventing shell.
2. Confirm prerequisites: `main` is the deploy branch, the host (Cloudflare/Amplify/VPS) is reachable, and the secret store (1Password Connect, AWS OIDC, or repo secrets) is wired.
3. Pick the deploy target — [references/targets.md](references/targets.md) covers Cloudflare Pages, AWS Amplify, and GHCR + VPS (blue/green with Traefik). Each gets its own composite action under `.github/actions/<name>` so the workflow stays declarative. Prefer a working repo-local or sibling composite action over a fresh marketplace guess.
4. Author `.github/workflows/main.yml` and (optionally) `.github/workflows/deploy.yml` per [references/workflows.md](references/workflows.md). Keep the `changes → verify → e2e → deploy` topology; manual dispatch reuses verified artifacts/images.
5. Stand up change detection: `dorny/paths-filter@v4` for simple per-app rules, or a Turbo `--affected` walker for monorepos that need package-graph awareness. Output one boolean per deploy lane.
6. Wire env loading via [references/secrets.md](references/secrets.md) — 1Password Connect for application env, AWS OIDC for cloud creds, GHCR auto-token for image push. Keep secret values in the secret manager or environment store, referenced from workflow YAML.
7. Set deploy concurrency: cancellable for verify/e2e, **non-cancellable** for deploy. Group by `(env, lane)` so a web deploy does not block an api deploy, but two web deploys serialize.
8. Add a smoke step after deploy: hit the deployed URL or container health endpoint and fail the job if it is not 200. A green deploy that does not serve traffic is a failed deploy.
9. Validate end-to-end: PR (verify only, no deploy) → merge a change touching one lane → watch detect → verify → e2e → deploy → smoke → publish summary. Confirm only the touched lane ran.
10. Cross-check [references/troubleshooting.md](references/troubleshooting.md) when a deploy is stuck, racing, or shipping the wrong artifact.

## Examples

Load detailed workflow snippets from [references/workflows.md](references/workflows.md) only after the target lanes and host are known; load [references/targets.md](references/targets.md) only for the selected host.

Minimal deploy anchor:

```yaml
deploy-web:
  needs: [verify-web, e2e-web]
  if: ${{ needs.verify-web.result == 'success' && needs.e2e-web.result == 'success' }}
  concurrency: { group: deploy-production-web, cancel-in-progress: false }
  steps:
    - uses: actions/download-artifact@v8
      with: { name: web-dist, path: apps/web/dist }
    - run: curl -fsS https://web.example.com/healthz
```

## Guardrails

- One artifact end-to-end: e2e and deploy both consume the artifact verify uploaded.
- Repo precedent beats generic advice. If a sibling repo already deploys to the same host successfully, preserve that workflow/action shape unless you can point to a concrete mismatch.
- Deploy concurrency is non-cancellable per `(env, lane)` and shared between `main.yml` and `deploy.yml`.
- A deploy job is not green until its smoke step has hit the deployed URL.
- Secret-bearing deploy jobs must validate any manual input before checkout or secret loading, and must deploy a previously built artifact or image with known provenance rather than rebuilding an arbitrary input ref.
