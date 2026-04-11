# Reviewer Selection

Pick the smallest set of independent reviewer personas that can actually challenge the change.

## Default Set

Use these for most non-trivial reviews:

- [reviewers/general.md](../reviewers/general.md)
- [reviewers/tests.md](../reviewers/tests.md)
- [reviewers/silent-failures.md](../reviewers/silent-failures.md)

## Add Conditional Personas

### Add [reviewers/types.md](../reviewers/types.md) when:

- new types, schemas, or DTOs are introduced
- API contracts changed
- invariants moved into or out of types
- a refactor changed data boundaries

### Add [reviewers/comments.md](../reviewers/comments.md) when:

- docstrings or code comments changed materially
- large comment blocks were added
- the change leans on comments to explain tricky behavior

## Shape-Based Shortcuts

- **UI feature** → general + tests + silent-failures
- **API / backend** → general + tests + silent-failures; add types for schema changes
- **State / migration / config** → general + tests + silent-failures; add types if invariants changed
- **Doc-heavy change** → general + comments
- **Tiny mechanical change** → general only, unless the change touches error handling or tests

## Do Not Spawn Everything Blindly

More personas are not always better.

Avoid reviewer spam when:

- the diff is tiny
- personas would repeat the same concern
- coordination overhead exceeds review value

Every persona should contribute a distinct lens or evidence source.
