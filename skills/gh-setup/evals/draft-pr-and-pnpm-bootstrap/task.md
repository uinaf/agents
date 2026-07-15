# Keep Draft Pull Requests Out of pnpm CI

## Problem

A repository's `.github/workflows/verify.yml` listens for pull-request activity types `opened`, `synchronize`, `reopened`, and `ready_for_review`. The maintainer expected that list to suppress draft pull requests, but opening or pushing to a draft still starts the verify job.

The pnpm job also enables `cache: pnpm` in `actions/setup-node` before `pnpm/action-setup`, and clean runners fail while the cache integration tries to locate the pnpm store.

Make the smallest safe workflow correction. Draft pull requests must not execute verification jobs, marking a PR ready must start verification, and pnpm caching must work on a clean runner. Keep the workflow on the unprivileged `pull_request` event.

## Input Files

The following files represent the current repository state. Extract them before beginning.

=============== FILE: .github/workflows/verify.yml ===============
name: Verify

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

permissions:
  contents: read

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0
        with:
          node-version-file: .node-version
          cache: pnpm
      - uses: pnpm/action-setup@d15e628ca66d93ee5f352c71671a7bc6a97af5c9 # v6.0.8
        with:
          run_install: false
      - run: pnpm install --frozen-lockfile
      - run: pnpm test
=============== END FILE ===============

=============== FILE: .node-version ===============
24
=============== END FILE ===============

=============== FILE: package.json ===============
{
  "private": true,
  "packageManager": "pnpm@10.17.1",
  "scripts": {
    "test": "vitest run"
  }
}
=============== END FILE ===============

## Output

Produce the corrected `.github/workflows/verify.yml` and a short explanation of why both fixes are necessary.
