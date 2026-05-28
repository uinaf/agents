# Replacement Guide

Use this when a React task touches direct `useEffect`. Classify the effect by intent; then replace it with the smallest pattern that preserves behavior.

## Why This Rule Exists

React's own guidance frames effects as an escape hatch for synchronizing with systems outside React. Factory's no-direct-useEffect rule applies the same idea as an agent guardrail: hidden synchronization through dependency arrays is easy for agents to add and hard for humans to trace later.

Common failure modes:

- dependency arrays hide coupling and drift during refactors
- state update -> render -> effect -> state update loops
- effect chains turn control flow into timing-sensitive synchronization
- event-caused behavior loses the original event context
- fetch effects recreate caching, retry, cancellation, and stale-data logic badly

## 1. Derive During Render

Use when an effect sets state from props, state, URL params, query params, feature flags, or selectors.

Smells:

- `useEffect(() => setX(f(y)), [y])`
- state mirrors props or other state
- an effect's only side effect is a setter

Prefer:

```tsx
const filteredProducts = products.filter((product) => product.inStock);
```

For expensive pure calculations, use `useMemo` only after the repo's performance expectations justify it. React Compiler may remove some need for manual memoization, so do not add `useMemo` reflexively.

## 2. Use Server or Server-State Data APIs

Use when an effect fetches data and stores it in component state.

Smells:

- `fetch(...).then(setState)` inside an effect
- manual `ignore`, `cancelled`, or stale response flags
- hand-rolled cache, retry, revalidation, pagination, or dedupe logic

Prefer, in repo order:

- server components, route loaders/actions, server functions, or framework data APIs when the data is needed for initial render
- TanStack Query, SWR, Relay, Apollo, or the repo's existing server-state layer for client-owned server state
- a shared SDK hook already present in the codebase

When using TanStack Query, prefer `queryOptions`, query keys that include variables, `enabled` for dependent queries, `select` for server-state derivation, AbortSignal-aware query functions, mutations with invalidation, and optimistic updates with cancellation/rollback where appropriate.

Use regular `useQuery` when dependent `enabled` gates, placeholder pagination, or cancellation semantics matter. TanStack v5 Suspense query hooks intentionally do not support all regular-query options.

Do not introduce a new dependency without explicit approval. If the repo has no server or server-state layer, state that the direct effect is a design gap and keep the smallest local fix honest.

## 3. Move User-Caused Work to Handlers, Actions, or Mutations

Use when an effect waits for state to change so it can run work caused by a click, form submit, keyboard action, drag, or route interaction.

Smells:

- `setShouldSubmit(true)` then an effect posts data
- flags that exist only to trigger an effect
- effect body contains navigation, toast, analytics, mutation, or imperative API calls caused by a known event

Prefer:

```tsx
async function handleSubmit() {
  await saveDraft(formState);
  navigate("/drafts");
}
```

In React 19 or framework code that supports form actions, prefer the repo's action pattern plus `useActionState`, `useFormStatus`, or `useOptimistic` for pending/error/optimistic UI. `useFormStatus` belongs in a child component rendered inside the form. Call `useOptimistic` updates from an action or transition. In TanStack Query code, use `useMutation` and invalidate or update the relevant query keys. Share duplicated behavior by extracting a function that event handlers call directly. Do not put the shared behavior in an effect just to avoid a helper.

## 4. Reset with Keys or Derived Selection

Use when an effect clears or reloads local state after an identity prop changes.

Smells:

- `useEffect(() => setComment(""), [userId])`
- "load this entity from scratch when ID changes"
- nested children also need reset behavior

Prefer a keyed boundary:

```tsx
function ProfilePage({ userId }: { userId: string }) {
  return <Profile key={userId} userId={userId} />;
}
```

When only selection needs adjusting, prefer storing stable IDs and deriving selected objects during render. Updating state during render is a last resort and must be tightly guarded.

## 5. Synchronize External Systems

Use `useMountEffect` only when the work is naturally setup on mount and cleanup on unmount. For external systems that must resync when props or state change, use a reviewed explicit exception or dependency-aware wrapper instead of pretending the work is mount-only.

Good candidates:

- subscribing to a browser API or external store not covered by `useSyncExternalStore`
- initializing and disposing a third-party widget
- focusing, scrolling, measuring, or integrating with imperative DOM APIs after mount
- starting and cleaning up a process tied to the component's presence

Prefer `useSyncExternalStore` when the component reads a changing external store or browser value. That gives React a subscription and snapshot contract instead of a hand-rolled effect that copies external state into local state.

Before using it, try conditional mounting:

```tsx
function VideoPlayerContainer({ isReady }: { isReady: boolean }) {
  if (!isReady) return null;
  return <VideoPlayer />;
}

function VideoPlayer() {
  useMountEffect(() => {
    const player = startPlayback();
    return () => player.stop();
  });
}
```

This keeps preconditions in the parent and lifecycle in the child.

## 6. Keep Expensive UI Responsive Without Effects

Use when an effect exists only to debounce, delay, copy, or stage render work after input changes.

Smells:

- state mirrors input so a later effect can update a slow list or chart
- effect-managed loading flags for non-urgent UI updates
- sequential awaits for independent data before render

Prefer:

- `useDeferredValue` when a slow child can lag behind an urgent input
- `useTransition` or framework navigation pending state for non-urgent updates
- `Suspense` boundaries for async UI that can stream or reveal independently
- `Promise.all` or framework parallel data APIs for independent requests
- dynamic import or route/code splitting for heavy optional client components

Use these only when the changed path has visible latency, React Doctor findings, profiler evidence, or an existing repo convention. Do not scatter performance hooks as decoration.

## Review Checklist

- No direct `useEffect` import remains in touched React components.
- No `React.useEffect(...)` namespace calls remain in touched React components.
- Shared wrapper files are the only direct `useEffect` import/call exceptions.
- Any wrapper use synchronizes with a real external system and has cleanup when setup allocates work.
- Data fetching follows the repo's existing server-state path.
- Client query code uses keys, cancellation, dependent-query gates, mutation invalidation, and optimistic rollback where relevant.
- User-caused work stays in event handlers.
- Forms/mutations use action, mutation, pending, and optimistic primitives instead of state flags plus effects.
- External subscriptions use `useSyncExternalStore` when they expose changing values.
- Reset semantics use `key`, component boundaries, or render-time derivation.
- Verification includes lint/type/test, React Doctor diff scan when available, plus the changed UI, hook, or component behavior.
