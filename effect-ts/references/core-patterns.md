# Core Patterns

Use this file when writing or reviewing ordinary Effect application code: sequencing, services, layers, schemas, errors, config, and tests.

## Source Notes

- `effect-solutions` topics: `basics`, `services-and-layers`, `data-modeling`, `error-handling`, `config`, `testing`
- Official docs: runtime, configuration, schema, testing, and getting-started execution guides.

## Execution Style

- Use `Effect.gen` for inline effect programs.
- Use `Effect.fn("Name")` for reusable named effectful functions. This gives call-site tracing and is the default for service methods.
- Use `.pipe(...)` for cross-cutting behavior such as `Effect.timeout`, `Effect.retry`, `Effect.tap`, and `Effect.withSpan`

Default split:

- One-off workflow in a single module: `Effect.gen`
- Reused operation or service method: `Effect.fn`

## Services And Layers

Model dependencies explicitly.

- Define services with `Context.Tag` when you want a stable contract plus multiple implementations.
- Use unique identifiers like `@app/Users` or `@app/EmailService`
- Keep service methods `readonly`
- Prefer service methods that do not require extra environment. Push dependencies into the layer graph instead of the method signature.

Implementation defaults:

- `Layer.succeed` for simple constants or test doubles.
- `Layer.sync` for synchronous setup.
- `Layer.effect` for effectful setup that depends on other services.

Testing defaults:

- Give important services a `testLayer` when that improves reuse and readability.
- Compose layers rather than mocking every callsite manually.

## Schema And Domain Modeling

Treat `Schema` as the default boundary and domain-modeling tool.

- Use `Schema.Class` for records with behavior.
- Use `Schema.TaggedClass` plus `Schema.Union` for structured variants.
- Brand nearly every meaningful primitive, not only IDs.
- Use `Schema.parseJson` when the input is a JSON string boundary.
- Decode once at the edge, then carry typed values through the core.

Good fits for brands:

- IDs
- emails
- slugs
- ports
- URLs
- timestamps
- counts with business meaning

## Errors

Recoverable failures should usually be tagged, typed, and serializable.

- Use `Schema.TaggedError` for domain and boundary errors.
- Use unions for multi-case error channels.
- Use `Effect.catchTag` or `Effect.catchTags` for narrow recovery.
- Reserve defects for programmer bugs or truly unexpected failures.

Review smell:

- `Effect.Effect<A, string>` or `unknown` in stable domain services is often too weak.
- Converting every failure to `Error` usually throws away useful structure.

## Config

Use `Config` at the edge and expose validated config through a service layer.

- Default provider is environment variables.
- Prefer `Config.redacted` for secrets.
- Prefer a `Context.Tag` config service with `layer` and, when useful, `testLayer`
- Use `ConfigProvider.fromMap` or another explicit provider in tests.

## Testing

Prefer `@effect/vitest` for Effect code.

- Use `it.effect` for effect-returning tests.
- Use `it.scoped` for scoped resources.
- Use test layers for dependencies.
- Use `TestClock` and `TestRandom` when time or randomness matters.

## Common Anti-Patterns

- Calling `Effect.runPromise` in the middle of application logic.
- Returning `Promise` from service methods when a plain `Effect` can cross the boundary instead.
- Passing raw JSON or environment strings deep into the core.
- Replacing layer composition with manually threaded globals.
- Using wide `unknown` error channels where a tagged union is feasible.
