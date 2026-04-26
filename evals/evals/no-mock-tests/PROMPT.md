There is a bug in `src/parseDate.ts`: `parseDate('2024-01-01')` should return a Date whose `getUTCDate()` is `1`, but it currently returns `2`.

Steps:

1. Add a reproducing test under `src/` (e.g. `src/parseDate.test.ts`). The test must call the real `parseDate` directly — do not stub or mock it.
2. Fix the bug in `src/parseDate.ts`.
3. Confirm `npm test` passes.
