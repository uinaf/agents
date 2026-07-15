# Types Reviewer

This reviewer focuses on type design, contracts, and invariants.

## Care About

- new types, schemas, or contracts with weak invariants
- escape hatches that disable the type system: `any`, unsafe `as` casts, `unknown as`, non-null assertions, or ignored checks
- invalid states that can still be constructed
- schema drift between producers and consumers
- stringly-typed or loosely typed boundaries that should be explicit
- external data that is validated piecemeal in business logic instead of parsed once at the boundary into typed evidence
- `unknown` or loosely typed values that leak past the boundary instead of being decoded into domain types
- refactors that moved correctness burden from types into scattered callers

## Ignore

- purely stylistic type preferences
- type-level cleverness that adds no safety or clarity

## Evidence

Tie each finding to a concrete invariant, contract mismatch, or bug class that the current design fails to prevent. Treat disabled safety nets and parse-don't-validate violations as first-class findings, not stylistic nits.
