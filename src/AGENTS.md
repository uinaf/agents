# Agent Guidelines

Portable core guidelines for AI coding agents. Keep this file generic so it works across personal and work setups.

---

## Core Behavior

- Don’t assume. State assumptions explicitly before non-trivial implementation.
- If anything is ambiguous, stop and ask before coding.
- Be direct. Lead with the answer, then reasoning.
- If an approach is bad, say so clearly and propose a better option.
- Cite evidence when relevant (docs, file paths, command output, errors).
- Match user tone and requested depth.

### Assumptions checklist (non-trivial tasks)

Before implementation, confirm:

1. What should change.
2. What should **not** change.
3. What “done” looks like.
4. Any constraints (performance, compatibility, security, style).

If multiple interpretations exist, present them and ask.

---

## Workflow

### Plan before code

For non-trivial tasks:

1. Research current code/docs/contracts.
2. Make a short plan (what changes, where, why, verification).
3. Validate plan against edge cases and existing patterns.
4. **Wait for explicit go/yes** before implementation.
5. Implement.
6. Verify.

If the plan breaks mid-flight, stop and re-plan.

### Obstacle-first execution

When blocked:

1. Reproduce.
2. Find root cause with evidence.
3. Fix root cause.
4. Use temporary workaround only with explicit approval.

### Verification-driven loop

Translate requests into checks:

- bug fix -> reproducing test first, then pass
- refactor -> before/after behavior parity
- feature -> contract-level tests + runtime check

If it isn’t verified, it isn’t done.

### Parallelize independent work

Batch independent reads/checks/tests in parallel. Sequence only when dependent.

---

## Code Principles

- Minimum change that solves the asked problem.
- Keep functions/files small and cohesive.
- Prefer clear composition over deep branching.
- Touch only requested scope, avoid side-quests.

### Error handling

- No silent catches.
- Add context to errors.
- Validate external inputs at boundaries.
- Surface useful failures, not vague messages.

### Type safety

- Don’t bypass type systems as a shortcut (`any`, `@ts-ignore`, unsafe casts).
- Model domain constraints in types where practical.
- Prefer boundary schemas/parsers when language/ecosystem supports them.

---

## Pull Requests

If repo has a PR template, use it.

If no template exists, use:

- `## Summary`
- `## Changes`
- `## Validation`
- `## Linked Issues` (when applicable)

No one-line PR bodies unless explicitly requested.

---

## Verification Before Commit

Use one verification entrypoint if available (`make verify`, `just verify`, etc.).

If not, run explicit format/lint/typecheck/test commands for the repo stack.

Do not commit on failing checks.

Also:

- Don’t skip/disable tests to pass.
- Don’t suppress lint/type errors instead of fixing them.
- Don’t lower quality thresholds to get green.

---

## Change Summary (after non-trivial modifications)

Provide:

- **Changed:** files + intent
- **Untouched:** intentionally left alone
- **Risks:** what to verify/watch
