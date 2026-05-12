# Secure Secrets and Credentials Wiring for a GitHub Actions Deploy Pipeline

## Problem/Feature Description

A platform team is migrating a Node.js API service from manual dashboard deployments to GitHub Actions. The service connects to a PostgreSQL database, calls the Stripe API, and uses several internal service tokens. A previous attempt to automate the deployment stored these connection strings and API keys directly in GitHub repository secrets and passed them to the deploy command via workflow YAML. A security audit flagged this setup: secrets were visible in workflow logs, rotation required updating multiple repositories manually, and there was no clear separation between the credentials the CI system needs to operate and the credentials the running application needs.

The deploy provider supports OIDC federation for CI identity. The application's runtime secret store already contains all runtime credentials under reference paths such as `secret://production/api/DATABASE_URL`. The goal is to redesign the secrets and credentials wiring so that long-lived deploy credentials are eliminated from repository secrets, runtime application secrets stay in the runtime secret store or production GitHub Environment, and nothing sensitive appears in logs or workflow YAML.

## Output Specification

Produce the following files:
- `.github/workflows/main.yml` — the push-to-main deploy workflow with correct permissions, OIDC auth, environment-scoped secret loading, and a separate read-only smoke job
- `deploy/production.env.example` — the committed env template file with secret-store references (use plausible but fictional `secret://` paths)
- `secrets-design.md` — an explanation of what each credential category is, where it lives, and why, including what goes in GitHub Environments, provider identity, runtime secret stores, and `vars.*`

Do not include any real credentials or tokens in the files. The smoke job must not receive deploy-provider credentials and should fail if provider credential env vars are present.
