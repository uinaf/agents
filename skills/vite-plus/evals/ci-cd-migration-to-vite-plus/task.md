# Standardize CI for a Frontend Utility Library

## Problem/Feature Description

The `@acme/utils` team maintains a TypeScript utility library used across several internal products. Their GitHub Actions setup was written before Vite+ was adopted and still uses a hand-rolled Node bootstrapping pattern: they install Corepack, activate pnpm through it, and run `pnpm install` manually before running tests with a direct vitest invocation. The CI also includes a separate release workflow that handles npm publishing and creating GitHub releases.

The team has since fully adopted Vite+ as their toolchain. Their tech lead wants to standardize CI to match the current toolchain and reduce maintenance overhead — ideally by trimming the bootstrap boilerplate — while making sure nothing in the release process breaks.

## Output Specification

Produce updated GitHub Actions workflow files for this repository under `.github/workflows/`. The two workflow files are `ci.yml` (the main test/verify workflow) and `release.yml` (the publish workflow). Both should be written as complete, valid YAML files. Also write a brief `migration-notes.md` describing what changed and why.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: .github/workflows/ci.yml ===============
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Enable Corepack
        run: corepack enable

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Lint
        run: pnpm run lint

      - name: Type check
        run: pnpm run typecheck

      - name: Test
        run: pnpm exec vitest run --coverage

      - name: Build
        run: pnpm run build

=============== FILE: .github/workflows/release.yml ===============
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
          registry-url: 'https://registry.npmjs.org'

      - name: Enable Corepack
        run: corepack enable

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build package
        run: pnpm run build

      - name: Pack
        run: pnpm pack

      - name: Publish to npm
        run: npm publish --provenance --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: '*.tgz'
          generate_release_notes: true

=============== FILE: package.json ===============
{
  "name": "@acme/utils",
  "version": "1.4.2",
  "type": "module",
  "scripts": {
    "lint": "eslint src",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "build": "tsdown src/index.ts"
  },
  "devDependencies": {
    "eslint": "^9.0.0",
    "tsdown": "^0.12.0",
    "typescript": "^5.4.0",
    "vitest": "^2.1.0",
    "@vitest/coverage-v8": "^2.1.0"
  }
}
