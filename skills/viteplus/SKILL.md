---
name: viteplus
description: "Migrate or align frontend repositories to the stock VitePlus workflow. Use when standardizing package or monorepo repos around `vp`, `voidzero-dev/setup-vp`, `vite-plus/test`, and VitePlus-native CI, test, packaging, and hook flows. Default to replacing direct package-manager and Vitest wiring with the VitePlus equivalents unless the repo has a proven exception."
---

# VitePlus

Use this skill to move a frontend repo closer to the stock VitePlus toolchain without blindly deleting repo-specific release or runtime logic.

## Migration Targets

When a repo is adopting VitePlus, default to this destination unless a repo-specific boundary clearly blocks it:

- CI uses `voidzero-dev/setup-vp@v1`, lets the action own Node and package-manager bootstrap, then runs `vp install`, `vp check`, `vp test`, and `vp build` as needed
- test files use `vite-plus/test` when VitePlus owns the test surface
- scripts prefer `vp test`, `vp test --watch`, `vp test --coverage`, `vp pack`, `vp build`, `vp update`, and `vp run <script>` over direct package-manager, raw Vitest, or tsdown wiring
- hooks prefer `vp config`, `.vite-hooks`, and `vp staged` instead of custom Husky or `lint-staged` setup
- contributor docs use the new `vp` commands in the same change
- if you keep the old command shape, explain the repo-specific reason explicitly

## Workflow

1. Audit the repo's current scripts, workflows, Vite config, test imports, release flow, package manager, and any repo-specific packaging steps.
2. Read [references/bootstrap.md](references/bootstrap.md) first for migration entrypoints, local guidance-file discovery such as `AGENTS.md`, `CLAUDE.md`, or repo rules, and the standard validation path.
3. Choose the repo shape: read [references/packages.md](references/packages.md) for standalone packages or [references/monorepos.md](references/monorepos.md) for workspaces.
4. Update the local tool surface together: scripts, `vite.config.ts`, test imports, hook wiring, and packaging commands should move as one migration instead of drifting piecemeal. After this step, run `vp check && vp test` to verify the migrated surface is coherent before moving on. If either command fails, resolve the errors before proceeding — do not carry forward a broken tool surface into CI or release changes.
5. Update CI and release automation with [references/ci-cd.md](references/ci-cd.md), replacing hand-rolled Node setup with the stock Vite+ flow where it fits.
6. Update tests and coverage wiring with [references/testing.md](references/testing.md) before changing assertions about test behavior.
7. Check [references/commands.md](references/commands.md) before changing command invocations, script wiring, or package-manager usage.
8. Keep repo-specific binary, release, or packaging steps only where Vite+ does not replace them cleanly.
9. If the repo is standardizing on a newer Vite+ release, update the global `vp` binary with `vp upgrade`, then update the project packages with `vp update vite-plus @voidzero-dev/vite-plus-core @voidzero-dev/vite-plus-test` or the nearest repo-appropriate subset. Verify with `vp outdated` when version drift is a concern.
10. Validate the migrated repo end-to-end by running `vp env && vp install && vp check && vp test`. Then re-check the key runtime surfaces: build output (verify `vp build` produces the expected artifacts), test coverage (confirm `vp test --coverage` reports pass), and hook triggers (confirm `vp staged` fires correctly on a staged change). If any surface fails, fix it before declaring the migration complete.

Concrete examples:

```yaml
- uses: voidzero-dev/setup-vp@v1
  with:
    node-version-file: ".node-version"
    cache: true
- run: vp install
- run: vp check
- run: vp test
- run: vp build
```

```ts
export default defineConfig({
  staged: {
    "*.{js,ts,tsx,vue,svelte}": "vp check --fix",
  },
})
```

Before/after for a common migration — replacing hand-rolled test scripts:

```diff
 # package.json scripts
-- "test": "vitest run --coverage",
-- "test:watch": "vitest",
+- "test": "vp test",
+- "test:watch": "vp test --watch",
```

## Guardrails

- Start from `vp create` or `vp migrate` when the repo shape allows it instead of rebuilding the migration by hand.
- Do not invent custom Husky, lint-staged, or shell-hook wiring when `vp config`, `.vite-hooks`, and `vp staged` already fit the repo.
- Keep `pack` config in `vite.config.ts` when feasible; do not maintain parallel tsdown config unless the repo has a deliberate reason.
- Do not delete repo-specific release workflows, binary packaging, or publish steps just to look more "stock."
- When coverage requires `@vitest/coverage-v8`, treat mixed-version warnings as a known Vite+ caveat and verify whether the same warning reproduces in a fresh stock scaffold before calling it a repo bug.
- Update contributor docs when install, test, or verify commands change.
