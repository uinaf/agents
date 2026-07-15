---
name: vite-plus
description: "Migrate or align frontend package and monorepo repositories to Vite+. Use when the user asks to migrate to Vite+, standardize on `vp`, clean up a Vite+ setup, or move CI, tests, packaging, and hooks onto the stock Vite+ workflow. Prefer Vite+ commands over direct package-manager and Vitest wiring unless the repo has a proven exception."
---

# Vite+

Move a frontend repo closer to the stock Vite+ toolchain while preserving repo-specific release and runtime logic. Vite+ is in beta, but still pre-1.0: verify behavior against installed `vp --version`, packaged docs under `node_modules/vite-plus/docs/`, and the latest [release notes](https://github.com/voidzero-dev/vite-plus/releases) instead of relying on memorized command shapes.

## Migration Targets

Default to this destination unless a repo-specific boundary clearly blocks it. If you keep an old command shape, document the reason.

- CI uses `voidzero-dev/setup-vp`; the action owns Node and package-manager bootstrap. Let its default `run-install: true` run `vp install`, then run `vp check`, `vp test`, and `vp build`; set `run-install: false` only when the workflow needs an explicit install step. In repos that pin GitHub Actions, pin `setup-vp` to a full commit SHA with a same-line exact version comment and let Dependabot maintain it
- Tooling versions have one checked-in source of truth. Node comes from `.node-version`; package-manager versions come from `package.json#packageManager`; Vite+ comes from the repo's `vite-plus` dependency or workspace catalog. Do not repeat Node, pnpm, or Vite+ literals in workflows when a source file can be read
- test files use `vite-plus/test` (and `vite-plus/test/browser/context` for browser mode); Vite+ 0.2.x runs upstream Vitest directly and no longer uses `@voidzero-dev/vite-plus-test`
- scripts prefer `vp dev`, `vp test`, `vp test watch`, `vp test run --coverage`, `vp pack`, `vp build`, `vp preview`, and `vp run <script>` (or `vpr <script>`) over direct package-manager, raw Vitest, or tsdown wiring
- hooks use `vp config`, `.vite-hooks`, and `vp staged` as the default hook stack
- single-source config in `vite.config.ts`: no parallel `vitest.config.ts`, `.oxlintrc*`, `.oxfmtrc*`, or `tsdown.config.ts`
- project agent guidance comes from Vite+ itself when possible: `vp migrate --agent <name>` writes the official short `AGENTS.md`/`CLAUDE.md` block, and installed projects may expose the same guidance at `node_modules/vite-plus/AGENTS.md`
- contributor docs move to the new `vp` commands in the same change

## Workflow

1. Confirm the project is on Vite 8+ and, when it directly depends on Vitest or `@vitest/*`, Vitest 4.1+.
2. Audit current scripts, workflows, Vite config, test imports, release flow, package manager, and packaging.
3. Read [references/bootstrap.md](references/bootstrap.md) for entrypoints (`vp create`, `vp migrate`), editor/agent config, local guidance-file discovery, and validation path.
4. Pick the shape and load only that reference: [references/packages.md](references/packages.md) for standalone packages, or [references/monorepos.md](references/monorepos.md) for workspaces.
5. Migrate scripts, `vite.config.ts`, test imports, hooks, and packaging together. Verify with `vp check && vp test` before moving on.
6. Update CI per [references/ci-cd.md](references/ci-cd.md).
7. Update tests and coverage per [references/testing.md](references/testing.md).
8. Check [references/commands.md](references/commands.md) before changing command invocations. Load [references/known-issues.md](references/known-issues.md) only on unexpected behavior or when upgrading Vite+.
9. Keep repo-specific release, binary, or packaging steps Vite+ does not replace. Verify jobs may use Vite+ dependency caches; secret-bearing release, publish, signing, and deploy jobs disable dependency caches and run fresh installs.
10. To adopt a newer Vite+ release: `vp upgrade` updates the global CLI; then run `vp migrate` in the project. On an existing Vite+ project it defaults to a version-only upgrade: it re-pins `vite-plus`, the required `vite` -> `@voidzero-dev/vite-plus-core` alias, and Vitest-related pins across workspace packages. Use `vp migrate --full` only when you also want the first-time setup bucket (hooks, editor files, agent files, lint migration). Confirm with `vp --version`, lockfile inspection, and `vp outdated`.
11. End-to-end validation: `vp install && vp check && vp test`, then verify `vp build` or `vp pack` artifacts, `vp preview` where applicable, `vp test run --coverage`, and `vp staged` on a staged change.

## Tooling Source Of Truth

Before changing CI, preserve one canonical version owner:

- Node: `.node-version`; wire it through `node-version-file: ".node-version"`
- package manager: `package.json#packageManager`
- Vite+: the `vite-plus` dependency or workspace catalog; when CI needs an explicit `version`, derive it from that source with a structured parser
- Vite core: keep the `vite` manifest dependency plus package-manager override/catalog/resolution pointed at the matching `npm:@voidzero-dev/vite-plus-core@<version>`
- Vitest: do not add a `vitest` override for node-mode-only Vite+ 0.2.x projects; add direct Vitest and `@vitest/*` packages only when the project uses Vitest APIs, coverage packages, UI, or browser providers directly
- workflow exceptions: document why the action cannot read the repo-owned source
- Docker: for containerized builds, prefer the official `ghcr.io/voidzero-dev/vite-plus` toolchain image; do not use it as a production runtime image

Concrete shapes:

```yaml
- uses: voidzero-dev/setup-vp@<full-sha> # v1.x.y
  with:
    node-version-file: ".node-version"
    cache: true
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
- After editing workflows, grep for duplicated tooling literals such as `node-version:`, `pnpm@`, `corepack prepare`, and inline `version: "0.`. Keep action pins separate: GitHub Action SHAs and their same-line version comments are allowed because they identify the action, not the project toolchain.
- For cacheable `vp run` tasks, rely on automatic file tracking first. A standard `vp build` task now reports Vite inputs, outputs, and relevant env metadata to Vite Task, so do not add manual `input`, `output`, or `env` config unless the project has behavior Vite cannot report.
- If `vp check` is not running type-aware lint or type checks, confirm `lint.options.typeAware` and `lint.options.typeCheck` in `vite.config.ts`, and check for `compilerOptions.baseUrl` in `tsconfig.json` — `tsgolint` does not support `baseUrl` and Vite+ silently skips type-aware checks when it is present.

## Known Caveats

See [references/known-issues.md](references/known-issues.md) for current upstream caveats (SSR `instanceof` failures and Vite+ 0.2.x Vitest wrapper removal). Before preserving legacy wiring, reproduce the caveat on the installed release and inspect the upstream resolution for the first fixed version or upgrade path. A closed issue does not prove an older pinned release is unaffected.
