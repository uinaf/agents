# Troubleshooting

Common failure modes when standing up or operating a deploy pipeline. Check here before rewriting the workflow.

## Only one lane changed, but every lane deployed

- Cause: path rules only mention app source paths or the affected-graph command is not wired to lane outputs.
- Verify: inspect the `changes` job outputs and confirm the lockfile, shared packages, workflow files, and infra files are assigned to the right lanes.
- Fix: include shared dependency paths in every consuming lane and force all affected lanes when CI, deploy, or infrastructure contracts change.

## E2E passed but production serves a different build

- Cause: deploy rebuilt from source or checked out a newer ref instead of deploying the payload verified by e2e.
- Verify: compare payload reference, source SHA, producing workflow run, checksum or digest, and deployed version in the deploy summary.
- Fix: deploy must consume the exact verified payload reference: same-job build output, release asset, package version, provider-native package, or immutable image digest. No fresh build commands in deploy jobs unless the deploy platform is the builder and its provenance is recorded.

## Deploy is blocked by Actions artifact quota

- Cause: production deploy depends on `actions/upload-artifact` / `actions/download-artifact`, so repo or org artifact quota blocks deploy even though build and tests passed.
- Verify: failing step says artifact storage quota was hit, or the workflow has an Actions artifact handoff that only exists to move deploy payloads between jobs.
- Fix: remove the GitHub Actions artifact dependency. For same-run static deploys, build/test/deploy in one trusted environment-scoped job and hand off to monitoring in the summary. For versioned releases, deploy from the GitHub Release asset, package registry, container digest, or provider-native package.

## Manual deploy ignores the requested ref safety checks

- Cause: `inputs.ref` is passed directly to checkout, shell, payload lookup, or image lookup in a secret-bearing job.
- Fix: validate manual inputs in a secretless job, emit sanitized outputs, prove the payload exists for that ref, then load environment credentials.

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

## Post-deploy checks have deploy credentials

- Cause: a monitoring, incident, notification, or synthetic-check job inherits OIDC/provider env from a shared setup action.
- Verify: assert provider credential variables are absent before running any read-only follow-up checks or publishing incident metadata.
- Fix: keep follow-up jobs read-only with `contents: read` only, or move the check into the app's monitoring system.

## Deployment looks green but users see failures

- Cause: CI used a cheap endpoint check as proof, but real monitoring, alerting, or synthetic coverage was missing or pointed at the wrong environment.
- Fix: remove the fake confidence. Wire the deployed URL into the GitHub Environment, publish a release/deploy marker to the monitoring system when the repo supports it, and include monitoring and rollback links in the deploy summary.

## Step summary is useless during incidents

- Cause: the workflow logs details but does not write a human-readable handoff summary.
- Fix: call a small repo-owned summary helper, such as `scripts/ci/write-deploy-summary`, that writes environment, lane, source commit, payload identity, deploy URL, monitoring URL, alert coverage, and rollback pointer to `$GITHUB_STEP_SUMMARY`.
