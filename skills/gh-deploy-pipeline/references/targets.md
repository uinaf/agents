# Deploy Targets

Use this reference when wiring the deploy step. The detect→verify→e2e→deploy→smoke shape is identical across targets; only the deploy composite action changes.

## Cloudflare Pages (Static SPA / SSR)

Simplest target. One API token, one project, one branch. Pages handles atomic swaps for you — no blue/green plumbing needed.

Composite action shape (`.github/actions/cloudflare-pages-deploy/action.yml`):

```yaml
inputs:
  api-token:    { required: true }
  account-id:   { required: true }
  project-name: { required: true }
  dist-dir:     { required: true }
  branch:       { required: true, default: main }

runs:
  using: composite
  steps:
    - shell: bash
      env:
        CLOUDFLARE_API_TOKEN:  ${{ inputs.api-token }}
        CLOUDFLARE_ACCOUNT_ID: ${{ inputs.account-id }}
      run: |
        npx wrangler@latest pages deploy "${{ inputs.dist-dir }}" \
          --project-name "${{ inputs.project-name }}" \
          --branch "${{ inputs.branch }}"
```

- `branch: main` deploys to production. Any other branch creates a preview deployment with a `<branch>.<project>.pages.dev` URL — that's the cheap PR-preview pattern.
- The api-token needs `Account › Cloudflare Pages › Edit` only. Use a scoped API token for this target.
- Wrangler reads `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` from env; passing them as flags is redundant and leaks into logs.
- `_redirects` and `_headers` files at the root of `dist-dir` are picked up automatically. Custom `wrangler.toml` is only needed for Workers, not Pages.

## AWS Amplify (Static / SSR)

Heavier than Pages but mandatory inside an AWS-controlled blast radius. Uses OIDC-assumed roles (no long-lived access keys) and a custom deploy script that uploads to S3 and triggers an Amplify branch deployment.

Composite action shape:

```yaml
inputs:
  artifact-directory: { required: true }
  artifact-name:      { required: true }
  branch:             { required: true }
  custom-rules-file:  { required: false, default: "" }

runs:
  using: composite
  steps:
    - uses: actions/download-artifact@v8
      with:
        name: ${{ inputs.artifact-name }}
        path: ${{ inputs.artifact-directory }}

    - uses: aws-actions/configure-aws-credentials@v6.1.1
      with:
        role-to-assume: ${{ env.AWS_AMPLIFY_DEPLOY_ROLE_ARN }}
        aws-region:     ${{ env.AWS_REGION }}

    - shell: bash
      run: |
        node tooling/ci/amplify/deploy-branch.ts \
          --app-id "${AMPLIFY_APP_ID}" \
          --artifact-directory "${{ inputs.artifact-directory }}" \
          --branch "${{ inputs.branch }}" \
          ${{ inputs.custom-rules-file && format('--custom-rules-file {0}', inputs.custom-rules-file) || '' }}
```

The `deploy-branch.ts` helper is small but load-bearing:

```ts
// 1. Zip artifact-directory
// 2. amplify.createDeployment({ appId, branchName }) → { jobId, zipUploadUrl }
// 3. PUT the zip to zipUploadUrl
// 4. amplify.startDeployment({ appId, branchName, jobId })
// 5. Poll amplify.getJob({ appId, branchName, jobId }) until SUCCEED / FAILED
// 6. echo "deploy_url=https://${branch}.${appId}.amplifyapp.com" >> $GITHUB_OUTPUT
```

- OIDC trust policy on the IAM role: `repo:<org>/<repo>:ref:refs/heads/main` for production, plus a separate role for `pull_request` previews. Two roles, one per blast radius.
- The role needs `amplify:CreateDeployment`, `amplify:StartDeployment`, `amplify:GetJob`, and S3 `PutObject` on the deployment bucket. Nothing more.
- `--custom-rules-file` lets you sync per-branch redirect rules (`apps/web/amplify-redirects.json`) before the deploy. Without it, redirects drift between local config and Amplify console.
- Preview branches: name them `pr-${PR_NUMBER}` and let Amplify auto-create. Tear them down via a scheduled cleanup workflow that calls `amplify:DeleteBranch` for closed PRs.

## GHCR + VPS (Container, blue/green with Traefik)

For a backend service that runs on a VPS. Two repos may collaborate: this one builds and pushes the image; an Ansible inventory lives either alongside or in a separate ops repo and runs the cutover.

### Build + push the image

```yaml
build-image:
  needs: [verify]
  permissions:
    contents: read
    packages: write       # required for ghcr.io push
    id-token: write       # for build provenance attestation
  steps:
    - uses: actions/checkout@v6
    - uses: docker/setup-buildx-action@v3
    - uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    - uses: docker/metadata-action@v5
      id: meta
      with:
        images: ghcr.io/${{ github.repository }}
        tags: |
          type=sha,prefix=,format=long
          type=raw,value=main,enable={{is_default_branch}}
    - uses: docker/build-push-action@v6
      with:
        context: .
        push: true
        tags:   ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to:   type=gha,mode=max
        provenance: mode=max
```

- The image tag the deploy step consumes is the **commit SHA**. Keep `:main` or `:latest` as human browsing tags only because they can be reassigned.
- `provenance: mode=max` writes a SLSA build attestation alongside the image. Free; on by default in newer buildx.

### Render env from 1Password

The container needs runtime env (DB URLs, third-party API keys, internal service tokens) that does not live in the GitHub secret store. Render once into a `.env` file inside the runner, ship it to the VPS over SSH alongside the image tag, and keep its contents out of logs.

```yaml
- uses: ./.github/actions/load-1password-env
  with:
    env-file: deploy/production.env.example   # template with op://… references
  env:
    OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}

# Now $RUNNER_TEMP/production.env contains rendered values
- run: scp -o StrictHostKeyChecking=accept-new \
       "$RUNNER_TEMP/production.env" \
       deploy@${VPS_HOST}:/srv/${{ github.event.repository.name }}/.env.next
```

See [secrets.md](secrets.md) for the load-1password-env composite action.

### SSH + Ansible cutover

Two healthy containers (`api-blue`, `api-green`), one Traefik label switch. Only the unhealthy slot is replaced on each deploy.

```yaml
- name: Configure SSH
  run: |
    mkdir -p ~/.ssh
    echo "${{ secrets.VPS_DEPLOY_SSH_KEY }}" > ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    ssh-keyscan -H "${VPS_HOST}" >> ~/.ssh/known_hosts

- name: Run blue/green cutover
  env:
    IMAGE_TAG: ghcr.io/${{ github.repository }}:${{ github.sha }}
    VPS_HOST:  ${{ vars.VPS_HOST }}
  run: |
    ansible-playbook -i deploy/inventory.ini \
      deploy/playbooks/cutover.yml \
      -e "image_tag=${IMAGE_TAG}" \
      -e "env_file=$RUNNER_TEMP/production.env"
```

The `cutover.yml` playbook (sketch):

1. `docker login ghcr.io` on the VPS using a fine-grained PAT scoped read-only to that org's packages.
2. `docker pull ${image_tag}` — fail fast if the image isn't published.
3. Determine which slot is currently live by reading Traefik's `traefik.http.routers.api.service` label (`api-blue@docker` or `api-green@docker`). The other slot is the **target**.
4. Stop and `docker rm` the target slot's container; start a new container in the target slot bound to the new image, with `traefik.enable=false` (off the load balancer until healthy).
5. Health probe: `curl -fsS http://127.0.0.1:${TARGET_PORT}/healthz` with retries (10 × 2s). If it never returns 200, abort — the live slot is still serving traffic.
6. Flip Traefik labels: target slot becomes `traefik.enable=true` and the live router service is updated. Use `docker update` or the Traefik dynamic file provider; not a container restart on Traefik itself.
7. Drain the now-old slot: 30s pause for in-flight requests, then `docker stop`. Leave the container so the next deploy can roll back without re-pulling.
8. Final smoke from the GitHub runner: `curl -fsS https://api.example.com/healthz` over the public DNS.

```ini
# deploy/inventory.ini
[api]
api.example.com ansible_user=deploy
```

```yaml
# deploy/playbooks/cutover.yml — abridged
- hosts: api
  gather_facts: false
  tasks:
    - name: Pull new image
      community.docker.docker_image:
        name: "{{ image_tag }}"
        source: pull

    - name: Discover live slot
      shell: |
        docker inspect traefik --format '{% raw %}{{json .Config.Labels}}{% endraw %}' \
          | jq -r '.["traefik.http.routers.api.service"]'
      register: live_router
      changed_when: false

    - name: Compute target slot
      set_fact:
        target_slot: "{{ 'green' if 'blue' in live_router.stdout else 'blue' }}"

    - name: Replace target slot container
      community.docker.docker_container:
        name: "api-{{ target_slot }}"
        image: "{{ image_tag }}"
        env_file: "{{ env_file }}"
        restart_policy: unless-stopped
        labels:
          traefik.enable: "false"
        # ... ports, networks, volumes elided

    - name: Health probe target slot
      uri:
        url: "http://127.0.0.1:{{ target_port }}/healthz"
        status_code: 200
      retries: 10
      delay:   2
      register: health
      until:   health.status == 200

    - name: Cut Traefik over to target slot
      community.docker.docker_container:
        name: "api-{{ target_slot }}"
        labels:
          traefik.enable: "true"
          traefik.http.routers.api.service: "api-{{ target_slot }}@docker"

    - name: Drain old slot
      community.docker.docker_container:
        name: "api-{{ 'blue' if target_slot == 'green' else 'green' }}"
        state: stopped
      # leave it stopped, not removed — easy rollback target
```

### Public verification

The runner-side smoke step is what closes the loop. A green Ansible playbook on a misrouted Traefik label is still a failed deploy — only an external HTTP check confirms the public is served.

```yaml
- name: Public health check
  run: |
    for i in 1 2 3 4 5; do
      if curl -fsS https://api.example.com/healthz >/dev/null; then
        echo "OK"; exit 0
      fi
      sleep 5
    done
    echo "::error::Public health check failed after 25s"; exit 1
```

### Caveats

- The VPS deploy user (`deploy@`) needs `docker` group membership but no sudo. A compromised CI runner should not be able to `apt install` on the VPS.
- The ghcr-pull PAT used on the VPS is **separate** from the GitHub Actions `GITHUB_TOKEN`. It's a fine-grained PAT, read-only on packages, scoped to the org. Rotate quarterly.
- Inject env vars at runtime so the same image runs dev, staging, and prod.
- A failed health probe must leave the live slot untouched. The Ansible task graph above does that by labeling the target `traefik.enable=false` until the probe passes; if the probe fails, the playbook aborts before flipping the router label.

## GitHub Pages

Built-in to the platform. Use the `actions/deploy-pages` flow when the deployment target is a docs site or static project page co-located with the source repo.

```yaml
deploy-docs:
  needs: [verify]
  permissions:
    pages: write
    id-token: write
  environment:
    name: github-pages
    url: ${{ steps.deploy.outputs.page_url }}
  steps:
    - uses: actions/checkout@v6
    - uses: actions/configure-pages@v5
    - run: <build site>
    - uses: actions/upload-pages-artifact@v3
      with: { path: ./_site }
    - id: deploy
      uses: actions/deploy-pages@v4
```

- Caveat: GitHub Pages does not support previews. For PR previews, deploy the same build to a separate Cloudflare Pages project keyed by `pr-${PR_NUMBER}`.
- `environment.name: github-pages` is required — `actions/deploy-pages` will refuse to run without it.

## Vercel / Netlify

Both providers operate the same way as Cloudflare Pages — a CLI invocation with an API token does the upload, the platform does the atomic swap. Use `vercel deploy --prod` (with `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`) or `netlify deploy --prod --dir=apps/web/dist` (with `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID`).

The decision criterion is the rest of the stack, not the pipeline: pick the host that owns the rest of the runtime (Vercel for Next.js apps that use Vercel Functions, Netlify for sites already on Netlify Functions). For everything else, Cloudflare Pages is cheaper and faster.

## Multi-environment (staging + production)

When a single repo deploys to both staging and production, branch-out from the same workflow rather than duplicating it.

```yaml
deploy-web:
  strategy:
    matrix:
      include:
        - { environment: staging,    cf_project: web-staging,    branch: staging }
        - { environment: production, cf_project: web-production, branch: main }
  if: |
    (matrix.environment == 'staging'    && github.ref == 'refs/heads/staging') ||
    (matrix.environment == 'production' && github.ref == 'refs/heads/main')
  concurrency:
    group: deploy-${{ matrix.environment }}-web
    cancel-in-progress: false
```

- Use a `branch:` strategy (push to `staging` deploys staging; push to `main` deploys prod) rather than environment tags. Tags require an extra release step and break the "merge to ship" model.
- GitHub Environments (`environment: production`) gate the deploy on a manual approver. Add when the on-call rotation requires it; skip when the team trusts merge-to-main.
