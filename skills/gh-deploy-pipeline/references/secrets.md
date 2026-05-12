# Secrets and Credentials

Use this reference to keep deploy credentials short-lived, scoped, and quiet in logs. Prefer OIDC and GitHub Environments over provider-specific static-token recipes.

## Layers

Deploy workflows usually touch three secret classes:

- CI identity: the trust material GitHub Actions uses to authenticate to the deploy provider.
- Deploy configuration: environment names, project IDs, regions, service names, URLs, and role names.
- Runtime secrets: values the running app reads, such as database URLs, payment keys, signing keys, and internal service tokens.

Keep these classes separate. Repo-level secrets are bootstrap-only; production deploy credentials and runtime secrets belong to GitHub Environments or the provider's secret system.

## OIDC First

When the provider supports federation, use GitHub's OIDC token instead of long-lived credentials:

```yaml
deploy:
  permissions:
    contents: read
    id-token: write
  environment:
    name: production
  steps:
    - run: ./scripts/ci/assume-deploy-identity --environment production
```

The provider trust policy should bind at least:

- repository owner/name
- branch, protected tag, or GitHub Environment
- provider audience
- deployment role or environment

Use one identity per blast radius. Production and staging should not share the same provider role.

## Static Tokens

Use static tokens only when federation is unavailable or the provider API does not support it.

- Store static tokens on the GitHub Environment, not as repository-level secrets.
- Give each token one purpose and one environment.
- Prefer narrowly scoped provider tokens over broad user tokens.
- Rotate static tokens on a schedule and after any runner, dependency, or workflow compromise.
- Document why OIDC was not used.

## Runtime Secrets

Runtime secrets should be resolved by the deploy provider or environment-specific secret store whenever possible. If the workflow must render runtime config:

- render inside the GitHub runner after the environment is selected
- keep the rendered file in `$RUNNER_TEMP`
- transfer only to the deploy target that needs it
- remove it at the end of the job when practical
- log key names or counts only, never values

Do not commit plaintext runtime values. Template files may contain secret-store references when those references are non-sensitive without their corresponding access token.

## Logging Hygiene

GitHub masks declared secrets in logs. It does not reliably mask:

- values rendered to disk
- substrings of secrets concatenated with other text
- secrets passed as command-line arguments
- provider tokens returned by CLI debug output

Rules:

1. Pass secrets through env vars or stdin.
2. Disable verbose CLI logging in secret-bearing jobs.
3. Avoid `set -x` in deploy scripts.
4. Debug rendered env files by logging key counts or key names only.
