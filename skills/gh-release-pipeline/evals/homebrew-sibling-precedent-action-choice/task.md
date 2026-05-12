# Preserve the Working Homebrew Tap Pattern

## Problem/Feature Description

The `tccutil` repo publishes a small non-Go CLI and needs its release workflow fixed so new GitHub releases update `uinaf/homebrew-tap` automatically. A previous attempt used `dawidd6/action-homebrew-bump-formula`, but the action tried to follow a fork/PR path and failed with the existing fine-grained `TAP_GITHUB_TOKEN`.

The organization already has a known-good sibling repo, `uinaf/healthd`, with an `update-homebrew-tap` job that successfully pushes directly to the same style of tap using the v3 line of `Justintime50/homebrew-releaser`, pinned to a full commit SHA. The desired fix is to copy that boring working pattern, not invent an inline clone/sed/push script and not swap in another Homebrew action.

## Output Specification

Update `.github/workflows/release.yml` for `tccutil` so the release job updates the Homebrew tap after a release is published.

Also write a short `SETUP.md` note documenting the required `TAP_GITHUB_TOKEN` scope.

## Input Files

The following files represent the current repository state. Extract them before beginning.

=============== FILE: .github/workflows/release.yml ===============
name: release
on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@<full-sha> # v6.x.y
        with:
          fetch-depth: 0
      - uses: cycjimmy/semantic-release-action@<full-sha> # v4.x.y
        id: release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: Bump Homebrew formula
        if: steps.release.outputs.new_release_published == 'true'
        uses: dawidd6/action-homebrew-bump-formula@<full-sha> # v5.x.y
        with:
          token: ${{ secrets.TAP_GITHUB_TOKEN }}
          tap: uinaf/homebrew-tap
          formula: tccutil
          tag: v${{ steps.release.outputs.new_release_version }}
=============== END FILE ===============

=============== FILE: docs/healthd-update-homebrew-tap.yml ===============
update-homebrew-tap:
  needs: release
  if: needs.release.outputs.new_release_published == 'true'
  runs-on: ubuntu-latest
  steps:
    - uses: Justintime50/homebrew-releaser@<full-sha> # v3.x.y
      with:
        homebrew_owner: uinaf
        homebrew_tap: homebrew-tap
        formula_folder: Formula
        github_token: ${{ secrets.TAP_GITHUB_TOKEN }}
        commit_owner: uinaf release bot
        commit_email: release-bot@users.noreply.github.com
        install: 'bin.install "healthd"'
        test: 'system "#{bin}/healthd", "--version"'
=============== END FILE ===============
