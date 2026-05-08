# Set Up a TypeScript Utility Library on Vite+

## Problem/Feature Description

The platform team at Acme is creating a new shared TypeScript library, `@acme/config`, that will be published to the internal npm registry and consumed by multiple frontend applications. The library has no build setup yet — just source files and a bare package.json. The team uses pnpm as their package manager across all repos, and they've standardized on Vite+ as their frontend toolchain.

Before the library can be published and used downstream, it needs a complete build setup: packaging configuration, a pre-commit hook that enforces linting on staged files, and updated contributor documentation so other developers know how to work with the repo. The team wants everything set up consistently with how their other Vite+ repos are configured, and they don't want to introduce extra config files that will need to be kept in sync over time.

## Output Specification

Produce:
- An updated `package.json` with correct scripts and any necessary configuration fields
- A `vite.config.ts` with packaging and hook configuration
- An updated `README.md` with current contributor instructions (install, test, build steps)
- Any other files required to complete the setup

Do NOT produce a `tsdown.config.ts` or equivalent separate packaging config file unless there is a specific reason to.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: package.json ===============
{
  "name": "@acme/config",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "test": "vitest run",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "vite-plus": "^1.0.0",
    "typescript": "^5.4.0"
  }
}

=============== FILE: README.md ===============
# @acme/config

Shared configuration helpers for the Acme platform.

## Development

Install dependencies:

```sh
pnpm install
```

Run tests:

```sh
pnpm test
```

## Publishing

This package is published to the internal npm registry. See the platform team's release docs for details.

=============== FILE: src/index.ts ===============
export { loadConfig } from './load.js'
export { validateConfig } from './validate.js'
export type { AcmeConfig, ConfigOptions } from './types.js'
