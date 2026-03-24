# Adoption And Runtime

Use this file for Promise interop, framework integration, runtime questions, and debugging missing services or awkward Effect migrations.

## Incremental Adoption

Adopt Effect at boundaries first.

Good starting points:

- new features
- flaky integrations
- IO-heavy workflows
- places with repeated validation or ad hoc error handling

Bad starting points:

- stable low-risk code with no current pain
- hot paths where a large rewrite would be risky without profiling

## Promise Interop

Wrap Promise APIs instead of letting them leak through the codebase.

- Use `Effect.tryPromise` when the Promise can reject or throw.
- Use `Effect.promise` when the Promise is already trustworthy and failure semantics are clear.
- Preserve cancellation when the underlying API accepts `AbortSignal`

Prefer a narrow wrapper at the boundary instead of sprinkling Promise conversion throughout the app.

## The `use` Pattern

`effect-solutions` documents a practical `use` pattern for third-party libraries with wide Promise APIs.

Shape:

- expose a service with a `use` method
- pass the underlying client plus `AbortSignal` into a callback
- convert thrown errors into a tagged error type

Use this when a library has many operations and writing a fully wrapped service API would create noise. Do not use it when a handful of explicit methods would be clearer.

## Runtime Boundaries

Official runtime docs emphasize that `Effect.run*` executes a blueprint. Keep those calls at program edges.

Good places for `Effect.run*`:

- CLI entrypoints
- HTTP server startup
- worker startup
- test harnesses
- thin framework adapters

Bad places for `Effect.run*`:

- domain services
- repositories
- utility modules reused by other Effect code

## ManagedRuntime

Use `ManagedRuntime.make(layer)` when an external framework or host environment needs to execute Effect code repeatedly but does not naturally own the main Effect entrypoint.

Good fits:

- React or framework callbacks
- non-Effect server adapters
- background hooks or plugin systems

## Debugging Missing Requirements

When an effect will not compose because of missing services:

1. Read the environment type first.
2. Find which service tags are still required.
3. Check whether an existing layer already provides them.
4. Compose or provide layers at the boundary instead of pushing `R` requirements deeper.

## Debugging Failures

- Prefer named `Effect.fn` functions so traces and spans are readable.
- Use `Effect.either` when you want to inspect failures without crashing the flow.
- Use `Effect.runPromiseExit` when defects or interruption matter during debugging.
- Keep logs and spans close to boundaries and important service calls.

## Review Smells During Migration

- `async` functions returning `Effect` values or mixing `await` with `yield*`
- Repeated `Effect.runPromise` inside handlers that should stay inside Effect.
- Promise wrappers that lose cancellation or collapse typed errors to `unknown`
- Partial migration where schemas and tagged errors exist but raw objects still flow through the core.
