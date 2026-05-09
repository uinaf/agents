# Structuring

Lightweight file shapes for specs, plans, and decisions. Templates, not ceremony.

## Directory Layout

```
docs/
├── specs/           # WHAT + WHY — long-lived contracts
├── plans/           # HOW + WHEN — tactical, deleted when done
└── decisions/       # WHY we chose X — ADR-lite
```

## Specs

Contracts that define "done." Stable after agreement. Change only when requirements change.

### Template

```markdown
# <feature-name>

## Problem
One paragraph. What's wrong and for whom.

## Requirements
- R1: <requirement>
- R2: <requirement>

## Acceptance Criteria
- AC1: <observable, testable outcome>
- AC2: <observable, testable outcome>

## Constraints
- <what must be true: perf, compat, security>

## Non-goals
- <what this explicitly does NOT cover>
```

### Naming
`specs/<feature-slug>.md` — e.g. `specs/password-reset.md`

### Lifecycle
Write → review → agree → implement. Update only when requirements change, not when the plan changes.

## Plans

Tactical execution strategy. Evolves during implementation. Delete when implemented — the branch/PR tells the story.

### Template

```markdown
# <feature-name> — Plan

Spec: `specs/<feature-slug>.md`

## Approach
2-3 sentences on the strategy.

## Tasks
- [ ] <task> → <files/modules>
- [ ] <task> → <files/modules>

## Order
What depends on what. What can run in parallel.

## Risks
- <what could go wrong and how to mitigate>
```

### Naming
`plans/YYYY-MM-DD-<feature-slug>.md` — e.g. `plans/2026-04-17-password-reset.md`

### Lifecycle
Write → implement → delete. The PR/commit history is the record. Plans are working documents, not archives.

## Decisions

Why, not what. ADR-lite.

### Template

```markdown
# <NNNN>-<slug>

## Context
What forced the decision.

## Decision
What we chose.

## Consequences
What this enables and what it blocks.
```

### Naming
`decisions/NNNN-slug.md` — e.g. `decisions/0003-use-sqlite-not-json.md`

### Lifecycle
Append-only. New decisions get the next number. Add a new decision when you reverse course.

## Discovery

Agents find these through `AGENTS.md` pointers, not filesystem scanning.

When the docs skill audits a repo and finds (or creates) specs/plans/decisions directories, it adds a routing entry to AGENTS.md:

```
## Docs
- Specs: docs/specs/
- Plans: docs/plans/
- Decisions: docs/decisions/
```

Keep AGENTS.md links shallow: directory plus one-line description, one pointer per directory.

## Rules

1. **One purpose per directory.** Keep specs in specs directories and plans in plans directories.
2. **Specs outlive plans.** A spec survives multiple plan attempts. A plan is disposable.
3. **Delete plans when done.** The PR tells the story. Plans are working documents, not archives.
4. **Link canonical docs.** Plans reference specs by path. Decisions reference both.
5. **Drift is a signal.** Plan changed but spec didn't = normal. Spec changed but tests didn't = bug.
