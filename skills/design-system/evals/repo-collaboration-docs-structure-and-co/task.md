# Repository Docs for react-json-logic

## Problem/Feature Description

The studio is open-sourcing `react-json-logic` — a React library for building and evaluating JsonLogic rule trees with React components. The codebase is TypeScript, uses pnpm workspaces, and the canonical pre-commit gate is `pnpm verify`. The project has been internal for about a year and is now ready for its first public release.

Before the repo goes public, it needs the three repo-level docs that agents and contributors will rely on: machine-readable agent instructions, a security disclosure policy, and a record that CLAUDE.md is properly set up so AI coding tools pick up the right guidance.

The person setting this up wants the docs to be genuinely useful without becoming a maintenance burden. Any collaborator or AI agent who reads AGENTS.md should immediately understand what the project is, what tools they need, how to get started, and what the commit rules are.

## What to Produce

Write the following files to the working directory:

### `AGENTS.md`

Agent and contributor orientation for the `react-json-logic` repo. Should cover:
- What the library does and what the publishable surface is
- Toolchain and install step
- The key commands (verify, test, build, dev)
- Commit message format
- Any conventions a fresh contributor would trip on

### `SECURITY.md`

Vulnerability reporting policy for the repo. Should cover how to report, what to include in a report, and what the studio's response looks like.

### `CLAUDE.md`

Set this up so that AI tools reading the repo get the same guidance as AGENTS.md. Include a shell command or note in the files that shows how this is achieved.

## Output Files

Write the three files to the working directory:
- `AGENTS.md`
- `CLAUDE.md`
- `SECURITY.md`
