# Alternative Map

Use this after the basic replacement guide when an effect is hiding a bigger React architecture problem.

## Data Fetching and Server State

Choose the highest available layer:

1. **Server/framework data** for initial render: React Server Components, route loaders, server functions, framework fetch/cache APIs, or page/layout data APIs.
2. **Client server-state library** for interactive, client-owned server state: TanStack Query, SWR, Relay, Apollo, or the repo's existing SDK hooks.
3. **Local async state** only when there is no shared server-state layer and the slice is too small to justify adding one.

TanStack Query replacements should usually include:

- `queryOptions` or the repo's existing query factory pattern
- query keys that encode every variable that changes the result
- `enabled` for dependent queries instead of conditional hooks or effect flags
- `select` for deriving server-state views
- query functions that accept and pass `signal` to `fetch`
- `useMutation` for writes, followed by invalidation or cache updates
- `onMutate` cancellation and rollback context for optimistic updates
- `placeholderData` for pagination instead of copying previous pages into local state

Use regular `useQuery` instead of Suspense query hooks when dependent `enabled` gates, placeholder pagination, or cancellation semantics matter. Suspense is good for boundary-driven loading, not for every query replacement.

## Forms, Writes, and User Actions

If the work happens because the user clicked, typed, submitted, dragged, or navigated, keep it at that cause.

Prefer:

- event handlers for simple client-only work
- framework actions or React form actions when the repo uses them
- `useActionState` for action result/error state
- `useFormStatus` for submit pending UI in a child component rendered inside the form
- `useOptimistic` for local optimistic UI when updates are dispatched from an action or `startTransition`
- TanStack Query `useMutation` for client server-state writes

Avoid `setFlag(true)` followed by an effect that notices the flag. That splits cause from effect and creates stale-closure and dependency-array risk.

## External Stores and Browser Values

If the component needs a changing value from outside React, prefer `useSyncExternalStore` over an effect that subscribes and copies into local state.

Good candidates:

- external state stores without first-class React bindings
- browser APIs such as online/offline status
- cross-tab, media-query, or storage-backed values

Keep `subscribe` stable outside the component when possible. `getSnapshot` must return a stable immutable snapshot while the external value has not changed.

## Performance and Waterfalls

Effects often hide performance work that should be explicit.

Prioritize high-impact fixes first: waterfalls, bundle/server boundaries, and data ownership usually beat low-level memoization. Do not jump to `useMemo` while a request waterfall or client-only fetch is still dominating the path.

Prefer:

- parallelizing independent async work with `Promise.all`
- Suspense boundaries to reveal independent async UI
- server-side fetch and hydration for initial data in framework apps
- dynamic import/code splitting for heavy optional client widgets
- `useDeferredValue` for slow children that can lag behind urgent input
- `useTransition` for non-urgent updates and navigations
- lazy `useState` initialization for expensive initial local values
- deriving cheap values inline instead of memoizing them

Only apply performance primitives when they map to a real bottleneck, React Doctor diagnostic, or existing repo standard.

## Verification and Diagnostics

Run the repo's normal guardrails first. When React Doctor is available, add:

```bash
npx react-doctor@latest --verbose --diff
```

Use React Doctor's explanation mode for unclear diagnostics or suppressions:

```bash
npx react-doctor@latest --explain src/App.tsx:42
```

Relevant effect-adjacent diagnostics include derived-state effects, fetch-in-effect, missing cleanup, stale closure capture, async without cleanup, exhaustive dependencies, and giant components created by trying to centralize too much orchestration in one component.

Suppress only when the code is intentionally unusual, and keep suppressions line-local and rule-specific.

## Sources

- Factory: https://factoryai.com/blog/why-we-banned-useeffect
- Factory thread mirror: https://threadnavigator.com/thread/2033969062834045089/
- React: https://react.dev/learn/you-might-not-need-an-effect
- React: https://react.dev/learn/synchronizing-with-effects
- React: https://react.dev/learn/separating-events-from-effects
- React: https://react.dev/learn/removing-effect-dependencies
- React: https://react.dev/reference/react/useSyncExternalStore
- React: https://react.dev/reference/eslint-plugin-react-hooks/lints/set-state-in-effect
- TanStack Query: https://tanstack.com/query/latest/docs/framework/react/overview
- TanStack Query options: https://tanstack.com/query/latest/docs/framework/react/guides/query-options
- Vercel React Best Practices: https://vercel.com/blog/introducing-react-best-practices
- Vercel React Server Components: https://vercel.com/blog/understanding-react-server-components
- React Doctor: https://www.react.doctor/docs
