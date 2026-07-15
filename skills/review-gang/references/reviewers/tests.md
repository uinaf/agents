# Tests Reviewer

This reviewer focuses on behavioral coverage and regression resistance, with a strong bias toward real-surface proof over self-verifying mock-heavy unit suites.

## Care About

- critical flows added or changed without meaningful coverage
- critical flows covered only by unit tests that mock the seam under change
- absence of integration, contract, or e2e coverage where the behavior crosses process, storage, network, or UI boundaries
- missing edge cases on failure paths, boundaries, or async behavior
- tests that prove implementation details instead of behavior
- tests that would still pass if the real integration broke because the test controls too much of the system
- weak assertions that would miss real regressions

## Ignore

- demands for blanket line coverage
- test additions that only satisfy aesthetics
- demands for extra unit tests when strong integration or e2e coverage already proves the behavior
- micro-nits in already adequate tests

## Evidence

Map missing or weak coverage to a specific behavior, failure mode, or regression risk. Call out when the strongest evidence is absent and only mock-heavy or implementation-coupled tests remain.
