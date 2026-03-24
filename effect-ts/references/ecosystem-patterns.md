# Ecosystem Patterns

Use this file for Effect packages beyond the core module: HTTP, CLI, platform services, streams, and schedules.

## HTTP Clients

`effect-solutions` recommends wrapping HTTP behavior in a service and keeping decoding close to the response.

Default pattern:

1. Provide an `HttpClient` implementation such as `FetchHttpClient.layer`
2. Build a client with request middleware such as `HttpClient.mapRequest(HttpClientRequest.prependUrl(...))`
3. Decode response bodies with `HttpClientResponse.schemaBodyJson(...)`
4. Match status codes explicitly when non-2xx outcomes are part of the contract.

Use a service when:

- the API has a stable domain contract
- auth, base URL, or headers repeat
- you want test doubles or shared retry logic

Use direct `HttpClient` calls when:

- the call is one-off
- the code is already at a thin integration boundary

## HttpApi

The platform package exports `HttpApi`, `HttpApiGroup`, `HttpApiEndpoint`, `HttpApiSchema`, `HttpApiBuilder`, and OpenAPI helpers.

Use `HttpApi` when you want:

- a typed endpoint description
- shared schema definitions across server and client
- generated or derived documentation
- stronger handler contracts than ad hoc router code

Do not force `HttpApi` into tiny endpoints if plain `HttpRouter` or a direct platform handler is already the simpler fit.

## CLI

`effect-solutions` treats `@effect/cli` as the standard way to build a typed Effect CLI.

Default pieces:

- `Command.make(...)`
- `Args.*`
- `Options.*`
- `Command.withSubcommands(...)`
- `Command.run(...)`
- runtime layer from the host platform, such as Bun or Node

Keep CLI handlers thin:

- parse arguments in the command layer
- delegate real work to services
- keep domain logic outside the command definitions

## Streams And Scheduling

Reach for `Stream` when the data is repeated, chunked, backpressured, subscription-like, or naturally continuous. Reach for plain `Effect` when the operation is a single request/response workflow.

Use `Schedule` for:

- retries
- repetition
- backoff policies
- polling loops

Typical boundary:

- single call with retry: plain `Effect` plus `Schedule`
- ongoing feed or subscription: `Stream`

## Platform Services

Choose the smallest platform package that fits the host runtime.

- Node server or worker: `@effect/platform-node`
- Bun runtime: `@effect/platform-bun`
- browser integration: `@effect/platform-browser`

Avoid mixing host-specific packages without a reason. Keep host selection at the edge so the core stays portable.

## Review Heuristics

- If the code already has schemas, decode at the HTTP boundary instead of later.
- If the CLI handler knows too much about storage or transport, extract a service.
- If a polling loop is manually recursive, see whether `Schedule` or `Stream` makes the control flow clearer.
- If platform code leaks into the domain layer, push it outward behind a service boundary.
