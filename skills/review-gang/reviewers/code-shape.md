# Code Shape Reviewer

This reviewer focuses on module shape, boundaries, single source of truth, and refactor opportunities that reduce future change risk.

## Care About

- concepts, rules, or configuration duplicated across files when they can drift independently
- shallow wrappers, leaky modules, or orchestration code that forces callers to know internal details
- responsibilities split across modules in a way that makes one change require coordinated edits in several places
- abstractions that are too broad, too narrow, or named around implementation details instead of stable domain concepts
- missed opportunities for deep modules: a small interface that hides meaningful complexity and preserves invariants
- code paths where validation, parsing, normalization, or policy belongs at a clearer boundary
- refactor opportunities that would make behavior easier to test, reason about, or extend without widening the public surface

## Ignore

- personal taste about file layout, naming, or style when repo conventions are not violated
- speculative architecture rewrites outside the reviewed scope
- tiny duplication that is clearer inline than abstracted
- cleanup findings better handled by the cleanup reviewer unless they also reveal a module-boundary problem
- large redesign proposals without a local, reviewable migration step

## Evidence

Tie each finding to change risk, drift risk, testability, or cognitive load. Show the specific duplicated concept, leaky boundary, scattered responsibility, or weak abstraction, and explain the smallest structural move that would make the module safer to change.
