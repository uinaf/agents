# Autoreview Target Selection

## Problem/Feature Description

A developer asks for "autoreview before I push." The checkout is clean, the current branch is `feature/payment-idempotency`, and the branch has an open pull request against `main`. The developer already committed the change locally; there is no dirty working-tree patch.

You must choose the correct autoreview target and produce the exact command sequence you would run. Do not review an empty local diff. Do not push just to review.

## Output Specification

Produce `autoreview-plan.md` with:

- **Target**: the chosen review mode and base
- **Commands**: exact shell commands to discover the PR base and run autoreview
- **Why Not Local**: one concise sentence explaining why dirty-local mode is wrong
- **Proof Loop**: how focused tests and rerun review should be handled if findings are accepted

## Input Files

=============== FILE: inputs/git-state.txt ===============
branch: feature/payment-idempotency
status: clean
origin/main: 174b6ef
HEAD: 3a67d25
open_pr_base: main
=============== END FILE ===============

=============== FILE: inputs/request.txt ===============
can u run autoreview on this before I push?
=============== END FILE ===============
