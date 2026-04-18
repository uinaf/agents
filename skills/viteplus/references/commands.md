# Commands

Use this reference before changing command invocations, package-manager usage, or script wiring in a Vite+ repo.

## Defaults

- Treat `vp` as the tool owner for runtime, package-manager, and frontend-tooling operations.
- Do not use `pnpm`, `npm`, or `yarn` directly when Vite+ is the tool owner; use `vp install`, dependency subcommands, or `vp pm` instead.
- Do not invent nonexistent commands such as `vp vitest` or `vp oxlint`; use the built-in `vp test` and `vp lint` commands.
- Distinguish global upgrades from repo-local upgrades: `vp upgrade` updates the global CLI, while `vp update ...` updates project dependencies.

## Built-ins vs Scripts

- Built-in commands such as `vp build`, `vp test`, and `vp dev` do not run same-named `package.json` scripts.
- Use `vp run <script>` for repo-defined scripts that Vite+ does not replace directly.
- If a task needs caching, dependency ordering, or environment/input control, define it in the `run` block in `vite.config.ts` instead of leaving it as a plain package script.

## Upgrades

- Use `vp upgrade` to update the global `vp` binary on the machine.
- Use `vp update vite-plus` to move the local `vite-plus` package forward in a repo.
- When the repo uses Vite+'s aliased core packages, update them explicitly with `vp update @voidzero-dev/vite-plus-core @voidzero-dev/vite-plus-test` so the lockfile fully re-resolves the Vite+ stack.
- Use `vp outdated` to confirm whether any Vite+ packages remain behind the intended release.

## Validation Path

- Prefer the standard migration validation sequence: `vp env`, `vp install`, `vp check`, `vp test`, then `vp build` or `vp pack` as appropriate.
