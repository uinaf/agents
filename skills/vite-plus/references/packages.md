# Packages

Use this reference for standalone package repos adopting Vite+.

## Defaults

- Prefer `vp pack` for libraries and standalone executables (`pack.exe = true` for native binaries).
- Prefer `vp check` and `vp test` as the default verify surface.
- Keep `pack` config in `vite.config.ts` instead of maintaining a parallel `tsdown.config.ts`. After migrating, delete the standalone `tsdown.config.ts`.

## Aliased Dependencies

- `pnpm` repos should add overrides for Vite+ wrapped `vite` and `vitest`:

  ```yaml
  # pnpm-workspace.yaml
  overrides:
    vite: npm:@voidzero-dev/vite-plus-core@latest
    vitest: npm:@voidzero-dev/vite-plus-test@latest
  ```

- `npm` projects use `overrides` in `package.json`; Yarn projects use `resolutions`.

## Notes

- `vp pack --watch` is the watch-mode equivalent for libraries; pair it with `vp run -r --parallel dev` in monorepos that consume the library via `dist/`.
- Keep SDK, codegen, or bootstrap steps that Vite+ does not replace.
- Update docs when install, test, or packaging commands change.
