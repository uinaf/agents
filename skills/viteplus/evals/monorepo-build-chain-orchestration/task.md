# Monorepo Root Script Setup for UI Library and Docs Site

## Problem Description

The Luminary design system team maintains a TypeScript monorepo that contains a publishable component library (`packages/luminary-ui`) and a documentation/demo site (`apps/docs`). The docs app imports the UI library via the workspace protocol so it can showcase and test components before publishing.

The team recently decided to adopt Vite+ as their unified toolchain. A junior engineer made an initial attempt at wiring up root-level scripts but hit a frustrating issue: the build script for the docs app would sometimes build only the docs app without including the library's latest output, causing stale component renders. They tried using `pnpm --filter` to pull in the library transitively but observed inconsistent results depending on the pnpm version. The dev workflow is also broken — starting dev mode immediately hits missing module errors because the library's `dist/` folder doesn't exist yet.

The repo is a pnpm workspace. The library is an OSS-published package that external users will install from npm, so the docs site serves as integration verification that the published artifact resolves correctly end-to-end. The team wants the root scripts to handle four scenarios correctly: building the docs site for deployment, running development with hot reload across both packages, running tests across the workspace, and setting up pre-commit checks.

## Output Specification

Produce the following files reflecting the corrected Vite+ based monorepo setup:

- `package.json` — root package.json with corrected `scripts` block (the rest of the file can remain as provided)
- `apps/docs/vite.config.ts` — Vite config for the docs app
- `vite.config.ts` — root vite.config.ts with workspace-wide hook and staged configuration
- `packages/luminary-ui/package.json` — library package.json with corrected scripts

You may also produce a short `SETUP.md` explaining how to run each workflow, updated to reflect the new commands.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: package.json ===============
{
  "name": "@luminary/workspace",
  "private": true,
  "scripts": {
    "build": "pnpm --filter '...@luminary/docs' run build",
    "build:docs": "pnpm --filter '...@luminary/docs' run build",
    "dev:docs": "pnpm -r --parallel run dev",
    "test": "pnpm -r run test",
    "check": "pnpm -r run check",
    "verify": "pnpm -r run verify"
  },
  "devDependencies": {
    "vite-plus": "^1.2.0",
    "@voidzero-dev/vite-plus-core": "^1.2.0",
    "@voidzero-dev/vite-plus-test": "^1.2.0"
  }
}

=============== FILE: pnpm-workspace.yaml ===============
packages:
  - 'packages/*'
  - 'apps/*'

overrides:
  vite: npm:@voidzero-dev/vite-plus-core@latest
  vitest: npm:@voidzero-dev/vite-plus-test@latest

=============== FILE: packages/luminary-ui/package.json ===============
{
  "name": "@luminary/ui",
  "version": "0.5.0",
  "description": "Luminary Design System — UI component library",
  "type": "module",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "types": "./dist/index.d.ts"
    }
  },
  "files": ["dist"],
  "scripts": {
    "build": "vp pack",
    "dev": "vite build --watch",
    "test": "vp test run --coverage",
    "check": "vp check"
  },
  "devDependencies": {
    "vite-plus": "^1.2.0",
    "typescript": "^5.4.0"
  }
}

=============== FILE: apps/docs/package.json ===============
{
  "name": "@luminary/docs",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "vp build",
    "dev": "vp dev",
    "preview": "vp preview"
  },
  "dependencies": {
    "@luminary/ui": "workspace:*"
  },
  "devDependencies": {
    "vite-plus": "^1.2.0"
  }
}

=============== FILE: apps/docs/vite.config.ts ===============
import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  resolve: {
    alias: {
      '@luminary/ui': resolve(__dirname, '../../packages/luminary-ui/src/index.ts'),
    },
  },
})

=============== FILE: vite.config.ts ===============
import { defineConfig } from 'vite-plus'

export default defineConfig({})
