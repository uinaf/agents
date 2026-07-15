---
name: react-ban-use-effect
description: "Ban direct `useEffect` in React code. Use when writing, refactoring, reviewing, or migrating React components or hooks that import, call, add, or replace direct `useEffect`; when an agent reaches for effects for derived state, fetching, event reactions, resets, or external sync; or when adding lint/agent rules for a no-direct-useEffect policy. Do not use for ordinary React work with no effect smell, non-React code, or legitimate effect architecture outside React."
---

# React Ban useEffect

Default stance: do not import or call `useEffect` directly in React components. Treat effects as an escape hatch for synchronizing with external systems, not as the default place to put render, event, data, or reset logic.

## Start Here

1. Search the touched React surface for direct `useEffect` imports and calls.
2. Classify each effect by intent before editing:
   - render-time derivation
   - data fetching or server state
   - response to a user action
   - local state reset on identity change
   - async UI, pending state, or request waterfall
   - external-system synchronization
3. Replace it with the narrowest declarative pattern from [references/replacements.md](references/replacements.md).
4. For data, forms, external stores, or performance work, also check the stronger alternative map in [references/alternatives.md](references/alternatives.md).
5. Keep behavior proof concrete: run the repo's lint/type/test gate, the optional `react-doctor` CLI diff scan when available, plus the smallest runtime or component check that exercises the changed path. Fix failures and rerun before completion.

## Replacement Ladder

Use the highest applicable layer:

1. render-time calculation
2. server, loader, or framework data API
3. server-state library such as TanStack Query, SWR, Relay, or Apollo
4. event handler, form action, or mutation
5. keyed component boundary
6. `useSyncExternalStore` or a reviewed domain-specific external-system hook with explicit reactive inputs

If none of these fit, stop and explain why the code truly needs an effect instead of adding direct `useEffect`.

## Allowed Escape Hatches

Prefer an existing repo integration hook. If the repo has no standard, add a domain-specific hook that names the external system, owns its setup and cleanup, accepts every reactive input explicitly, and keeps those inputs in the effect dependency list. See [the external-system replacement](references/replacements.md#5-synchronize-external-systems) for the concrete shape.

Do not expose a generic effect callback or dependency list to callers, and do not suppress `react-hooks/exhaustive-deps`. A truly mount-only integration may use an empty dependency list only when its setup reads no reactive value from props, state, or the component closure. Prefer `useSyncExternalStore` for external stores or browser values that change over time. Never use an exception hook to fetch server state, copy props into state, or relay user actions.

## Enforcement

For new policy work, prefer the repo's existing ESLint shape. The usual rule is `no-restricted-imports` against `useEffect` from `react`, with the message pointing developers to declarative replacements and reviewed external-integration hooks. Also block namespace calls such as `React.useEffect(...)` with `no-restricted-syntax` or a custom rule. Allow only named, reviewed external-integration hook files as direct-import/call exceptions; do not create a general-purpose wrapper exemption. If the repo already uses another lint shape, preserve that local convention.

```ts
{
  "no-restricted-imports": ["error", {
    name: "react",
    importNames: ["useEffect"],
    message: "Use a declarative replacement or reviewed external-integration hook.",
  }],
  "no-restricted-syntax": ["error", {
    selector: "CallExpression[callee.object.name='React'][callee.property.name='useEffect']",
    message: "Do not call React.useEffect directly.",
  }],
}
```

For reviews, treat new direct `useEffect` as a finding unless the diff also introduces a clear, reviewed exception. Ask for a replacement plan rather than dependency-array tuning.

For upstream provenance and uinaf tailoring notes, use [references/upstream.md](references/upstream.md).

## Boundaries

- Scope the change to the touched path or requested migration slice.
- Preserve the repo's existing data, lint, hook, and framework conventions.
- Leave `useLayoutEffect`, framework lifecycle APIs, and non-React effect systems alone unless requested.
- Use performance primitives only for real UI/perf evidence or established repo patterns.

## Sources

Core sources and the broader alternatives bibliography live in [references/alternatives.md](references/alternatives.md).
