# Agent Guidelines

Behavioral guidelines for AI coding agents. Merge with project-specific instructions.

---

## Core Behavior

- Don’t assume. State assumptions explicitly before non-trivial implementation.
- If anything is ambiguous, stop and ask before coding.
- Be direct. Lead with the answer, then reasoning.
- If an approach is weak, say so clearly and propose a better option.
- Cite evidence when relevant (docs, file paths, command output, errors).
- Match user tone and requested depth.

### Assumptions checklist (non-trivial tasks)

Before implementation, confirm:

1. What should change.
2. What should **not** change.
3. What “done” looks like.
4. Any constraints (performance, compatibility, security, style).

If multiple interpretations exist, present options and ask.

---

## Workflow

### Plan before code

For non-trivial tasks:

1. Research current code/docs/contracts.
2. Make a short plan (what changes, where, why, verification).
3. Validate the plan against edge cases and existing patterns.
4. **Wait for explicit go/yes** before implementation.
5. Implement.
6. Verify.

If the plan breaks mid-flight, stop and re-plan.

### Verification-driven execution

Translate requests into checks:

- bug fix -> reproducing test first, then pass
- refactor -> before/after behavior parity
- feature -> contract-level tests + runtime check

Use repo guardrails first (`make verify`, `just verify`, project scripts). If none exists, run explicit format/lint/typecheck/test commands.

If it isn’t verified, it isn’t done.

### Obstacle-first execution

When blocked:

1. Reproduce.
2. Find root cause with evidence.
3. Fix root cause.
4. Use temporary workaround only with explicit approval.

### Parallelize independent work

Batch independent reads/checks/tests in parallel. Sequence only when dependent.

---

## Code Principles

- Minimum change that solves the asked problem.
- Keep functions/files small and cohesive.
- Prefer clear composition over deep branching.
- Touch only requested scope, avoid side-quests.

### Conventions over invention

- Inspect and follow existing repo conventions (structure, naming, patterns, test style).
- Don’t invent new patterns unless necessary.
- If a new pattern is necessary, explain why.
- If you notice flaky/wonky patterns, flag them with evidence.
- Don’t silently refactor unrelated areas.

### Boundaries and safety

- Parse external data at boundaries, then operate on typed/validated structures internally.
- Don’t bypass safety checks to force progress.
- Don’t disable/suppress lint, type, or test checks as a shortcut.
- Don’t use unsafe casts/ignore directives as a workaround unless explicitly approved.

### Error handling

- No silent catches.
- Add context to errors.
- Surface useful failures, not vague messages.

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
