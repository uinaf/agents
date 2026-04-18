# Monorepos

Use this reference for workspace repos adopting VitePlus.

## Defaults

- Move workspace scripts, test surface, and CI together instead of partially migrating leaf packages.
- Keep workspace package-manager conventions and cache boundaries unless VitePlus replaces them cleanly.
- Leaf packages and apps should still prefer `vp check`, `vp test`, and `vp pack` where VitePlus is the real tool owner.
- Use `vp run @pkg/task`, `vp run -r`, `vp run -t`, and `vp run --filter` instead of inventing custom workspace task wrappers when VitePlus already owns the task graph.
- Keep commit-hook setup repo-wide: prefer one `vp config`-managed `.vite-hooks` install plus staged checks in root `vite.config.ts` over per-package hook tooling.

## Guardrails

- Do not force VitePlus onto non-frontend or non-Node packages.
- Keep workspace-specific caching and dependency ordering rules if VitePlus does not fully cover them yet.
- Verify the important leaf packages still build and test after the migration.
