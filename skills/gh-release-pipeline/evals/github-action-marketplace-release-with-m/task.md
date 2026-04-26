# Publish a TypeScript GitHub Action to the Marketplace with Automated Releases

## Problem/Feature Description

Apex Platform has built `notify-on-failure`, a TypeScript GitHub Action that sends Slack notifications when a workflow job fails. The action is used internally across dozens of repositories, and several external teams have requested access. The team wants to publish it to the GitHub Actions Marketplace and set up automated releases using semantic-release so that every `feat:` or `fix:` commit to `main` automatically creates a new GitHub Release and advances the version.

The big challenge is distribution: users of GitHub Actions typically pin to a major version tag like `uses: apex-platform/notify-on-failure@v2` and expect that tag to always point to the latest stable release in that major line. If the team just creates `v2.1.0` but never updates the `v2` tag, all consumers are stuck on whatever version was current when they set up their workflow.

Additionally, the action is written in TypeScript, but GitHub only runs JavaScript — so the compiled output needs to be what the action actually executes. The team needs the CI pipeline to handle both the verification of the TypeScript source and the proper handoff to the marketplace runtime.

## Output Specification

Produce the following files:

- `.github/workflows/ci.yml` — GitHub Actions workflow with verify and release jobs
- `.releaserc.json` — semantic-release configuration suitable for a marketplace action
- `action.yml` — the action manifest (you may adapt/complete the partial version provided below)

## Input Files

The following files are provided. Extract them before beginning.

=============== FILE: action.yml ===============
name: "Notify on Failure"
description: "Sends a Slack notification when a workflow job fails"
author: "Apex Platform"

inputs:
  slack-webhook-url:
    description: "Slack incoming webhook URL"
    required: true
  message:
    description: "Custom message to include in the notification"
    required: false
    default: "A workflow job failed"

runs:
  using: "node20"
  main: "src/index.ts"
=============== END FILE ===============

=============== FILE: package.json ===============
{
  "name": "notify-on-failure",
  "version": "2.0.0",
  "description": "Sends a Slack notification when a workflow job fails",
  "scripts": {
    "build": "esbuild src/index.ts --bundle --platform=node --outfile=dist/index.js",
    "test": "vitest run",
    "lint": "eslint src",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "esbuild": "^0.21.0",
    "typescript": "^5.4.0",
    "vitest": "^1.6.0",
    "eslint": "^8.57.0",
    "@actions/core": "^1.10.1"
  }
}
=============== END FILE ===============

=============== FILE: .nvmrc ===============
20
=============== END FILE ===============
