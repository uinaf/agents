# Troubleshooting

Common failure modes when standing up or operating a deploy pipeline. Check here before rewriting the workflow.

## Two pushes deployed, only the second's artifact is on the host

- Cause: deploy concurrency group is missing or set to `cancel-in-progress: true`. Both runs reached the host; whichever uploaded last wins. The first run's e2e validated an artifact that never shipped.
- Fix: `concurrency: { group: deploy-<env>-<lane>, cancel-in-progress: false }` at the **job** level. Verify and e2e can stay cancellable; deploy must serialize.

## Deploy job runs even though the lane wasn't changed

- Cause: the `if:` gate uses `success()` instead of an explicit `result == 'success'` check. `success()` is true when the upstream job is **skipped**, which the lane-detection job does on unrelated changes.
- Fix: `if: ${{ needs.verify-<lane>.result == 'success' && needs.e2e-<lane>.result == 'success' }}`.

## Lane detection misses a CI/hosting change

- Cause: `paths-filter` rules only mention app source paths, not CI/hosting paths. A change to `.github/workflows/main.yml` or `Dockerfile` wasn't redeployed because no lane claimed those paths.
- Fix: add a "force lanes" rule for CI/hosting paths, or include those paths in *every* lane's filter. For Turbo `--affected`, layer a path-based force-trigger on top of the package-graph result.

## E2E passed but the deployed site fails the same flow

- Cause: e2e ran against a different artifact than the one that shipped. Common culprits: the deploy job rebuilt instead of downloading the artifact, the artifact name collided with another lane's, or the deploy job's checkout pulled a newer commit than verify did.
- Verify: in the deploy job log, look for the `Download build artifact` step. Its "Total downloaded size" should match the upload step's bytes from verify.
- Fix: deploy must `actions/download-artifact` the exact name uploaded by verify. No `npm run build` in the deploy job. Pin both jobs' checkout to the same `${{ github.sha }}`.

## Cloudflare Pages deploy 200s but new content is missing

- Cause: build emitted into the wrong directory; wrangler uploaded the old `dist/` from the previous run that was still on the runner, or the new build wrote to `apps/web/build` while the deploy points at `apps/web/dist`.
- Verify: `actions/upload-artifact` step has `if-no-files-found: error`. If it ever silently succeeded with 0 files, the artifact was empty.
- Fix: assert the artifact size > 0 between verify and deploy. Add a `ls -la apps/web/dist` debug step to confirm what's about to ship.

## AWS Amplify deploy hangs in `PENDING`

- Cause: the upload to S3 succeeded but `amplify:StartDeployment` was never called, or the IAM role lacks `amplify:GetJob` so the polling loop can't progress.
- Verify: AWS console → Amplify app → Deployments tab. If the job is missing entirely, `StartDeployment` failed silently.
- Fix: re-check the IAM policy for `amplify:CreateDeployment`, `amplify:StartDeployment`, `amplify:GetJob`. Add structured logging in `deploy-branch.ts` so each Amplify API call writes its response to the GitHub log.

## AWS OIDC: "Could not assume role with OIDC"

- Cause: the role's trust policy `sub` claim doesn't match the workflow's actual claim. Common: trust policy says `ref:refs/heads/main`, workflow runs on a `pull_request` (claim is `pull_request:<head-ref>`).
- Verify: a debug step `aws sts get-caller-identity` after the configure step won't help — it never reaches that point. Look at the configure step's "Federated Authentication" log line and the role's trust policy side by side.
- Fix: align the trust policy's `StringLike` `sub` claim with the workflow event. For preview deploys, use a separate role whose trust policy allows `pull_request`-event subs.

## GHCR push fails with "denied: permission_denied"

- Cause: the workflow lacks `permissions: { packages: write }`, or the repo is private and the org's package visibility rules block the push.
- Fix: add `packages: write` at the job level. For private repos, in org settings → Packages → "Container registry", confirm the source repo is allowed to publish.

## VPS Ansible cutover succeeds but the public URL still serves the old image

- Cause: Traefik re-read the docker labels but the old container still has `traefik.enable=true`, so two routers match the same host rule. Traefik picks one in label order, which may not be the new one.
- Verify: `curl -fsS http://<vps>:8080/api/http/routers` (Traefik dashboard) and inspect both `api-blue` and `api-green` routers. Exactly one should have the production host rule.
- Fix: in the cutover playbook, **remove** the production host label from the old slot before adding it to the new slot. Both labels at once is the bug.

## Health probe passed in Ansible, public smoke fails

- Cause: the in-VPS probe hit `127.0.0.1:<port>` directly, bypassing Traefik. Traefik routing changes (host rules, TLS, middleware) are exactly the kind of bug that fails public traffic but passes the local probe.
- Fix: keep the local probe (it catches container-crashed-on-boot) but add a **runner-side** smoke step that hits the public DNS over HTTPS. A green deploy must pass both.

## Failed deploy left two healthy containers but the wrong one live

- Cause: the cutover playbook flipped the Traefik label early (before the health probe), then the probe failed and aborted, leaving traffic pointed at an unhealthy slot.
- Fix: the new slot's container starts with `traefik.enable=false`. The label flip happens **after** the health probe, never before. If the probe fails, the playbook aborts and the live slot is untouched.

## 1Password render emits literal `op://` strings into the .env

- Cause: `1password/load-secrets-action` ran but `OP_SERVICE_ACCOUNT_TOKEN` was empty (typo, wrong secret name, or scoped to a different vault). The action exits 0 on missing references unless `OP_CONNECT_TOKEN` is also set, and `op:` strings pass through as literals.
- Verify: `grep '^[A-Z_]*=op://' "$rendered_env_file"` after the load step. Any match is a render failure.
- Fix: assert no `op://` literals remain. Add a guard step:
  ```bash
  if grep -q '^[A-Z_]*=op://' "$rendered_env_file"; then
    echo "::error::1Password references not resolved"; exit 1
  fi
  ```

## Preview deploy comment posts but the URL 404s

- Cause: the comment was upserted before the deploy completed, or the deploy_url output was empty (the deploy step crashed after writing the comment but before publishing the artifact).
- Fix: order is `deploy → smoke → comment`. The comment job must `needs:` the smoke job, not just the deploy job.

## Workflow re-runs after a deploy because the bot pushed a generated file

- Cause: the deploy step (or a post-deploy hook) committed a generated file back to `main`, retriggering the workflow.
- Fix: the deploy job must not push to `main`. If a post-deploy file update is genuinely required (e.g. update a CDN manifest), put it in a separate workflow gated on a non-`main` ref, or commit with `[skip ci]` in the message and gate `main.yml` on `!contains(github.event.head_commit.message, '[skip ci]')`.

## "Could not download artifact: 404 Not Found" between verify and deploy

- Cause: the upload step in verify ran on a different runner than the download step in deploy, but the artifact name was reused by another lane in the same workflow run. GitHub deduplicates by name within a run.
- Fix: make artifact names lane-scoped (`web-dist`, `tv-dist`, never just `dist`). Verify with `actions/list-artifacts` if you need to inspect mid-run.

## Manual `workflow_dispatch` deploy ignores my `ref:` input

- Cause: the workflow ignores the requested ref, or passes an unvalidated input into a secret-bearing job.
- Fix: validate `inputs.ref` in a secretless step, emit a sanitized output, then use that output for `actions/checkout` `with.ref` or artifact/image lookup. Sanity-check `git rev-parse HEAD` against the validated ref.

## Concurrency group serializes when it shouldn't

- Cause: the group key includes `${{ github.ref }}` instead of `(env, lane)`, so two pushes on `main` correctly serialize but a manual dispatch from a different ref gets its own queue and can race.
- Fix: lane-scoped key (`deploy-production-web`), not ref-scoped. Same key in `main.yml` and `deploy.yml`. Different lanes get different keys so web and api can deploy in parallel.

## "Resource not accessible by integration" when posting preview comment

- Cause: the deploy job is missing `pull-requests: write`, or the workflow was triggered from a fork (where `GITHUB_TOKEN` is read-only).
- Fix: add `permissions: { pull-requests: write }` at the job level. For fork PRs, gate the comment step on `github.event.pull_request.head.repo.full_name == github.repository`.
