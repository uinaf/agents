---
name: gh-setup
description: "Set up or align a repository's GitHub collaboration and delivery surface: repo settings, branch/ruleset policy, PR and security templates, Actions hardening, GitHub Environments, release workflows, and deploy workflows. Use when standardizing GitHub setup for repos, CI/CD, publishing versioned packages, or deploying running apps; route app deploy details to deploy references and package publish details to release references."
---

# GitHub Setup

Make GitHub the boring, enforceable shell around a repo: settings, templates, Actions, secrets, releases, and deploys should all point at the same delivery contract.

This skill owns GitHub policy and workflow shape. It does not own product architecture, provider-specific infrastructure internals, app security review, or repo boot/readiness setup.

It also owns baseline existence and template shape for GitHub-facing collaboration files such as PR templates, issue templates, `SECURITY.md`, and `CONTRIBUTING.md`.

## Start Here

1. Inspect the repo before changing policy:
   - `.github/workflows/`
   - `.github/actions/`
   - `.github/pull_request_template.md`
   - `.github/ISSUE_TEMPLATE/`
   - `SECURITY.md`
   - `CONTRIBUTING.md`
   - `docs/`
   - package, build, release, deploy, and verify scripts
2. Check live GitHub settings before recommending changes: default branch, merge methods, branch/ruleset policy, Actions permissions, allowed GitHub Actions, Environments, Environment protection rules, secrets/vars locations, protected tags, and allowed push actors.
   Useful probes:
   - `gh repo view --json defaultBranchRef,mergeCommitAllowed,rebaseMergeAllowed,squashMergeAllowed,deleteBranchOnMerge`
   - `gh api repos/{owner}/{repo}/actions/permissions`
   - `gh api repos/{owner}/{repo}/environments`
   - `gh api repos/{owner}/{repo}/rulesets`
3. Classify the repo:
   - **Versioned artifact**: package, library, CLI, GitHub Action, Homebrew-published binary, or registry publish -> read [release workflows](references/release-workflows.md) and [release targets](references/release-targets.md).
   - **Running app or service**: Pages, Cloudflare, SST, container, static app, backend, or hosted service -> read [deploy workflows](references/deploy-workflows.md), [deploy environments](references/deploy-environments.md), and [deploy secrets](references/deploy-secrets.md).
   - **Both**: publish the durable artifact first, then deploy from that published boundary. Read both release and deploy references.
4. Use repo-local commands as the source of truth. If a release repo lacks stable verify/package proof, or a deploy repo lacks stable verify, e2e, monitoring, or rollback hooks, pause GitHub wiring until the repo has durable readiness proof.
5. Keep `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `AGENTS.md`, and `docs/` current when GitHub changes affect contributor or operator workflows.

## Baseline Shape

- `main` is continuously releasable or deployable after verification passes.
- Pull requests run verify with read-only credentials.
- Merges to `main` run verify before release or deploy.
- Release/publish/deploy jobs are non-cancellable at the secret-bearing boundary.
- GitHub Environments hold release/deploy secrets and variables; repo-level secrets are bootstrap-only.
- Manual secret-bearing workflows validate inputs in a secretless job before checkout or credential loading.
- GitHub Actions artifacts are temporary CI scratch storage, not a release or deployment registry.
- Required workflows keep a stable final check when lane detection, matrices, or no-op paths can skip individual jobs.

## Repository Settings

Read [repo settings](references/repo-settings.md) when changing merge policy, branch protections, rulesets, tag protection, Actions permissions, Environment settings, or repository descriptions.

Default posture:

- Prefer squash merge for small and medium repos unless the repo has a clear history-preservation reason.
- Disable merge methods the repo does not intentionally support.
- Preserve existing approval, status-check, signed-commit, actor, and tag restrictions unless the user explicitly asks to change them.
- Prefer signed-commit requirements on protected/default branches when the plan and automation path support them.
- If direct pushes to `main` must remain allowed, prefer branch protection with conversation resolution rather than forcing all default-branch changes through PRs by accident.
- For release bump commits, verify the token actor is allowed by branch/ruleset policy before relying on bot metadata.

## Templates

Read [templates](references/templates.md) when creating or aligning PR templates, issue templates, `SECURITY.md`, or contributor-facing GitHub guidance.

Default posture:

- PR templates should ask for summary, changed surfaces, risks, verification, and complexity.
- `SECURITY.md` should be private-first and avoid public issue reporting for vulnerabilities.
- `CONTRIBUTING.md` should describe contributor setup, validation, and PR workflow only when the repo accepts outside or cross-team contributions.
- Issue templates should exist only when they improve triage; avoid checklist theater.
- Keep durable workflow detail in docs, not copied across README, CONTRIBUTING, templates, and agent guidance.

## Actions Security

Read [Actions security](references/actions-security.md) before editing workflows that execute code, load secrets, publish artifacts, sign binaries, or deploy.

Hard defaults:

- Do not use `pull_request_target` for workflows that check out, install, build, test, package, publish, sign, deploy, or execute project code.
- Default workflow permissions to read-only or `{}` and grant scopes per job.
- Pin high-trust release, publish, upload, signing, and deploy actions to full commit SHAs with same-line version comments when the repo can maintain them.
- Run `actionlint` for syntax and `zizmor` for GitHub Actions security before inventing bespoke validators.
- Keep workflow YAML boring: prefer maintained actions and repo-owned commands over large inline shell/JavaScript blocks.
- Keep untrusted PR caches separate from privileged push, release, deploy, signing, or publish caches.

## Release Route

Use this route for versioned packages, libraries, CLIs, marketplace actions, Homebrew-published tools, Swift/CocoaPods packages, Go/Rust releases, and registry publishes.

Core shape:

```text
pull request -> verify
push to main -> verify -> release/publish -> version bump or release PR
```

Read only the target-specific references needed:

- [release workflows](references/release-workflows.md) - workflow layout, triggers, checkout, permissions, caches, skip-CI, bot identity, and trusted refs
- [release targets](references/release-targets.md) - npm, Swift, GoReleaser, Rust, GitHub Action, and Homebrew target shapes
- [semantic-release](references/semantic-release.md) - semantic-release config and dry-run checks
- [release troubleshooting](references/release-troubleshooting.md) - common release failures

## Deploy Route

Use this route for running apps and services: static sites, SST apps, Cloudflare, containers, APIs, and hosted frontends.

Core shape:

```text
push to main
  -> detect changes
  -> verify lane and build immutable payload
  -> e2e against that payload
  -> deploy through GitHub Environment
  -> monitoring and rollback handoff
```

Read only the deploy references needed:

- [deploy workflows](references/deploy-workflows.md) - lane detection, concurrency, manual deploy, permissions, monitoring handoff, and summaries
- [deploy environments](references/deploy-environments.md) - Environment contracts, OIDC, SST, Cloudflare/static-token boundaries
- [deploy secrets](references/deploy-secrets.md) - credential categories, logging, runtime secrets, OIDC, and token fallback
- [deploy troubleshooting](references/deploy-troubleshooting.md) - common deploy failures

## Output

Report the setup compactly:

- files changed
- GitHub settings or Environments to update manually
- release/deploy target and durable payload boundary
- verification run
- remaining risks or blockers

If live GitHub settings were not checked, say so. Do not present inferred settings as confirmed.

Example:

```text
files changed: .github/workflows/release.yml, SECURITY.md
settings: live rulesets not checked; require manual confirmation
target: npm package release from verified main
evidence: actionlint, npm test
risks: publish token environment still needs maintainer update
```
