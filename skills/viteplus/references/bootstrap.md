# Bootstrap

Use this reference when starting a new repo on VitePlus or converting an existing one.

## New Repo

1. Use `vp create` to scaffold the closest stock shape.
2. Keep package manager and workspace settings consistent with the repo standard.
3. Prefer `vp check`, `vp test`, and `vp build` or `vp pack` from day one.

## Existing Repo

1. Audit current scripts, CI, test imports, package manager, and packaging flow before migrating.
2. Use `vp migrate` as the default starting point instead of a hand-rolled conversion.
3. If Vite+ is already installed, inspect its packaged guidance files first. A common location is `node_modules/vite-plus/AGENTS.md`, but use whatever `AGENTS.md`, `CLAUDE.md`, or rules file ships with the installed toolchain.
4. Reconcile generated files with the repo's real guardrails and release flow instead of assuming stock output is final.
5. Keep useful generated agent guidance, but merge it into the repo's real guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules instead of accepting generic VitePlus boilerplate unchanged.
6. Treat the machine-global `vp` binary and the repo-local `vite-plus` package as separate upgrade surfaces. `vp upgrade` updates the global CLI, while project dependencies should move with `vp update ...` inside the repo.

## Notes

- VitePlus detects the package manager from the workspace, including `packageManager`, `pnpm-workspace.yaml`, and lockfiles.
- Prefer a single coherent migration over partial adoption that leaves scripts, imports, and CI out of sync.
- Validate migrations with `vp env`, `vp install`, `vp check`, `vp test`, and then `vp build` or `vp pack` as appropriate.
