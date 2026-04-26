# Consolidate Tooling Configuration for VitePlus Migration

## Problem Description

The Prism analytics platform team has been running a TypeScript frontend library for two years. Over that time, configuration has accumulated organically: a separate Vitest config, a standalone oxlint config, tsdown for packaging, and Husky for pre-commit hooks. The project was recently updated to Vite 8 and Vitest 4.1, making it eligible for VitePlus adoption.

The team's tech lead wants to migrate to VitePlus and consolidate everything into its unified config format. She's especially keen on enabling proper type-aware linting across the codebase — the project has had latent type errors slip through because the existing oxlint setup doesn't perform type-aware checks. However, a previous spike by a colleague enabled the lint options in a test branch and found that type-aware checks silently weren't running, even with the options turned on. The colleague suspected it might be related to a tsconfig setting but didn't track down the root cause before moving on.

Your task is to perform the migration: consolidate all configuration into `vite.config.ts`, enable the team's desired type-aware checking correctly, and replace the Husky hook setup with the VitePlus equivalent. Produce the migrated config files and a brief `MIGRATION.md` explaining what changed and the recommended migration procedure for future reference.

## Output Specification

Produce the following files:

- `vite.config.ts` — the consolidated VitePlus config incorporating lint, test, pack, and staged-hook configuration
- `tsconfig.json` — updated TypeScript config (address any settings incompatible with VitePlus features you discover)
- `package.json` — updated with corrected scripts and dependencies reflecting the new toolchain
- `MIGRATION.md` — brief notes on what was consolidated, what the recommended migration entry point is, and any gotchas the team should know about (especially around type-aware checking)

Organize the output so that any configuration files no longer needed under VitePlus conventions are absent from your output — the team will delete them from the repo based on what you produce.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: package.json ===============
{
  "name": "@prism/analytics-core",
  "version": "1.4.2",
  "type": "module",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.cjs",
      "types": "./dist/index.d.ts"
    }
  },
  "files": ["dist"],
  "scripts": {
    "build": "tsdown",
    "dev": "tsdown --watch",
    "test": "vitest run --coverage",
    "test:watch": "vitest",
    "lint": "oxlint src/",
    "check": "tsc --noEmit && oxlint src/",
    "prepare": "husky install"
  },
  "devDependencies": {
    "vite": "^8.0.0",
    "vitest": "^4.1.0",
    "tsdown": "^0.12.0",
    "oxlint": "^0.4.0",
    "@vitest/coverage-v8": "^4.1.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.0.0",
    "typescript": "^5.4.0"
  }
}

=============== FILE: vitest.config.ts ===============
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['src/**/*.test.ts'],
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.test.ts'],
    },
  },
})

=============== FILE: .oxlintrc.json ===============
{
  "rules": {
    "no-unused-vars": "error",
    "no-console": "warn",
    "eqeqeq": "error",
    "no-implicit-coercion": "warn"
  },
  "ignorePatterns": ["dist/", "node_modules/"]
}

=============== FILE: tsdown.config.ts ===============
import { defineConfig } from 'tsdown'

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm', 'cjs'],
  dts: true,
  clean: true,
  sourcemap: true,
  treeshake: true,
  outDir: 'dist',
})

=============== FILE: tsconfig.json ===============
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "strict": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "dist",
    "baseUrl": ".",
    "paths": {
      "@prism/*": ["./src/*"]
    },
    "skipLibCheck": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}

=============== FILE: vite.config.ts ===============
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    lib: {
      entry: 'src/index.ts',
      formats: ['es', 'cjs'],
    },
  },
})

=============== FILE: .husky/pre-commit ===============
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
