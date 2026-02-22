# Agent Guidelines

Behavioral guidelines for AI coding agents. Merge with project-specific instructions.

---

## Core Behavior

- Don’t assume. State assumptions, ask when unclear.
- Be direct. Lead with the answer, then reasoning.
- If something is a bad idea, say it and propose an alternative.
- Cite evidence when relevant (docs, file paths, command output, errors).
- Match user tone and depth.

### Banned habits

- Fake certainty when uncertain.
- Fluff phrases like “it’s worth mentioning…”
- Long preambles before the answer.

---

## Workflow

### Plan before code

Before non-trivial changes:

1. Research current code/docs/contracts.
2. Make a short plan (what changes, where, why, verification).
3. Validate edge cases.
4. Implement.

If the plan breaks mid-flight, stop and re-plan.

### Obstacle-first execution

When blocked:

1. Reproduce.
2. Find root cause with evidence.
3. Fix root cause.
4. Use temporary workaround only with explicit approval.

### Verification-driven loop

Convert requests into checks:

- bug fix -> reproducing test first, then pass
- refactor -> before/after behavior parity
- feature -> contract-level tests + runtime check

If it isn’t verified, it isn’t done.

### Parallelize independent work

Batch independent reads/checks/tests in parallel. Sequence only when dependent.

---

## Code Principles

- Minimum change that solves the asked problem.
- Small, cohesive functions/files.
- Prefer composition over deep branching logic.
- Prefer declarative flow over ad-hoc imperative state.
- Touch only requested scope; don’t do side-quests.

### Error handling

- No silent catches.
- Add context to errors.
- Validate external inputs at boundaries.
- Surface useful failures, not vague “something went wrong”.

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

Use one verification entrypoint if the repo has one (`make verify`, `just verify`, etc.).

If not, run explicit format/lint/typecheck/test commands for the repo’s stack.

Do not commit on failing checks.

Also:

- Don’t skip/disable tests to pass.
- Don’t suppress lint/type errors instead of fixing them.
- Don’t lower quality thresholds to get green.

---

## Language: TypeScript

- `strict: true`.
- Schema-first at boundaries (Zod). Derive types from schemas.
- Prefer `Result`-style return shapes (or `safeParse`) for recoverable failures.
- No `any`, no `@ts-ignore`, no unsafe casts as a shortcut.
- Bun + oxlint/oxfmt conventions when repo uses them.

## Language: Go

- Errors are values, always checked and wrapped with context.
- Parse/unmarshal into typed structs at boundaries, validate immediately.
- Use named domain types over raw primitives.
- Keep concurrency cancellable (`context`, `errgroup`, controlled goroutines).
- Keep lint/test clean (`gofmt`, `golangci-lint`, `go test`).

## Language: Rust

- `Result<T, E>` everywhere, `?` over `unwrap`.
- Parse into strong types (`serde`) at boundaries.
- Avoid `unsafe`; if required, document invariants with `// SAFETY:`.
- Prefer enums/newtypes to encode domain constraints.
- Keep `cargo fmt`, `cargo clippy`, and tests clean.

---

## Change Summary

After non-trivial modifications, summarize:

- **Changed:** files + intent
- **Untouched:** intentionally left alone
- **Risks:** what to verify/watch
