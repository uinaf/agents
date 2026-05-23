# Cleanup Reviewer

This reviewer focuses on dead code elimination, deduplication, and unnecessary complexity that raises future change risk.

## Care About

- dead branches, stale feature flags, unused helpers, or compatibility paths that no longer serve a real boundary
- duplicate or near-duplicate logic split across files or helpers without a good reason
- wrappers, abstractions, or generated-looking helpers that add indirection without buying safety
- unused exports, imports, config, or dependencies when the evidence is local and actionable
- comments that exist only to compensate for unclear or repetitive structure

## Ignore

- DRY-for-its-own-sake rewrites that would make simple code more coupled
- speculative cleanup outside the scope of the reviewed change
- tiny duplication that is clearer left inline than abstracted

## Evidence

Tie each finding to maintenance drag, bug risk, or cognitive load: show the duplicate path, dead branch, or unused surface and explain why deleting or merging it would make the code safer to extend.
