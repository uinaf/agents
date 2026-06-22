# Packages

Use this reference for standalone package repos adopting Vite+.

## Defaults

- Prefer `vp pack` for libraries and standalone executables (`pack.exe = true` for native binaries).
- Prefer `vp check` and `vp test` as the default verify surface.
- Keep `pack` config in `vite.config.ts` instead of maintaining a parallel `tsdown.config.ts`. After migrating, delete the standalone `tsdown.config.ts`.

## Aliased Dependencies

- In standalone packages, declare `vite` directly in `devDependencies` as the Vite+ core alias, even if no source file imports Vite:

  ```json
  {
    "devDependencies": {
      "vite": "npm:@voidzero-dev/vite-plus-core@<matching-vite-plus-version>",
      "vite-plus": "^<matching-vite-plus-version>"
    }
  }
  ```

  This gives pnpm a concrete importer for the aliased `vite` name. An override alone can leave Vitest and Vite+ peer contexts locked against upstream `vite@8.x` instead of `@voidzero-dev/vite-plus-core`.

- `pnpm` repos should keep the `vite` override pointed at Vite+ core:

  ```yaml
  # pnpm-workspace.yaml
  overrides:
    vite: npm:@voidzero-dev/vite-plus-core@<matching-vite-plus-version>
  ```

  For single-package pnpm repos, add `packages: ["."]` or the block form below if the workspace file would otherwise contain only settings:

  ```yaml
  packages:
    - "."

  overrides:
    vite: npm:@voidzero-dev/vite-plus-core@<matching-vite-plus-version>
  ```

- `npm` projects use `overrides` in `package.json`; Yarn projects use `resolutions`.
- After reinstalling, check that `pnpm-lock.yaml` records the importer `vite` specifier as `npm:@voidzero-dev/vite-plus-core@<version>` and the version as `@voidzero-dev/vite-plus-core@...`; do not stop at `pnpm config get overrides`.
- In Vite+ 0.2.x and newer, do not alias `vitest` to `@voidzero-dev/vite-plus-test`; that wrapper was removed. Plain node-mode tests should not list `vitest` directly. Keep or add direct upstream `vitest` / `@vitest/*` dependencies only for direct Vitest API usage, coverage/UI packages, or browser-mode requirements.

## Notes

- `vp pack --watch` is the watch-mode equivalent for libraries; pair it with `vp run -r --parallel dev` in monorepos that consume the library via `dist/`.
- Keep SDK, codegen, or bootstrap steps that Vite+ does not replace.
- Update docs when install, test, or packaging commands change.
