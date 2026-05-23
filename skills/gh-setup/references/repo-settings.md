# Repository Settings

Use this reference when the task touches GitHub repository settings, merge policy, branch protections, rulesets, tag policy, Actions permissions, repository metadata, or Environments.

## Inspect First

Check the live repo before making severity calls or writing instructions:

- default branch
- enabled merge methods
- branch protections and repository rulesets
- required checks and merge queue
- required conversation resolution
- signed commit requirements
- allowed push actors
- protected tag rules
- Actions permissions and allowed actions policy
- GitHub Environments, reviewers, branch/tag restrictions, secrets, and vars
- repository description, homepage, topics, and visibility

Prefer `gh` or the GitHub UI/API for live settings. Checked-in workflow files are evidence, not proof of repo settings.

## Merge Policy

Default posture:

- Enable squash merge for repos that value a clean mainline.
- Disable merge commits and rebase merge unless the repo intentionally supports them.
- Preserve existing merge policy when a repo has a documented reason.
- Keep PR title conventions aligned with the repo's release tooling when squash commits become release commits.

Do not change merge methods just to satisfy taste. Tie the change to release notes, review ergonomics, auditability, or maintainer policy.

## Branch And Ruleset Policy

Preserve existing protections unless the user asks for a policy change.

Baseline checks:

- `main` should block force pushes and branch deletion.
- Required status checks should match the repo's real verify workflow.
- Required conversation resolution is useful even when direct pushes to `main` remain allowed.
- Merge queue requires workflows to include `merge_group` for required checks.
- Release bump commits need an actor that branch rules allow. When branch push restrictions are not enabled, workflow `GITHUB_TOKEN` writeback is acceptable for low-risk repos. When branch push restrictions are required, use a narrowly scoped GitHub App release actor that branch rules or rulesets explicitly allow.
- If a ruleset requires pull requests on `main`, automated push-back release jobs will fail unless the actor is exempted or the release tool opens PRs.

Branch protection with only conversation resolution is often a better fit than a full PR-required ruleset when maintainers intentionally keep direct pushes available.

## Tag Policy

Protect release tags when releases or deploys depend on tags.

- Restrict `v*` tag creation and mutation to trusted release automation or release admins.
- Treat marketplace major tags such as `v1` as mutable release pointers and document that explicitly.
- Do not let manual workflows publish from arbitrary tags unless the tag pattern and actor are trusted.

## Actions Policy

Use least privilege at both repository and workflow levels:

- Actions should not have broad write permissions by default.
- Secret-bearing jobs grant scopes per job.
- Allowed actions policy should permit known pinned actions and repo-owned local actions.
- Fork PRs should run read-only checks with no release or deploy secrets.

## Environments

Use GitHub Environments as secret and policy boundaries:

- `release` for package/library/CLI/marketplace publishing secrets.
- `staging`, `production`, or provider-specific environment names for running app deploys.
- Publish-only release jobs may use an approval-free `release` Environment for secret scoping, but GitHub will create deployment records for jobs that declare an Environment. There is no supported `deployment: false` workflow key.
- Running-service deploy jobs should keep deployment records enabled.
- Reviewer-gated Environments are for human-approved production promotion, signing, store submission, or other intentional manual gates.

Environment branch/tag policies constrain the workflow run ref. They do not prove a later manually checked-out ref is safe.
