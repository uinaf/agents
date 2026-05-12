# Troubleshooting

Common failure modes when standing up or operating a deploy pipeline. Check here before rewriting the workflow.

## Only one lane changed, but every lane deployed

- Cause: path rules only mention app source paths or the affected-graph command is not wired to lane outputs.
- Verify: inspect the `changes` job outputs and confirm the lockfile, shared packages, workflow files, and infra files are assigned to the right lanes.
- Fix: include shared dependency paths in every consuming lane and force all affected lanes when CI, deploy, or infrastructure contracts change.

## E2E passed but production serves a different build

- Cause: deploy rebuilt from source or checked out a newer ref instead of promoting the artifact verified by e2e.
- Verify: compare artifact name, source SHA, producing workflow run, and deployed version in the deploy summary.
- Fix: deploy must download the exact artifact or promote the immutable image produced by verify. No build commands in deploy jobs.

## Manual deploy ignores the requested ref safety checks

- Cause: `inputs.ref` is passed directly to checkout, shell, artifact lookup, or image lookup in a secret-bearing job.
- Fix: validate manual inputs in a secretless job, emit sanitized outputs, prove the artifact/image exists for that ref, then load environment credentials.

## Environment secret is unavailable

- Cause: the job did not declare `environment:`, the Environment branch policy rejected the run ref, or the secret is configured at the wrong scope.
- Verify: check the job's environment name, deployment protection state, and whether the secret exists on that Environment rather than at repository scope.
- Fix: declare the correct Environment on the deploy job and keep production secrets environment-scoped.

## OIDC role assumption fails

- Cause: provider trust policy does not match the workflow's actual claims. Common mismatches are branch vs tag, missing Environment binding, wrong audience, or a manual deploy checking out a different ref than the workflow run ref.
- Verify: print non-sensitive OIDC claim metadata if the provider supports it, or compare the workflow event, ref, repository, and environment against the trust policy.
- Fix: align the trust policy with the intended environment and event. Use separate roles for staging and production.

## Deploys race and the older one wins

- Cause: deploy concurrency is cancellable, scoped to `${{ github.ref }}`, or uses different keys between push deploys and manual deploys.
- Fix: use the same non-cancellable key in every deploy path: `deploy-<environment>-<lane>`.

## Smoke job has deploy credentials

- Cause: smoke is implemented as a step inside the deploy job, or the smoke job inherits OIDC/provider env from a shared setup action.
- Verify: assert provider credential variables are absent before running browser or HTTP checks.
- Fix: split smoke into a downstream read-only job with `contents: read` only.

## Smoke passes locally but users see failures

- Cause: smoke checks hit an internal endpoint, bypass routing, or check the wrong environment URL.
- Fix: smoke the public or consumer-facing environment endpoint where practical, and write that URL to the deploy job's Environment `url` and step summary.

## Step summary is useless during incidents

- Cause: the workflow logs details but does not write the human handoff artifact.
- Fix: append a concise `$GITHUB_STEP_SUMMARY` with environment, lane, source commit, artifact/image identity, deploy URL, smoke result, and rollback pointer.
