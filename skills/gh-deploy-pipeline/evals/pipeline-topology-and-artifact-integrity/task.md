# Reliable GitHub Actions Deploy Pipeline for a React SPA

## Problem/Feature Description

A product team runs a React SPA (built with Vite) that is currently deployed by hand: a developer runs `npm run build` locally and uploads the `dist/` folder through the provider dashboard. This works when there is only one developer, but the team has grown to seven engineers and two of them broke production last week by shipping untested local builds. The team wants a GitHub Actions pipeline that enforces the rule "what was tested is exactly what gets deployed" — no exceptions.

The pipeline should build the app once, run end-to-end tests against that exact build output, and only then promote it through the `production` GitHub Environment using the provider's OIDC-backed deploy identity. If the build produces no output (which happened silently twice this month due to a misconfigured Vite output path), the pipeline must catch it immediately. The app uses a Vite-based framework with a non-standard output structure. After every successful deployment, on-call engineers must be able to confirm that the live site is serving traffic correctly — right now there is no automated check and the team only finds out about broken deploys from user reports.

## Output Specification

Produce a working GitHub Actions workflow at `.github/workflows/main.yml` that triggers on push to `main` and implements the full build -> test -> deploy flow described above. Use a repo-owned provider-thin deploy script or local action that accepts artifact path and environment; do not write a provider cookbook.

The deploy job must declare the `production` GitHub Environment, use `id-token: write`, and keep provider identifiers in environment vars rather than hardcoded workflow values.

Include a brief `deploy-summary.md` file explaining the pipeline shape you chose — what runs in each job, what gets passed between jobs, what identity boundary the deploy uses, and why.
