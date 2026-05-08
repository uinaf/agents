# Bootstrap

Use this reference when starting a new repo on Vite+ or converting an existing one.

## Prerequisites

- Vite 8 or newer.
- Vitest 4.1 or newer.

Vite+ does not support older upstream versions. Upgrade Vite and Vitest in the existing project first if needed.

## New Repo

1. Use `vp create` to scaffold the closest stock shape. `vp create` ships built-in templates (`vite:monorepo`, `vite:application`, `vite:library`, `vite:generator`) plus shorthand and remote sources.
2. Keep package manager and workspace settings consistent with the repo standard.
3. Prefer `vp check`, `vp test`, and `vp build` or `vp pack` from day one.
4. `vp create` writes `npm.scriptRunner: "vp"` into `.vscode/settings.json` automatically. Keep it unless the team has not adopted `vp` locally.

## Existing Repo

1. Audit current scripts, CI, test imports, package manager, and packaging flow before migrating.
2. Use `vp migrate` as the default starting point instead of a hand-rolled conversion. Pass `--agent <name>` and `--editor <name>` to write agent and editor config in the same pass; pass `--no-interactive` for non-interactive runs.
3. After running `vp migrate`, confirm `vite` imports were rewritten to `vite-plus` and `vitest` imports were rewritten to `vite-plus/test` before removing the old dependencies.
   - In a monorepo, prefer running `vp create` and `vp migrate` against the workspace root with `--editor <name>` once. Use `--no-editor` when generating per-package apps or libraries so each leaf does not generate its own `.vscode/` or `.zed/` settings that conflict with the root configuration.
4. If Vite+ is already installed, inspect its packaged guidance files first. A common location is `node_modules/vite-plus/AGENTS.md` plus the bundled `node_modules/vite-plus/docs/`. Use whatever `AGENTS.md`, `CLAUDE.md`, or rules file ships with the installed toolchain.
5. Reconcile generated files with the repo's real guardrails and release flow instead of assuming stock output is final.
6. Keep useful generated agent guidance, but merge it into the repo's real guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules instead of accepting generic Vite+ boilerplate unchanged.
7. Treat the machine-global `vp` binary and the repo-local `vite-plus` package as separate upgrade surfaces. `vp upgrade` updates the global CLI, while project dependencies should move with `vp update ...` inside the repo.

## Notes

- Vite+ detects the package manager from the workspace in this order: `packageManager` in `package.json`, `pnpm-workspace.yaml`, `pnpm-lock.yaml`, `yarn.lock` / `.yarnrc.yml`, `package-lock.json`, `bun.lock` / `bun.lockb`, then a few config-only fallbacks. With none of those, `vp` falls back to `pnpm`.
- Prefer a single coherent migration over partial adoption that leaves scripts, imports, and CI out of sync.
- Validate migrations with `vp env current`, `vp install`, `vp check`, `vp test`, and then `vp build` or `vp pack` as appropriate.
