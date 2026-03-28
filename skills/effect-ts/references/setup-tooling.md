# Setup And Tooling

Use this file when bootstrapping an Effect repo, auditing project setup, or deciding which packages and compiler settings belong in the project.

## Source Notes

- `effect-solutions` is the opinionated setup guide and recommends the language service, strict TypeScript defaults, and a local Effect source checkout.
- `effect.website` is the canonical reference for runtime, config, and package APIs.
- The Effect monorepo confirms current package names such as `effect`, `@effect/platform`, `@effect/cli`, `@effect/vitest`, and `@effect/platform-node`

## Package Selection

- Install `effect` in every Effect project.
- Add `@effect/platform` for HTTP clients, filesystem, platform services, and general app integration.
- Add exactly one platform runtime package for the host:
  - `@effect/platform-node`
  - `@effect/platform-bun`
  - `@effect/platform-browser`
- Add `@effect/cli` for CLIs.
- Add `vitest` and `@effect/vitest` for tests.
- Do not install `@effect/schema` for new work — `Schema` lives in `effect`

## Language Service

`effect-solutions` recommends installing `@effect/language-service` and wiring it into `tsconfig.json`

```json
{
  "compilerOptions": {
    "plugins": [
      {
        "name": "@effect/language-service"
      }
    ]
  }
}
```

For VS Code or Cursor, prefer workspace TypeScript:

```json
{
  "typescript.tsdk": "./node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true
}
```

If the project wants build-time diagnostics, run `effect-language-service patch` and persist it via a `prepare` script.

## TypeScript Defaults

From `effect-solutions`, these are the main defaults worth checking before code changes:

- `strict: true`
- `exactOptionalPropertyTypes: true`
- `noUnusedLocals: true`
- `noImplicitOverride: true`
- `verbatimModuleSyntax: true`
- `incremental: true` and `composite: true` when the repo benefits from project references

Module settings depend on the project shape:

- Bundled apps: use `"module": "preserve"` with `"moduleResolution": "bundler"`
- Node apps and libraries: use `"module": "NodeNext"`

## Local Reference Checkout

`effect-solutions` recommends cloning the Effect repo locally so agents can grep real implementations when docs are not enough. If the repo already has a local reference path in `AGENTS.md` or `CLAUDE.md`, use that before browsing the web.

## Setup Audit Checklist

1. Inspect `package.json`, lockfiles, and `tsconfig*`
2. Check whether the repo already uses Effect and which runtime package it uses.
3. Check whether `@effect/language-service` is present and configured.
4. Confirm test tooling and scripts.
5. Confirm the platform package matches the host runtime.
6. Check for stale or deprecated packages before adding anything new.

## Validation

- Run the repo's existing install, typecheck, lint, and test commands.
- If you changed compiler settings, run a real `tsc`-backed check, not only the editor.
- If you changed runtime packages, run one representative entrypoint after install.
