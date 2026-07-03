# Release Branch Autoreview Closeout

## Problem/Feature Description

You are closing out a hotfix on branch `release/2.4.1`. The change fixes a crash during app startup. Autoreview returns one real crash-related finding and one non-blocking style finding. The release manager says the branch must stay frozen except for release blockers.

Your job is to produce the closeout decision and next steps. Do not expand the release branch for non-blocking cleanup.

## Output Specification

Produce `release-autoreview-closeout.md` with:

- **Release Scope**
- **Findings Decision**
- **Fixes Allowed**
- **Verification**
- **Forward-Port / Follow-up**

## Input Files

=============== FILE: inputs/review-output.md ===============
Finding A [P1 bug]:
The startup crash still happens when `config.json` is missing because the hotfix only handles malformed JSON, not ENOENT.

Finding B [P3 style]:
`startup.ts` has an older helper name that could be renamed for readability.
=============== END FILE ===============

=============== FILE: inputs/release-context.txt ===============
branch: release/2.4.1
allowed_changes: release blockers, crashes, data loss, install/upgrade breakage, concrete security exposure
current_issue: startup crash
=============== END FILE ===============
