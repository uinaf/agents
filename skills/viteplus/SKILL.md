---
name: viteplus
description: "Migrate or align frontend repositories to the stock VitePlus workflow. Use when standardizing package or monorepo repos around `vp`, `voidzero-dev/setup-vp`, `vite-plus/test`, and VitePlus-native CI, test, and packaging flows, including updating scripts, test config, CI setup, and packaging commands."
---

# VitePlus

Use this skill to move a frontend repo closer to the stock VitePlus toolchain without blindly deleting repo-specific release or runtime logic.

## Workflow

1. Audit the repo's current scripts, workflows, Vite config, test imports, release flow, package manager, and any repo-specific packaging steps.
2. Read [references/bootstrap.md](references/bootstrap.md) first for migration entrypoints, local guidance-file discovery such as `AGENTS.md`, `CLAUDE.md`, or repo rules, and the standard validation path.
3. Choose the repo shape: read [references/packages.md](references/packages.md) for standalone packages or [references/monorepos.md](references/monorepos.md) for workspaces.
4. Update the local tool surface together: scripts, `vite.config.ts`, test imports, hook wiring, and packaging commands should move as one migration instead of drifting piecemeal.
5. Update CI and release automation with [references/ci-cd.md](references/ci-cd.md), replacing hand-rolled Node setup with the stock Vite+ flow where it fits.
6. Update tests and coverage wiring with [references/testing.md](references/testing.md) before changing assertions about test behavior.
7. Check [references/commands.md](references/commands.md) before changing command invocations, script wiring, or package-manager usage.
8. Keep repo-specific binary, release, or packaging steps only where Vite+ does not replace them cleanly.
9. Validate the migrated repo with the standard `vp` flow, then re-check the important runtime surface.

Concrete examples:

```yaml
- uses: voidzero-dev/setup-vp@v1
- run: vp env
- run: vp install
- run: vp check && vp test
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

- Treat `vp` as the tool owner for runtime, package-manager, and frontend-tooling operations when a repo has adopted Vite+.
- Prefer `vp create` or `vp migrate` as the migration starting point and `voidzero-dev/setup-vp@v1` plus `vp install` as the default CI shape.
- Prefer `vp config` and `vp staged` for hooks and related agent integration. Do not invent custom Husky, lint-staged, or shell-hook wiring when the stock Vite+ flow fits.
- Use `vp pack` for libraries and executables; use `vp build` for web applications.
- Keep `pack` config in `vite.config.ts` when feasible; do not maintain parallel tsdown config unless the repo has a deliberate reason.
- Do not delete repo-specific release workflows, binary packaging, or publish steps just to look more "stock."
- When coverage requires `@vitest/coverage-v8`, treat mixed-version warnings as a known Vite+ caveat and verify whether the same warning reproduces in a fresh stock scaffold before calling it a repo bug.
- Update contributor docs when install, test, or verify commands change.
