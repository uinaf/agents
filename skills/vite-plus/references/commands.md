# Commands

Use this reference before changing command invocations, package-manager usage, or script wiring in a Vite+ repo.

## Defaults

- Treat `vp` as the tool owner for runtime, package-manager, and frontend-tooling operations.
- Do not use `pnpm`, `npm`, or `yarn` directly when Vite+ is the tool owner; use `vp install`, dependency subcommands, or `vp pm` instead.
- Do not invent nonexistent commands such as `vp vitest` or `vp oxlint`; use the built-in `vp test`, `vp lint`, `vp fmt`, and `vp check`.
- Built-in commands cannot be overridden by same-named scripts. `vp build` always runs the built-in Vite build; use `vp run build` (or `vpr build`) to execute a `package.json` `build` script.
- `vpr` is a standalone shorthand for `vp run`. Use whichever the repo prefers; do not mix the two in the same scripts block.
- Distinguish global upgrades from repo-local upgrades: `vp upgrade` updates the global CLI, while `vp update ...` updates project dependencies.

## Runtime and Package Manager

- `vp env` owns Node.js version management. Use `vp env current` for verification and `vp env use` when a repo needs to set or switch Node versions.
- `vp install` owns install/bootstrap. It detects the package manager from the repo; do not add Corepack or direct package-manager setup beside it unless the repo has a proven exception.
- `vp rebuild` rebuilds native modules after Node.js changes. It is shorthand for `vp pm rebuild`.

## Built-ins vs Scripts

- Built-in commands such as `vp dev`, `vp build`, `vp preview`, `vp test`, `vp lint`, `vp fmt`, and `vp check` do not run same-named `package.json` scripts.
- Use `vp run <script>` for repo-defined scripts that Vite+ does not replace directly.
- If a task needs caching, dependency ordering, or environment/input control, define it in the `run.tasks` block in `vite.config.ts` instead of leaving it as a plain package script. Tasks defined in `vite.config.ts` are cached by default; `package.json` scripts are not.
- For one-off cache opt-in on a script, use `vp run --cache <script>` or set `run.cache.scripts: true` in `vite.config.ts`.

## Check Commands

- `vp check` runs format, lint, and type checks together.
- Use `vp check --no-lint` for a type-check-only workflow instead of reaching for raw `tsc` when Vite+ owns the repo.
- Use `vp lint` or `vp fmt` only when the workflow genuinely needs the narrower pass; `vp check` is the default gate.

## Test Commands

- `vp test` does a one-shot run by default — unlike raw Vitest, it does not stay in watch mode.
- Use `vp test watch` for watch mode and `vp test run --coverage` for coverage.
- See `references/testing.md` for import surface and config rules.

## Native Modules and Binaries

- `vpx <pkg[@version]>` runs a local or remote binary, downloading on demand.
- `vp exec <bin>` runs a binary from the project's `node_modules/.bin`.
- `vp dlx <pkg>` runs a one-off package binary without adding it to dependencies.

## Upgrades

- Use `vp upgrade` to update the global `vp` binary on the machine.
- Use `vp update vite-plus` to move the local `vite-plus` package forward in a repo.
- Vite+ aliases `vite` and `vitest` to `npm:@voidzero-dev/vite-plus-core@latest` and `npm:@voidzero-dev/vite-plus-test@latest`. `vp update vite-plus` does not re-resolve those aliases — update them explicitly with `vp update @voidzero-dev/vite-plus-core @voidzero-dev/vite-plus-test` so the lockfile fully re-resolves the Vite+ stack.
- Use `vp outdated` to confirm whether any Vite+ packages remain behind the intended release.

## Validation Path

- Prefer the standard migration validation sequence: `vp env current`, `vp install`, `vp check`, `vp test`, then `vp build` or `vp pack` as appropriate.
