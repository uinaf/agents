# Monorepos

Use this reference for workspace repos adopting VitePlus.

## Defaults

- Move workspace scripts, test surface, and CI together instead of partially migrating leaf packages.
- Keep workspace package-manager conventions and cache boundaries unless VitePlus replaces them cleanly.
- Leaf packages and apps should still prefer `vp check`, `vp test`, and `vp pack` where VitePlus is the real tool owner.
- Use `vp run <pkg>#<task>`, `vp run -r`, `vp run -t`, and `vp run --filter` instead of inventing custom workspace task wrappers when VitePlus already owns the task graph.
- Keep commit-hook setup repo-wide: prefer one `vp config`-managed `.vite-hooks` install plus staged checks in root `vite.config.ts` over per-package hook tooling.

## Orchestration with `vp run`

`vp run` reads the same workspace dependency graph that the package manager already uses — regular `dependencies` (and `workspace:*`) in each `package.json`. There is no separate task-runner config to maintain.

Three flags cover almost all root-level orchestration:

| Flag | Selects | Order | Use when |
| ---- | ------- | ----- | -------- |
| `vp run <pkg>#<task>` | one package | n/a | Targeted action against a single package |
| `vp run -t <pkg>#<task>` | a package and all of its workspace deps | topological (deps first) | Build chains, deploy commands, anything that needs upstream artifacts ready |
| `vp run -r <task>` | every workspace package that defines `<task>` | topological by default; `--parallel` ignores order | Repo-wide passes (test, check, dev) |

### Pattern: build chain for CI / deploy

Use `vp run -t` for any "build the consumer and everything it depends on" command. The classic case is a demo app that bundles a sibling library:

```json
{
  "scripts": {
    "build:example": "vp run -t @scope/example#build"
  }
}
```

This is the right shape for Cloudflare Pages, Vercel, or any CI step that takes a single root-level command and expects all transitive artifacts to land. The dependency order comes from `apps/example/package.json` declaring `"<lib>": "workspace:*"`.

### Pattern: parallel dev with a one-shot library seed

A demo app that consumes the library's published artifact (via the library's `exports` map → `dist/`) needs the library's `dist/` to exist before its dev server can resolve imports. The library's dev script is typically a watch task (`vp pack --watch`) that never returns — so a sequential `vp run -t example#dev` blocks forever on the watch and never starts the demo.

Seed the library once, then start every package's `dev` task in parallel:

```json
{
  "scripts": {
    "dev:example": "vp run <lib>#build && vp run -r --parallel dev"
  }
}
```

After the seed, the demo's Vite dev server resolves `<lib>` against `dist/index.mjs`, and HMR flows through to library code on subsequent edits via the lib's watch loop.

### Build-first vs source-alias for a demo app

Two valid patterns for "demo app inside a publishable-library monorepo":

- **Build-first (default for OSS / publishable libraries).** Demo bundles the library's published `dist/` artifact. A green deploy proves what npm consumers will install actually resolves end-to-end. Slightly slower; requires the `vp run -t` chain above. Recommended when the demo deploy doubles as integration verification of the published shape.
- **Source alias.** Demo's Vite config aliases the library name to `../packages/<lib>/src/index.ts`. Faster, no chain needed, full HMR for free. But the demo no longer validates the published artifact, so a broken `exports` map or missing `files` entry only surfaces when a real consumer installs the package.

For OSS or published libraries, prefer build-first. For a purely internal demo whose only job is fast iteration, source alias is fine.

## Don't blindly migrate every script to `vp run`

`vp run -r` and `vp run -t` earn their keep when there is cross-package ordering or a transitive dependency to walk. For leaf-only tasks that just fan out the same command in every package — `test`, `check`, `verify` — `pnpm -r run <task>` (or the equivalent for the active package manager) is the same shape with one less abstraction. Real-world reference from a verified two-package repo:

```json
{
  "scripts": {
    "build": "vp run <lib>#build",
    "build:example": "vp run -t @scope/example#build",
    "dev:example": "vp run <lib>#build && vp run -r --parallel dev",
    "preview:example": "vp run @scope/example#preview",
    "test": "pnpm -r run test",
    "check": "pnpm -r run check",
    "verify": "pnpm -r run verify"
  }
}
```

The split is intentional: anything that walks the workspace graph goes through `vp run`; anything that just iterates leaves stays on the package manager's recursive runner.

## Graduating to `vite.config.ts` task definitions

`vp run` of a `package.json` script is uncached by default. Tasks defined in the root `vite.config.ts` `run.tasks` block are cached by default and can declare `dependsOn: ['<otherpkg>#<task>']` to express ordering inline. When CI build chains start to dominate wall-clock time, move the orchestrating task into `vite.config.ts` to pick up caching for free:

```ts
import { defineConfig } from 'vite-plus';

export default defineConfig({
  run: {
    tasks: {
      'build:example': {
        command: 'vp run @scope/example#build',
        dependsOn: ['<lib>#build'],
      },
    },
  },
});
```

This is a follow-up, not a day-one migration. Land the script-based orchestration first, measure, then promote the hot paths.

## Pitfall: `pnpm --filter "...<pkg>"` does not include workspace deps reliably

Per the pnpm documentation, `--filter "...<pkg>"` should select `<pkg>` and all of its workspace dependencies. In practice on `pnpm@10.33.2` driving `pnpm run`, the leading-ellipsis filter matched only the leaf package — workspace dependencies were not included even with `pnpm -r`. Verify in any repo with:

```bash
pnpm -r --filter '...<pkg>' list --depth -1
```

If only one package is listed, use `vp run -t <pkg>#<task>` for transitive builds instead of trying to coerce pnpm's filter. `vp run -t` walks the same workspace dependency graph and gives the expected topological order.

## Guardrails

- Do not force VitePlus onto non-frontend or non-Node packages.
- Keep workspace-specific caching and dependency ordering rules if VitePlus does not fully cover them yet.
- Verify the important leaf packages still build and test after the migration.
- Do not invent an extra task-runner config (Turborepo, Nx, custom shell wrappers) just to express ordering — `vp run -t` already reads the workspace dependency graph.
