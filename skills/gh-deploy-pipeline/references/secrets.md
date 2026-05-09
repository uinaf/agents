# Secrets and Environment

Three layers of secrets show up in a deploy pipeline: **CI access** (cloud creds, registry tokens), **runtime env** (DB URLs, third-party keys baked into the deployed app), and **bot identity** (PATs that push to other repos or pull cross-repo images). Each layer has a single right answer.

## CI access — prefer OIDC

Whenever the cloud provider supports it, use GitHub's OIDC token instead of long-lived secrets.

### AWS

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v6
    with:
      role-to-assume: arn:aws:iam::123456789012:role/GhActionsDeploy
      aws-region:     us-east-1
```

Trust policy on the IAM role:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com" },
    "Action":    "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals":   { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
      "StringLike":     { "token.actions.githubusercontent.com:sub": "repo:<org>/<repo>:ref:refs/heads/main" }
    }
  }]
}
```

- One role per blast radius: `GhActionsDeploy-Production` (sub: `refs/heads/main`), `GhActionsDeploy-Preview` (sub: `pull_request`).
- Permissions on the role: only what the deploy needs (`amplify:*` on the specific app ARN, S3 `PutObject` on the deploy bucket prefix). Audit with the IAM Access Analyzer.
- Region is parameterized so a repo can deploy to multiple regions without a second role.

### GHCR (Container Registry)

The `GITHUB_TOKEN` works automatically for pushing images to `ghcr.io/<owner>/<repo>`:

```yaml
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

For **pulling** the image from a different host (the VPS deploy target), the auto-token is not enough — it doesn't leave the runner. Use a fine-grained PAT scoped read-only to that org's packages, store it on the VPS in `~/.docker/config.json`, and rotate quarterly.

### Cloudflare

Cloudflare's OIDC integration is opt-in per token. For most cases, a scoped API token (`Account › Cloudflare Pages › Edit`) is simpler and equivalent in blast radius.

```yaml
- uses: ./.github/actions/cloudflare-pages-deploy
  with:
    api-token:  ${{ secrets.CLOUDFLARE_API_TOKEN }}
    account-id: ${{ vars.CLOUDFLARE_ACCOUNT_ID }}   # not a secret
```

- Keep the account ID in `vars.*`, not `secrets.*`. It's not sensitive and the visibility helps debugging.
- One token per project. `web-prod` and `web-staging` get separate tokens so revoking one cannot break the other.

## Runtime env — 1Password Connect

The deployed app needs env vars that are not safe to keep in the GitHub secret store (third-party API keys, DB URLs, internal service tokens). Use 1Password as the secret system of record; render into a `.env` file at deploy time.

### Template file (committed to repo)

`deploy/production.env.example` is committed; values are 1Password references, not secrets:

```
DATABASE_URL=op://shared-prod/api-db/connection-string
STRIPE_SECRET_KEY=op://shared-prod/stripe/api-key
SENTRY_DSN=op://shared-prod/sentry/dsn
APP_BASE_URL=https://api.example.com
```

`op://shared-prod/<item>/<field>` references are URLs into the 1Password vault. They mean nothing without an `OP_SERVICE_ACCOUNT_TOKEN`.

### Composite action (`.github/actions/load-1password-env/action.yml`)

```yaml
name: Load 1Password environment
description: Render an env file with op:// references into job env

inputs:
  env-file: { required: true }

runs:
  using: composite
  steps:
    - id: render
      shell: bash
      run: |
        rendered="$RUNNER_TEMP/$(basename '${{ inputs.env-file }}').rendered"
        echo "rendered=$rendered" >> "$GITHUB_OUTPUT"

    - uses: 1password/load-secrets-action@v4
      with:
        export-env: true
      env:
        OP_ENV_FILE: ${{ inputs.env-file }}                         # template path
        OP_SERVICE_ACCOUNT_TOKEN: ${{ env.OP_SERVICE_ACCOUNT_TOKEN }}
```

The 1Password action reads the template, resolves each `op://` reference, and exports the result as job env (`export-env: true`) **and** as masked GitHub Actions secrets so they cannot accidentally be echoed.

### Service account token

- Issue a 1Password service account scoped to a single vault (`shared-prod`) so vault blast radius stays separated.
- Store it as `OP_SERVICE_ACCOUNT_TOKEN` in the repo's secrets. Rotate annually.
- For the VPS deploy pattern, render the env file inside the runner, scp it to the VPS, then use it as `env_file` on the container. Do **not** install 1Password on the VPS — the runner is the only thing that talks to 1Password.

### Why not GitHub repository secrets?

You can put runtime env in `secrets.*` and pipe it to the app. Two reasons not to:

1. GitHub secrets are per-repo. A monorepo with three deployable apps and shared env (DB URL, etc.) duplicates secrets — drift is a matter of when, not if.
2. Rotation requires a human in the GitHub UI per repo. With 1Password, rotating the value in the vault propagates to every render automatically.

Use GitHub secrets for **CI access** (the bootstrap layer that lets you talk to 1Password); use 1Password for **everything the deployed app reads**.

## Bot identity — fine-grained PATs only

When the workflow needs to mutate something outside the source repo (push to a tap repo, comment on PRs in another repo, trigger another repo's workflow), `GITHUB_TOKEN` is not enough.

Issue a fine-grained PAT scoped to that single repo, with the minimum permissions:

| Need | Repo | Permissions |
|---|---|---|
| Pull GHCR image from VPS | n/a (used outside Actions) | `packages: read` on the org |
| Push formula to tap repo | `<org>/homebrew-tap` | `contents: write` |
| Trigger workflow in another repo | `<org>/<other>` | `actions: write`, `contents: read` |
| Comment on cross-repo PR | `<org>/<other>` | `pull-requests: write` |

Store as `<PURPOSE>_GITHUB_TOKEN` (`TAP_GITHUB_TOKEN`, `OPS_TRIGGER_TOKEN`). Use one PAT per purpose; a token that can both push code and trigger workflows can deploy malicious code when leaked.

Classic PATs (`ghp_…` without scopes) are forbidden. If a workflow currently uses one, replace it before adding new functionality.

## Environment-scoped secrets

GitHub Environments (`environment: production`) let you scope secrets to specific deploy targets. Pair with required reviewers when the team needs a manual approval gate before production:

```yaml
deploy-prod:
  environment:
    name: production
    url: https://web.example.com
  steps:
    - run: echo "$DATABASE_URL"   # only the production-environment value
```

- Repo-level secrets are visible to every workflow run on every branch. Environment-scoped secrets are only readable when the job declares that environment, gated by the environment's protection rules.
- Use environments for production-only secrets such as production DB URLs and payment processor keys. Use repo-level secrets for everything else.

## Logging hygiene

GitHub masks declared secrets in logs. It does not mask:

- Values rendered to disk (a leaked `cat .env` step exposes everything).
- Substrings of secrets concatenated with other text.
- Secrets passed as command-line arguments (visible in `ps`).

Two rules:

1. Pass secrets via env vars or stdin.
2. Debug rendered env files by logging key counts or key names (`grep -c '^[A-Z_]*=' "$RENDERED"`), keeping values out of logs.
