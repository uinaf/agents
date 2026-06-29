# Scope And Release Guardrails

Autoreview is a closeout gate, not permission to rewrite the task.

## Scope Governor

Before the first review, freeze a scope baseline: original request or issue, target branch, intended behavior, owner boundary, changed files, and non-test LOC. For inherited or already-bloated branches, use the intended PR diff as the baseline rather than accepting all existing branch drift.

Before patching a finding, classify it:

- **In-scope blocker**: the finding is introduced by the current diff, affects the same owner boundary, and can be fixed without changing the task's contract.
- **Follow-up**: the finding is real but belongs to an adjacent bug class, sibling surface, cleanup, or broader hardening track.
- **Stop-and-escalate**: the finding requires a new protocol/config/storage/public API contract, a different owner boundary, a release-process change, or a design choice outside the original request.

Stop patching and report the scope break instead of continuing when:

- a narrow PR turns into an architecture change, protocol change, migration, or release-process change;
- the diff grows past 2x the original files or non-test LOC without explicit approval to expand scope;
- two review-triggered patch cycles have not converged; pause and reclassify every remaining finding before another edit;
- the best fix is "define the canonical contract first" rather than another local inference layer;
- fixing the accepted finding would make the PR no longer describe the same behavior, issue, or owner boundary.

After the two-cycle pause, continue only when every remaining accepted finding is still an in-scope blocker. Otherwise preserve the useful analysis, identify the smallest safe landed subset if one exists, and open or request a follow-up for the larger fix. Do not keep committing speculative fixes just to satisfy the reviewer.

Do not stack or push review-triggered fix commits while scope classification or focused proof is unresolved. Keep exploratory edits local until the cycle is proven in scope; if scope breaks, remove them from the landing lane instead of preserving them as branch history.

Critical exceptions must be explicit: active data loss, crash, broken install/upgrade, release blocker, or concrete security exposure. If the exception is not one of those, it is not critical enough to blow up scope.

## Release Branches And Release Process

On release, beta, stable, hotfix, signing, notarization, appcast, package-publish, or release-check work, use freeze discipline even when the branch name is not release-like:

- Fix only release blockers, failed release infrastructure, exact backports, install/upgrade breakage, data loss, crashes, or concrete security exposure.
- Treat non-blocking autoreview findings as follow-ups for `main`, not reasons to broaden the release branch.
- Do not introduce new product behavior, config surface, protocol shape, migration, plugin ownership, docs narrative, or process policy unless it directly unblocks the release.
- Keep proof tied to the release target: exact branch/ref, failing check or shipped-risk reason, smallest command/proof, and whether the fix must also forward-port to `main`.
- If review discovers a real but non-critical design problem during release closeout, stop with a follow-up issue/PR plan; do not use the release branch as the refactor lane.
