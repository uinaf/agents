# Packages

Use this reference for standalone package repos adopting Vite+.

## Defaults

- Prefer `vp pack` for libraries and standalone executables (`pack.exe = true` for native binaries).
- Prefer `vp check` and `vp test` as the default verify surface.
- Keep `pack` config in `vite.config.ts` instead of maintaining a parallel `tsdown.config.ts`. After migrating, delete the standalone `tsdown.config.ts`.

## Aliased Dependencies

- `pnpm` repos should keep the `vite` override pointed at Vite+ core:

  ```yaml
  # pnpm-workspace.yaml
  overrides:
    vite: npm:@voidzero-dev/vite-plus-core@<matching-vite-plus-version>
  ```

- `npm` projects use `overrides` in `package.json`; Yarn projects use `resolutions`.
- In Vite+ 0.2.x and newer, do not alias `vitest` to `@voidzero-dev/vite-plus-test`; that wrapper was removed. Plain node-mode tests should not list `vitest` directly. Keep or add direct upstream `vitest` / `@vitest/*` dependencies only for direct Vitest API usage, coverage/UI packages, or browser-mode requirements.

## Notes

- `vp pack --watch` is the watch-mode equivalent for libraries; pair it with `vp run -r --parallel dev` in monorepos that consume the library via `dist/`.
- Keep SDK, codegen, or bootstrap steps that Vite+ does not replace.
- Update docs when install, test, or packaging commands change.
