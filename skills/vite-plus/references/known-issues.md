# Known Issues (alpha)

Vite+ is still in alpha. These are real, recent caveats observed against the upstream issue tracker. Surface them only if the repo actually hits them — do not preemptively work around something a stock setup is fine with. Re-check this list against [the issue tracker](https://github.com/voidzero-dev/vite-plus/issues) when adopting a newer release.

## Hook runner compatibility

`vp` opens `/dev/tty` directly, which causes it to hang when spawned by non-interactive hook tools such as lefthook.

- Prefer the stock `vp config` / `.vite-hooks` path.
- If the repo has a reason to use lefthook or similar, run the hook command through `vp run --silent` and verify it returns under load before merging.
- Tracking: [voidzero-dev/vite-plus#1396](https://github.com/voidzero-dev/vite-plus/issues/1396).

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

## `@vitest/coverage-v8` mixed-version warnings

Adding `@vitest/coverage-v8` to a Vite+ project can still produce a mixed-version warning during `vp test run --coverage`, even in a fresh stock scaffold.

- Treat as a known Vite+ limitation. Verify the same warning reproduces in a fresh stock scaffold before calling it a repo bug.
