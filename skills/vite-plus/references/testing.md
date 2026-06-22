# Testing

Use this reference when migrating tests to Vite+ native usage.

## Defaults

- Import from `vite-plus/test` when migrating to Vite+.
- Browser-mode imports become `vite-plus/test/browser/context`.
- Move coverage and test-command wiring together with script updates.
- Verify both the default test pass and any coverage mode the repo actually depends on.
- Use the built-in `vp test` family rather than attempting to invoke Vitest through a made-up subcommand.

## Command Surface

- `vp test` runs tests once. Unlike raw Vitest, it does not stay in watch mode by default.
- `vp test watch` enters watch mode.
- `vp test run --coverage` runs once with coverage; `vp test run` is the explicit non-watch form for CI.
- Additional Vitest flags can be passed through after the subcommand (e.g. `vp test run --reporter verbose`).
- Vite+ 0.2.x runs upstream Vitest directly through `vite-plus`; do not keep the removed `@voidzero-dev/vite-plus-test` wrapper.

## Configuration

- Put test config in the `test` block in `vite.config.ts` once the repo is on Vite+.

```ts
import { defineConfig } from 'vite-plus'

export default defineConfig({
  test: {
    include: ['src/**/*.test.ts'],
  },
})
```

## Migration Diff

```diff
-import { describe, expect, it, vi } from 'vitest'
-const { page } = await import('@vitest/browser/context')
+import { describe, expect, it, vi } from 'vite-plus/test'
+const { page } = await import('vite-plus/test/browser/context')
```

After rewriting imports, remove the standalone `vitest` dependency for node-mode-only projects and keep only the `vite` alias pointing at `@voidzero-dev/vite-plus-core`. Leave imports from `vite-plus/test` and `vite-plus/test/*` unchanged; they are the stable public API.

## Vite+ 0.2.x Vitest Dependencies

- Node-mode-only tests: remove `@voidzero-dev/vite-plus-test`, remove any `vitest` alias or catalog entry, and do not add a direct `vitest` dependency.
- Direct Vitest usage: if source/config imports from `vitest` or `@vitest/*`, or lists packages such as `@vitest/coverage-v8` / `@vitest/ui`, pin those upstream packages to the Vitest version bundled by the installed `vite-plus` release.
- Browser mode: install the provider package the suite actually imports (`@vitest/browser-playwright` or `@vitest/browser-webdriverio`) in the workspace package that runs the browser tests, and keep its framework peer (`playwright` or `webdriverio`) present. With pnpm, also add direct `vitest` at the bundled version if `vitest/internal/browser` cannot resolve from the browser test server.
- Type augmentations such as `declare module 'vitest'` or `declare module '@vitest/browser*'` should still target the upstream module identity.

## Caveats

- Adding `@vitest/coverage-v8` means the repo now directly participates in Vitest dependency resolution. Pin it to the bundled Vitest version and verify the lockfile resolves a single Vitest version.
- `@cloudflare/vitest-pool-workers` currently fails under `vp test` (`Cannot read properties of undefined (reading 'config')`) while plain `vitest run` works. For Workers packages, keep the legacy `vitest` invocation until the upstream fix lands (tracking: voidzero-dev/vite-plus#1076).
