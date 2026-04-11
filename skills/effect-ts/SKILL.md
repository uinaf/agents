---
name: effect-ts
description: "Implement, debug, refactor, migrate, review, or explain Effect TypeScript code. Use when a task touches `effect` or `@effect/*` APIs, especially services, layers, schemas, runtime wiring, platform or CLI packages, Effect testing, or Promise-to-Effect migration."
---

# Effect TS

Write idiomatic Effect code instead of promise-shaped TypeScript with Effect wrappers pasted on top.

## Start

1. Inspect the repo first: `package.json`, `tsconfig*`, lockfile, existing `effect` / `@effect/*` imports, and nearby tests.
2. Match the task to the smallest useful reference set below.
3. If `effect-solutions` is installed, run `effect-solutions list` and `effect-solutions show <topic>...` before freehanding a pattern.
4. Follow local repo conventions before importing a new Effect pattern.

## Read By Task

- Setup, install, tsconfig, or repo audit → `references/setup-tooling.md`
- Core application code → `references/core-patterns.md`
- HTTP, CLI, platform, or stream work → `references/ecosystem-patterns.md`
- Promise interop, framework boundaries, runtime issues, or gradual migration → `references/adoption-runtime.md`

## Topic Map

- `effect-solutions show project-setup tsconfig` for bootstrap work.
- `effect-solutions show basics services-and-layers data-modeling error-handling config testing` for core application code.
- `effect-solutions show http-clients cli use-pattern` for ecosystem and integration work.
- Use `effect.website/docs` for deeper API detail, exhaustive module surfaces, and topics not yet covered here.

## Defaults

- Use `Effect.gen` for inline programs and `Effect.fn("Name")` for reusable named effectful functions.
- Keep `Effect.run*` at app edges, tests, workers, or framework adapters.
- Put dependencies in services and layers, not hidden globals.
- Parse external data once at the boundary with `Schema`, then pass typed values inward.
- Model recoverable failures with tagged errors and narrow unions.
- Prefer test layers and `@effect/vitest` over ad hoc mocks.

```ts
const loadUser = Effect.fn("loadUser")(function* (id: UserId) {
  const repo = yield* UserRepo
  return yield* repo.get(id)
})

const program = Effect.gen(function* () {
  const input = yield* Schema.decodeUnknown(UserInput)(payload)
  return yield* loadUser(input.id)
})
```

## Source Order

1. Use local project code and tests as the primary contract.
2. Use `effect-solutions` for opinionated patterns and tradeoffs.
3. Use `effect.website` for the canonical API surface.
4. If a local clone of the Effect repo exists, grep it for real implementations before guessing.

## Avoid

- Returning raw `Promise` values from service methods unless the boundary forces it.
- Calling `Effect.runPromise` deep inside domain code.
- Using string errors when a tagged error should exist.
- Re-validating already parsed domain data in the core.
- Reaching for advanced abstractions before the simpler service / layer / schema model fits.
