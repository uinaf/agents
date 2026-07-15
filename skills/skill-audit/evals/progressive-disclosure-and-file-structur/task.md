# Skill Health Check: Release Coordinator

## Problem/Feature Description

A DevOps team built a `release-coordinator` skill several months ago when they were still figuring out their workflow. The skill file has grown considerably since then: it contains a large inline scoring rubric, four worked examples, a step-by-step checklist that duplicates a shell script already in the repo, and a wall of prose in the frontmatter beyond the usual fields. The team suspects this is hurting performance because the model spends too long parsing the file before it understands what to do.

They want you to audit the skill's structure — specifically whether the right content is in the right place — and then restructure it so it follows sound information-architecture principles. After restructuring, they want Tessl run again so they can measure the improvement. Produce a before-and-after comparison and a written explanation of every structural change you made and why.

## Output Specification

Produce the following files:

- `audit-report.md` — covering the initial Tessl score, structural findings, every change made with a reason, the post-edit Tessl score, and a summary of what improved
- `audit-log.sh` — shell commands run during the audit in execution order (Tessl invocations, file reads, etc.)
- An updated version of `skills/release-coordinator/SKILL.md` reflecting the restructured skill
- Any new files you create in `skills/release-coordinator/references/` or `skills/release-coordinator/scripts/` as part of the restructure

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: skills/release-coordinator/SKILL.md ===============
---
name: release-coordinator
description: Helps coordinate releases.
triggers: ["deploy", "release", "ship"]
owner: devops-team
last_updated: 2024-01-15
---

# Release Coordinator

This skill helps coordinate software releases. It is used by the devops team. It should not be used for hotfixes or rollbacks — follow the repository's incident-response process for those cases.

## Release Scoring Rubric

Rate the release readiness on a scale of 1-5:

- **5** — All checks green, changelog updated, stakeholders notified, rollback plan documented
- **4** — Minor gaps: one stakeholder notification missing or changelog slightly incomplete
- **3** — Moderate gaps: two or more notifications missing, or changelog missing a section
- **2** — Significant gaps: no rollback plan or no changelog
- **1** — Incomplete: missing critical sign-off or build artifacts not ready

## Worked Example: Web App Release

Input: "We need to ship v2.3 of the web app by Friday."
Steps taken:
1. Checked JIRA for open blockers — found 2, escalated
2. Verified build artifacts in S3
3. Updated CHANGELOG.md with new features
4. Notified #releases Slack channel
5. Documented rollback: revert to v2.2 image in ECR
Result: Release approved, shipped Friday 14:00 UTC.

## Worked Example: Mobile Release

Input: "iOS build ready, need to coordinate App Store submission."
Steps taken:
1. Checked Apple review guidelines compliance
2. Confirmed TestFlight sign-off from QA
3. Updated App Store release notes
4. Coordinated with marketing for launch post
Result: Submitted to App Store, approved in 36h.

## Worked Example: API Version Bump

Input: "Bump the public API from v1 to v2."
Steps taken:
1. Verified backward-compat layer active
2. Updated OpenAPI spec and docs
3. Notified API consumers via email list
4. Set deprecation timeline in roadmap doc
Result: v2 live, v1 sunset in 90 days.

## Worked Example: Database Migration Release

Input: "Ship the schema migration for the orders table."
Steps taken:
1. Dry-run migration in staging
2. Confirmed rollback script tested
3. Scheduled maintenance window
4. Notified on-call team
Result: Migration complete, zero downtime.

## Workflow

### Pre-release

1. Check for open blockers in the issue tracker
2. Verify build artifacts exist and checksums match
3. Update the changelog for the version being released
4. Notify relevant stakeholders via the team's preferred channel
5. Document the rollback plan

### Release

6. Run the release script: `./scripts/do-release.sh <version>`
7. Monitor deployment logs for the first 10 minutes
8. Confirm the deployment health check passes

### Post-release

9. Update the release tracker
10. Send the post-release summary

## Release Checklist (also in scripts/do-release.sh)

- [ ] Open blockers resolved
- [ ] Build artifacts verified
- [ ] Changelog updated
- [ ] Stakeholders notified
- [ ] Rollback plan documented
- [ ] Health check passing
- [ ] Release tracker updated
- [ ] Post-release summary sent

=============== FILE: skills/release-coordinator/scripts/do-release.sh ===============
#!/bin/bash
# Release checklist runner
VERSION=$1
echo "Checking blockers..."
echo "Verifying artifacts..."
echo "Updating changelog..."
echo "Notifying stakeholders..."
echo "Documenting rollback..."
echo "Running release for $VERSION..."
echo "Monitoring logs..."
echo "Confirming health check..."
echo "Updating tracker..."
echo "Sending summary..."
echo "Release $VERSION complete."
