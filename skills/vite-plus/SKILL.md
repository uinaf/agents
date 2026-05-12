---
name: vite-plus
description: "Migrate or align frontend repositories to the stock Vite+ workflow. Use when standardizing package or monorepo repos around `vp`, `voidzero-dev/setup-vp`, `vite-plus/test`, and Vite+ native CI, test, packaging, and hook flows. Default to replacing direct package-manager and Vitest wiring with the Vite+ equivalents unless the repo has a proven exception."
---

# Vite+

Move a frontend repo closer to the stock Vite+ toolchain while preserving repo-specific release and runtime logic. Vite+ is in alpha — verify behavior against installed `vp --version` and the latest [release notes](https://github.com/voidzero-dev/vite-plus/releases) instead of relying on memorized command shapes.

## Migration Targets

Default to this destination unless a repo-specific boundary clearly blocks it. If you keep an old command shape, document the reason.

- CI uses `voidzero-dev/setup-vp@v1`; the action owns Node and package-manager bootstrap, then runs `vp install`, `vp check`, `vp test`, `vp build`
- test files use `vite-plus/test` (and `vite-plus/test/browser/context` for browser mode)
- scripts prefer `vp dev`, `vp test`, `vp test watch`, `vp test run --coverage`, `vp pack`, `vp build`, `vp preview`, `vp update`, and `vp run <script>` (or `vpr <script>`) over direct package-manager, raw Vitest, or tsdown wiring
- hooks use `vp config`, `.vite-hooks`, and `vp staged` as the default hook stack
- single-source config in `vite.config.ts`: no parallel `vitest.config.ts`, `.oxlintrc*`, `.oxfmtrc*`, or `tsdown.config.ts`
- contributor docs move to the new `vp` commands in the same change

## Workflow

1. Confirm the project is on Vite 8+ and Vitest 4.1+ — Vite+ refuses older versions.
2. Audit current scripts, workflows, Vite config, test imports, release flow, package manager, and packaging.
3. Read [references/bootstrap.md](references/bootstrap.md) for entrypoints (`vp create`, `vp migrate`), editor/agent config, local guidance-file discovery, and validation path.
4. Pick the shape and load only that reference: [references/packages.md](references/packages.md) for standalone packages, or [references/monorepos.md](references/monorepos.md) for workspaces.
5. Migrate scripts, `vite.config.ts`, test imports, hooks, and packaging together. Verify with `vp check && vp test` before moving on.
6. Update CI per [references/ci-cd.md](references/ci-cd.md).
7. Update tests and coverage per [references/testing.md](references/testing.md).
8. Check [references/commands.md](references/commands.md) before changing command invocations. Load [references/known-issues.md](references/known-issues.md) only on unexpected behavior or when upgrading Vite+.
9. Keep repo-specific release, binary, or packaging steps Vite+ does not replace. Verify jobs may use Vite+ dependency caches; secret-bearing release, publish, signing, and deploy jobs disable dependency caches and run fresh installs.
10. To adopt a newer Vite+ release: `vp upgrade` (global), then `vp update vite-plus @voidzero-dev/vite-plus-core @voidzero-dev/vite-plus-test` (project). Confirm with `vp outdated`.
11. End-to-end validation: `vp env current && vp install && vp check && vp test`, then verify `vp build` or `vp pack` artifacts, `vp preview` where applicable, `vp test run --coverage`, and `vp staged` on a staged change.

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
import { defineConfig } from 'vite-plus'

export default defineConfig({
  lint: {
    options: { typeAware: true, typeCheck: true },
  },
  staged: {
    "*.{js,ts,tsx,vue,svelte}": "vp check --fix",
  },
})
```

```diff
 # package.json scripts
-"test": "vitest run --coverage",
-"test:watch": "vitest",
+"test": "vp test run --coverage",
+"test:watch": "vp test watch",
```

## Guardrails

- Prefer `vp create` / `vp migrate --agent <name> --editor <name>` over hand-rolling agent or editor config.
- Preserve working release workflows, binary packaging, and publish steps while migrating the surrounding Vite+ flow.
- If `vp check` is not running type-aware lint or type checks, confirm `lint.options.typeAware` and `lint.options.typeCheck` in `vite.config.ts`, and check for `compilerOptions.baseUrl` in `tsconfig.json` — `tsgolint` does not support `baseUrl` and Vite+ silently skips type-aware checks when it is present.

## Known Caveats

See [references/known-issues.md](references/known-issues.md) for current upstream caveats (single-file `vp check --fix`, SSR `instanceof` failures, Cloudflare Workers tests, `@vitest/coverage-v8` mixed-version warnings).
