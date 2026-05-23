# GitHub Actions Pipeline for a Two-App Monorepo

## Problem/Feature Description

A platform team runs a monorepo that contains two deployable apps: `apps/dashboard` (a TypeScript React frontend) and `apps/api` (a Node.js Express backend). Both apps share a `packages/` directory of internal libraries and a root `pnpm-lock.yaml`.

The team has two pressing problems. First, every push to `main` triggers a full rebuild and redeploy of both apps even when only one of them changed. This doubles CI time and has caused accidental rollbacks when a clean deploy of one app brought along stale code from the other. Second, when engineers push rapid fixes to `main` during incidents, deploys sometimes race each other and the wrong artifact ends up on the host. At the same time, they need a way for an on-call engineer to manually re-deploy a verified artifact or image for a specific app and validated git ref without re-running all the tests.

Design and write the GitHub Actions workflows that solve both problems. The frontend lane promotes a verified static build artifact to the `production` GitHub Environment. The API lane promotes an immutable image reference to the same `production` Environment. The deploy provider supports OIDC, so the deploy jobs must use `id-token: write` and environment-scoped role/config variables instead of long-lived repository secrets.

## Output Specification

Produce the following files:
- `.github/workflows/main.yml` — push-to-main pipeline with lane-aware detection, verify, e2e, and deploy stages for both apps
- `.github/workflows/deploy.yml` — manual re-deploy workflow (workflow_dispatch) for re-deploying a verified artifact or image for a chosen lane and validated ref
- `.github/workflows/verify.yml` — pull request verification workflow (no deployment)
- `pipeline-design.md` — a brief explanation of how change detection works, how rapid pushes are handled, how environment credentials are scoped, and how the manual re-deploy relates to the main pipeline's concurrency
