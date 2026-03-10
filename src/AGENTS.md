# Agent Guidelines

Behavioral guidelines for AI coding agents. Merge with project-specific instructions.

---

## Core Behavior

- Be direct. Lead with the answer, then reasoning.
- Cite evidence when relevant (file paths, command output, errors, docs).
- If an approach is weak, say so and propose better.
- Fix only what was asked. Flag related issues, wait for approval.
- If instructions are unclear, contradictory, or have multiple interpretations, pause and ask.
- Priority order when rules conflict: safety/correctness > explicit user constraints > style/tone.

---

## Workflow

### Plan before code

A task is non-trivial if it touches multiple files/modules, changes a public contract, touches persistence/external I/O, or needs new tests/migrations. Trivial tasks (single-file, safe, obvious) skip planning — just implement and verify.

For non-trivial tasks:

1. Research current code/docs/contracts.
2. Confirm assumptions: what changes, what must NOT change, what "done" looks like, constraints.
3. Short plan: what, where, why, verification, non-goals.
4. Proceed with implementation unless the plan has unresolvable ambiguities — then stop and surface them.
5. Implement, then verify using the checks below.

If the plan breaks mid-flight, stop and re-plan.

### Verification

- Bug fix → reproducing test first, then fix.
- Refactor → before/after behavior parity.
- Feature → contract-level tests + runtime check.

Use repo guardrails first (`make verify`, `just verify`, project scripts). If none exist, run explicit format/lint/typecheck/test.

If it isn't verified, it isn't done.

### Sanity-check with reality

After tests pass, verify the change works in practice — not just in tests. Run the binary, hit the endpoint, check the output. If a `sanity-check` skill is available, use it.

### When blocked

Reproduce the issue. Find root cause with evidence. Fix root cause. Use workarounds only with explicit approval. In autonomous mode, **stop and surface the blocker** — do not burn tokens on workarounds.

---

## Code Principles

These aren't suggestions — they're the standard. Internalize them.

**SICP:** Composition over layered complexity. Build from small, composable pieces. Understand abstractions before using them.

**A Philosophy of Software Design (Ousterhout):** Deep modules with small stable surfaces. Minimize cognitive load. Complexity is the enemy — fight it actively.

**Software Design for Flexibility (Hanson & Sussman):** Extension points are earned by real use-cases, not speculation. Don't build for hypothetical futures.

### Design and structure

- Deep modules, small stable surfaces, minimal cognitive load.
- Composition over layered complexity.
- Extension points earned by real use-cases, not speculation.
- Prefer reversible changes when uncertain.
- For hot paths or perf-sensitive changes, include before/after benchmark numbers in the PR.

### Conventions

- Inspect and follow existing repo conventions (structure, naming, patterns, test style).
- Don't invent new patterns unless necessary — if you do, explain why.
- Never hardcode volatile metrics in docs (test counts, line counts, file sizes, coverage numbers). These go stale instantly and become lies. If it can be derived from a command, let the command be the source of truth.

### Safety

- Parse external data at boundaries; operate on typed/validated structures internally.
- No unsafe casts, ignore directives, suppressed checks, skipped tests, or lowered thresholds unless explicitly approved.
- Never log or surface secrets in error output.

### Dependencies

- Don't add or update dependencies unless necessary. Justify new deps in the PR.
- Prefer what's already in the stack before reaching for something new.

### Error handling

- No silent catches. Add context to errors. Surface useful failures.

### Migrations and state changes

- Schema/state changes must be forward-compatible. Document rollback path in the PR.
- If a migration is not safely reversible, flag it before proceeding.

### Testing

- No real timers in tests (mock them).
- No assertions on logger calls. Mute loggers in test suites.
- Prefer in-process tests: expose callable entry functions, test those directly.
- Subprocess tests only for true process-boundary behavior.
- Coverage must represent executed production code for the full test run.
- Coverage integrity: run the same coverage command as CI, confirm expected files appear, and treat missing files (e.g. due to process boundaries) as failure.

---

## Project Tracking

Work is tracked in Linear (workspace: `uinaf`). When a task references an issue ID (e.g. `UINAF-42`), that's the canonical spec. Read it for context before starting.

Use conventional commit format: `type(scope): description` — e.g. `feat:`, `fix:`, `refactor:`, `test:`, `chore:`, `docs:`.

If the task has a linked issue, include it parenthesized at the end: `type: description (fixes UINAF-42)`. Lowercase `fixes`. Not all tasks have issues — only add this when one exists.

---

## Commit Gate

All checks green before commit. If creating a PR, use repo template or: Summary, Changes, Validation, Linked Issues.

### Change Summary (non-trivial tasks)

- **Changed:** files + intent
- **Risks:** what to verify/watch
- **Complexity:** net `reduced` | `neutral` | `increased` — if increased, justify it or propose a simpler alternative
