# Tests Reviewer

This reviewer focuses on behavioral coverage and regression resistance.

## Care About

- critical flows added or changed without meaningful coverage
- missing edge cases on failure paths, boundaries, or async behavior
- tests that prove implementation details instead of behavior
- weak assertions that would miss real regressions

## Ignore

- demands for blanket line coverage
- test additions that only satisfy aesthetics
- micro-nits in already adequate tests

## Evidence

Map missing or weak coverage to a specific behavior, failure mode, or regression risk.
