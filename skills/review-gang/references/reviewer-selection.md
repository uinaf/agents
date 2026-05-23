# Reviewer Selection

Always spawn the default reviewer gang, then add only the conditional personas that can challenge the change from a distinct angle.

## Default Set

Spawn these for every Review Gang run:

- [reviewers/general.md](../reviewers/general.md)
- [reviewers/tests.md](../reviewers/tests.md)
- [reviewers/silent-failures.md](../reviewers/silent-failures.md)

The default gang is mandatory even for small diffs. The silent-failures lens is especially important when the diff touches error handling, retries, fallbacks, validation, auth, external services, or user-facing failures.

## Add Conditional Personas

### Add [reviewers/types.md](../reviewers/types.md) when:

- new types, schemas, or DTOs are introduced
- API contracts changed
- invariants moved into or out of types
- a refactor changed data boundaries
- the diff uses `any`, `as`, `unknown`, or other type escape hatches

### Add [reviewers/cleanup.md](../reviewers/cleanup.md) when:

- the diff is a refactor, migration, or generated-looking change with helper churn
- dead code, stale flags, duplicate branches, or unused exports look plausible
- the change introduces wrappers or abstractions that may add indirection without value
- you suspect the right fix is deletion or merging paths rather than adding more code

### Add [reviewers/comments.md](../reviewers/comments.md) when:

- docstrings or code comments changed materially
- large comment blocks were added
- the change leans on comments to explain tricky behavior

## Shape-Based Add-Ons

- **UI feature** → general + tests + silent-failures
- **API / backend** → general + tests + silent-failures; add types for schema changes and cleanup for wide refactors
- **State / migration / config** → general + tests + silent-failures; add types if invariants changed and cleanup if old paths may be left behind
- **Refactor / cleanup** → default gang + cleanup; add types when invariants changed
- **Doc-heavy change** → default gang + comments
- **Tiny mechanical change** → default gang only, unless comments/types/cleanup add a distinct concern

## Do Not Add Everything Blindly

More conditional personas are not always better.

Avoid conditional persona spam when:

- the diff is tiny
- personas would repeat the same concern
- coordination overhead exceeds review value

Every added persona should contribute a distinct lens or evidence source.
