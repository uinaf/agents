# VitePlus Upgrade for a Production TypeScript Library

## Problem Description

The Nexus UI team maintains a widely-used TypeScript component library that was migrated to VitePlus six months ago. VitePlus has since released several updates with bug fixes and new features the team wants to take advantage of, particularly improvements to the type-aware lint pass and faster test startup times.

The team's senior engineer is on leave, and the remaining engineers are unsure of the correct upgrade procedure. A previous attempt by a well-meaning team member ran `pnpm update vite-plus` directly, which updated the `package.json` entry for `vite-plus` but left the project in a broken state — `vp check` was reporting errors that hadn't existed before and `vp test` was running the wrong Vitest version. It took an hour of debugging to realize the issue: some underlying packages hadn't been updated.

The team needs a clear, correct upgrade runbook they can follow now and reuse for future upgrades. They also want a shell script (`upgrade-viteplus.sh`) that automates the steps so that future upgrades are one-command operations. The script should handle both the local tooling on the developer's machine and the project-level dependencies, in the right order, and include verification steps so the engineer knows the upgrade succeeded before they push.

## Output Specification

Produce the following files:

- `upgrade-viteplus.sh` — a shell script that performs the complete upgrade procedure in the correct order, including verification
- `UPGRADE.md` — a human-readable runbook explaining each step, why it is needed, and what to do if a step fails

Both files should document all necessary steps a developer would need to run to fully upgrade VitePlus. The script should be executable as-is (no placeholder TODOs).

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: package.json ===============
{
  "name": "@nexus/ui",
  "version": "2.1.0",
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
    "dev": "vp pack --watch",
    "test": "vp test run --coverage",
    "test:watch": "vp test watch",
    "check": "vp check",
    "verify": "vp check && vp test run --coverage"
  },
  "devDependencies": {
    "vite-plus": "^1.0.0",
    "@voidzero-dev/vite-plus-core": "^1.0.0",
    "@voidzero-dev/vite-plus-test": "^1.0.0",
    "typescript": "^5.4.0"
  }
}

=============== FILE: pnpm-workspace.yaml ===============
overrides:
  vite: npm:@voidzero-dev/vite-plus-core@latest
  vitest: npm:@voidzero-dev/vite-plus-test@latest

=============== FILE: vite.config.ts ===============
import { defineConfig } from 'vite-plus'

export default defineConfig({
  lint: {
    options: {
      typeAware: true,
      typeCheck: true,
    },
  },
  test: {
    include: ['src/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
    },
  },
  staged: {
    '*.{ts,tsx}': 'vp check --fix',
  },
})
