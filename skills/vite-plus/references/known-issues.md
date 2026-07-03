# Known Issues (beta)

Vite+ is in beta and still moving quickly. These are real, recent caveats observed against the upstream issue tracker. Surface them only if the repo actually hits them — do not preemptively work around something a stock setup is fine with. Re-check this list against [the issue tracker](https://github.com/voidzero-dev/vite-plus/issues) when adopting a newer release.

## `vp check --fix` on a single file

Single-file invocations can emit spurious `TS2591` errors for `node:*` imports while a full-project `vp check --fix` passes.

- If `staged` runs per-file `vp check --fix`, fall back to a `vp check --fix` over the staged set, or scope `staged` to non-TS globs until upstream lands a fix.
- Tracking: [voidzero-dev/vite-plus#1443](https://github.com/voidzero-dev/vite-plus/issues/1443).

## TanStack Start / SSR `instanceof` failures

Some package managers (notably bun, sometimes npm) install two physical copies of `@voidzero-dev/vite-plus-core` — once via the `vite` alias and once via `vite-plus`'s direct dependency — which breaks SSR `isRunnableDevEnvironment()` checks.

- If SSR fails after migration, run `vp dedupe` and confirm only one `@voidzero-dev/vite-plus-core` exists under `node_modules`.
- Tracking: [voidzero-dev/vite-plus#1391](https://github.com/voidzero-dev/vite-plus/issues/1391).

## Cloudflare Workers tests

`@cloudflare/vitest-pool-workers` currently fails under `vp test` (`Cannot read properties of undefined (reading 'config')`) while plain `vitest run` passes.

- Keep the legacy `vitest` invocation for Workers packages until the upstream fix lands.
- Tracking: [voidzero-dev/vite-plus#1076](https://github.com/voidzero-dev/vite-plus/issues/1076).

## Vite+ 0.2.x Vitest wrapper removal

Vite+ 0.2.x removed `@voidzero-dev/vite-plus-test` and runs upstream Vitest directly.

- On 0.1.x to 0.2.x upgrades, delete the wrapper from package manifests, lockfiles, catalogs, overrides, resolutions, and peer-tweak rules.
- Plain node-mode tests should not add a direct `vitest` dependency; direct Vitest users and browser-mode projects may still need pinned upstream Vitest packages that match the bundled version.
- If browser tests fail with `vitest/internal/browser` resolution errors under pnpm, add direct `vitest` in the package that runs browser tests at the bundled version, then reinstall cleanly if stale peer variants remain.
