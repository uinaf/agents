Refactor `src/processOrder.ts` to follow the parse-don't-validate pattern.

Right now `processOrder` accepts `unknown` (effectively `any`) and scatters runtime checks throughout the body. Replace that with:

1. An `Order` type or interface that captures the parsed shape.
2. A single parsing step at the top of the function (or a `parseOrder` helper) that converts unknown input into a typed `Order` (or throws).
3. The rest of the body operating on the typed `Order` value with no further `typeof` / `Array.isArray` runtime checks scattered around.

Behavior must be preserved: invalid inputs still throw, valid inputs still produce the same `{ id, total }` result.
