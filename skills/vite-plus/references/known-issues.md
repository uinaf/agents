# Known Issues (beta)

Vite+ is in beta and still moving quickly. Carry a caveat only when its failure reproduces on the installed release. Inspect the upstream issue or release notes to identify the first fixed version and preferred upgrade path; a closed report can still describe a bug in an older pinned release. Document the exact affected version and reproduction, then re-check the exception when upgrading.

## TanStack Start / SSR `instanceof` failures

Some package managers (notably bun, sometimes npm) install two physical copies of `@voidzero-dev/vite-plus-core` — once via the `vite` alias and once via `vite-plus`'s direct dependency — which breaks SSR `isRunnableDevEnvironment()` checks.

- If SSR fails after migration, run `vp dedupe` and confirm only one `@voidzero-dev/vite-plus-core` exists under `node_modules`.
- Tracking: [voidzero-dev/vite-plus#1391](https://github.com/voidzero-dev/vite-plus/issues/1391).

## Vite+ 0.2.x Vitest wrapper removal

Vite+ 0.2.x removed `@voidzero-dev/vite-plus-test` and runs upstream Vitest directly.

- On 0.1.x to 0.2.x upgrades, delete the wrapper from package manifests, lockfiles, catalogs, overrides, resolutions, and peer-tweak rules.
- Plain node-mode tests should not add a direct `vitest` dependency; direct Vitest users and browser-mode projects may still need pinned upstream Vitest packages that match the bundled version.
- If browser tests fail with `vitest/internal/browser` resolution errors under pnpm, add direct `vitest` in the package that runs browser tests at the bundled version, then reinstall cleanly if stale peer variants remain.
