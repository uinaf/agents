# Bootstrap

Use this reference when starting a new repo on Vite+ or converting an existing one.

## Prerequisites

- Vite 8 or newer.
- Vitest 4.1 or newer only when the repo directly depends on `vitest` or `@vitest/*`.

Vite+ does not support older upstream versions. In Vite+ 0.2.x and newer, node-mode tests normally get upstream Vitest transitively through `vite-plus`; upgrade direct Vitest ecosystem dependencies only when the project actually uses them.

## New Repo

1. Use `vp create` to scaffold the closest stock shape. `vp create` ships built-in templates (`vite:monorepo`, `vite:application`, `vite:library`, `vite:generator`) plus shorthand and remote sources. Pass `--git` or `--no-git` explicitly in automation so the scaffold does not stop on the interactive Git prompt.
2. Keep package manager and workspace settings consistent with the repo standard.
3. Prefer `vp check`, `vp test`, and `vp build` or `vp pack` from day one.
4. Let `vp create` own the first tooling pass when possible: recent Vite+ releases can migrate ESLint/Prettier-era defaults toward oxlint/oxfmt, select multiple editors, and write language-specific formatter overrides into editor settings.
5. `vp create` writes `npm.scriptRunner: "vp"` into `.vscode/settings.json` automatically. Keep it unless the team has not adopted `vp` locally.

## Existing Repo

1. Audit current scripts, CI, test imports, package manager, and packaging flow before migrating.
2. Use `vp migrate` as the default starting point instead of a hand-rolled conversion. Pass `--agent <name>` and `--editor <name>` to write agent and editor config in the same pass; pass `--no-interactive` for non-interactive runs.
3. After running `vp migrate`, confirm `vite` imports were rewritten to `vite-plus` and `vitest` imports were rewritten to `vite-plus/test` before removing the old dependencies.
   - In a monorepo, prefer running `vp create` and `vp migrate` against the workspace root with `--editor <name>` once. Use `--no-editor` when generating per-package apps or libraries so each leaf does not generate its own `.vscode/` or `.zed/` settings that conflict with the root configuration.
4. If Vite+ is already installed, inspect its packaged guidance files first. Recent releases ship docs directly at `node_modules/vite-plus/docs/`, and a common guidance entry is `node_modules/vite-plus/AGENTS.md`. Use whatever `AGENTS.md`, `CLAUDE.md`, or rules file ships with the installed toolchain.
5. Reconcile generated files with the repo's real guardrails and release flow instead of assuming stock output is final.
6. Keep useful generated agent guidance, but merge it into the repo's real guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules instead of accepting generic Vite+ boilerplate unchanged.
7. Treat the machine-global `vp` binary and the repo-local `vite-plus` package as separate upgrade surfaces. `vp upgrade` updates the global CLI, while project dependencies should move with `vp update ...` inside the repo.
8. For 0.1.x to 0.2.x upgrades, do not trust `vp migrate` as the only step. Remove `@voidzero-dev/vite-plus-test`, keep only the `vite` -> `@voidzero-dev/vite-plus-core` alias, and classify any direct Vitest, coverage, UI, or browser-provider usage before deciding which upstream Vitest packages must remain direct dependencies.

## Notes

- Vite+ detects the package manager from the workspace in this order: `packageManager` in `package.json`, `pnpm-workspace.yaml`, `pnpm-lock.yaml`, `yarn.lock` / `.yarnrc.yml`, `package-lock.json`, `bun.lock` / `bun.lockb`, then a few config-only fallbacks. With none of those, `vp` falls back to `pnpm`.
- `vp migrate` merges tool-specific config such as `.oxlintrc*`, `.oxfmtrc*`, and lint-staged config into `vite.config.ts`. Prefer that merge path before deleting old config files.
- Prefer a single coherent migration over partial adoption that leaves scripts, imports, and CI out of sync.
- Validate migrations with `vp env current`, `vp install`, `vp check`, `vp test`, and then `vp build` or `vp pack` as appropriate. Run `vp env doctor` when Node, npm, package-manager shims, or managed-runtime behavior looks inconsistent.
