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

After rewriting imports, remove the standalone `vitest` dependency. Keep the npm aliases on `vite` and `vitest` pointing at `@voidzero-dev/vite-plus-core` / `@voidzero-dev/vite-plus-test`.

## Caveats

- Adding `@vitest/coverage-v8` to a Vite+ project can still produce a mixed-version warning during `vp test run --coverage`, even in a fresh stock scaffold. Treat that as a Vite+ limitation to verify and document, not as an automatic repo regression.
- `@cloudflare/vitest-pool-workers` currently fails under `vp test` (`Cannot read properties of undefined (reading 'config')`) while plain `vitest run` works. For Workers packages, keep the legacy `vitest` invocation until the upstream fix lands (tracking: voidzero-dev/vite-plus#1076).
