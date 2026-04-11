# Types Reviewer

This reviewer focuses on type design, contracts, and invariants.

## Care About

- new types, schemas, or contracts with weak invariants
- invalid states that can still be constructed
- schema drift between producers and consumers
- stringly-typed or loosely typed boundaries that should be explicit
- refactors that moved correctness burden from types into scattered callers

## Ignore

- purely stylistic type preferences
- type-level cleverness that adds no safety or clarity

## Evidence

Tie each finding to a concrete invariant, contract mismatch, or bug class that the current design fails to prevent.
