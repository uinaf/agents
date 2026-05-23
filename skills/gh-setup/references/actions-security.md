# Actions Security

Use this reference when editing GitHub Actions workflows, composite actions, reusable workflows, release jobs, deploy jobs, signing jobs, or any workflow that loads secrets.

## Dangerous Trigger Boundary

Do not use `pull_request_target` for workflows that check out, install, build, test, package, publish, sign, deploy, or otherwise execute project code.

Use `pull_request` for outsider or fork code with read-only credentials. Keep secret-bearing work on trusted events such as `push` to protected branches, protected tags, or validated manual dispatch.

## Manual Inputs

Secret-bearing manual workflows must validate inputs before checkout or credential loading:

1. Run a secretless validation job.
2. Validate allowed values, ref shape, environment, lane, package, or version.
3. Resolve refs to one immutable SHA when checking out code.
4. Emit sanitized outputs.
5. Use only those sanitized outputs downstream.

Environment branch/tag policy is not enough when the job later checks out `inputs.ref`.

## Permissions

Set workflow permissions to `contents: read` or `{}` by default, then grant per job:

- `contents: write` only for release notes, tags, release assets, or bump commits.
- `id-token: write` only for OIDC, trusted publishing, or keyless provenance.
- `attestations: write` only when producing GitHub build attestations.
- `pull-requests: write` only when posting PR comments or checks that require it.
- Monitoring, incident, or notification jobs stay read-only and receive no provider credentials.

## Action Pinning

Pin high-trust release, publish, upload, signing, and deploy actions to full commit SHAs with a same-line version comment when the repo can maintain pin refreshes.

Example:

```yaml
- uses: zizmorcore/zizmor-action@5f14fd08f7cf1cb1609c1e344975f152c7ee938d # v0.5.6
```

Before committing a pin, verify the SHA resolves upstream. Dependabot can update SHA-pinned GitHub Actions when the version comment is accurate.

Enable Dependabot `github-actions` updates for repos with pinned Actions. Pinning without an update path turns security hardening into drift.

## Standard Hardening

Prefer scanner-backed gates before bespoke workflow validators:

- `actionlint` for syntax and expression mistakes
- `zizmor` for GitHub Actions security
- gitleaks or TruffleHog for secret scanning when appropriate
- CodeQL or dependency scanners when the repo uses them

For repos without GitHub Advanced Security, configure zizmor for annotations and omit `security-events: write`.

## Inline Logic Budget

Workflow YAML is orchestration, not an application runtime.

- Prefer maintained actions for standard checks, auth setup, package publishing, artifact handling, and security scanning.
- Keep inline `run:` steps to simple command calls or a tiny amount of glue.
- Move policy logic, ref resolution, JSON parsing, summaries, and provider-specific branching into a repo-owned script or local action with tests.
- Do not add bespoke shell, JavaScript, grep, awk, or YAML parsing just to silence a scanner. Fix the workflow shape or use the scanner's supported configuration.
- When no maintained action fits and the logic is security-sensitive, make the local action's contract narrow: typed inputs, explicit outputs, no implicit secrets, and tests that cover bad input.

## Checkout And Credentials

Use `fetch-depth: 0` when release tooling, semantic versioning, affected detection, or tag operations need history.

Keep `persist-credentials: false` through dependency install, build, pack, and test steps whenever possible in secret-bearing jobs. Add write credentials only at the narrow release or deploy boundary.

## Caches

Do not share package-manager caches between untrusted PR runs and privileged push, release, publish, signing, deploy, or promotion jobs.

If a cache is unavoidable, namespace it by workflow, event/trust level, platform, and lockfile. Release and signing jobs should regenerate or verify generated trees before publishing.

## Artifacts And Payloads

GitHub Actions artifacts are temporary CI scratch storage. They are acceptable for same-run handoff when retention and quota are understood, but they are a weak durable boundary.

Prefer durable publish/deploy inputs:

- same-job tested output for simple static deploys
- GitHub Release asset
- package registry version
- container image digest
- provider-native deployment package
- signed archive with checksum or provenance
