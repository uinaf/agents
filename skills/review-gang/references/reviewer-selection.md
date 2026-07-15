# Reviewer Selection

Choose the smallest independent reviewer set that can challenge the change honestly. Every run uses at least two separate reviewers.

## Risk Tiers

### Small, low-risk change

Use [general](reviewers/general.md) plus one specialist that matches the only meaningful risk. This tier requires all of the following:

- at most two narrowly scoped files
- no runtime behavior, public API, schema, permissions, persistence, release, dependency, or configuration change
- no security-sensitive, error-handling, retry, fallback, auth, or external-service path

Examples:

- typo or docstring correction → `general` + [comments](reviewers/comments.md)
- tiny test-only correction → `general` + [tests](reviewers/tests.md)
- mechanical internal rename → `general` + [code-shape](reviewers/code-shape.md)

If any condition is uncertain, use the normal tier.

### Normal change

Use the core gang:

- [general](reviewers/general.md)
- [tests](reviewers/tests.md)
- [silent-failures](reviewers/silent-failures.md)
- [code-shape](reviewers/code-shape.md)

### High-risk change

Start with the core gang, then add only specialists that cover a distinct risk. High-risk signals include public contracts, migrations, auth, permissions, external services, release or deploy wiring, persistence, broad refactors, or generated-looking churn.

## Add Conditional Personas

### Add [types](reviewers/types.md) when:

- new types, schemas, or DTOs are introduced
- API contracts changed
- invariants moved into or out of types
- a refactor changed data boundaries
- the diff uses `any`, `as`, `unknown`, or other type escape hatches

### Add [cleanup](reviewers/cleanup.md) when:

- the diff is a refactor, migration, or generated-looking change with helper churn
- dead code, stale flags, duplicate branches, or unused exports look plausible
- the change introduces wrappers or abstractions that may add indirection without value
- you suspect the right fix is deletion or merging paths rather than adding more code

### Add [comments](reviewers/comments.md) when:

- docstrings or code comments changed materially
- large comment blocks were added
- the change leans on comments to explain tricky behavior

## Shape-Based Selection

- **UI feature** → core gang
- **API / backend** → core gang; add types for schema changes and cleanup for wide refactors
- **State / migration / config** → core gang; add types if invariants changed and cleanup if old paths may be left behind
- **Refactor / cleanup** → core gang + cleanup; add types when invariants changed
- **Doc-heavy normal change** → core gang + comments
- **Tiny low-risk change** → general + one matching specialist

## Do Not Add Everything Blindly

More personas are not always better.

Avoid conditional persona spam when:

- the diff is tiny
- personas would repeat the same concern
- coordination overhead exceeds review value

Every selected persona should contribute a distinct lens or evidence source. Do not promote a small change to the core gang merely to satisfy a fixed reviewer count.
