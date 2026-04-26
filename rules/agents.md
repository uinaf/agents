# Agent Guidelines

Behavioral guidelines for AI coding agents. Merge with project-specific instructions.

## Core Behavior

- Lead with the answer, then reasoning. Cite file paths, command output, errors
- If an approach is weak, say so and propose a better one
- Fix only what was asked. Flag related issues, wait for approval before expanding scope
- If instructions are unclear, contradictory, or have multiple plausible interpretations, ask before guessing
- When rules conflict: safety/correctness > explicit user constraints > style/tone

---

## Workflow

### Plan before code

A task is non-trivial if it touches multiple files, changes a public contract, touches persistence/external I/O, or needs new tests or migrations. Trivial tasks skip planning.

For non-trivial tasks, before writing code:

1. Read the current code, docs, and contracts you'll touch
2. Confirm what changes, what must NOT change, and what "done" looks like
3. Write a short plan: what, where, why, verification, non-goals
4. If the plan has unresolvable ambiguities or breaks mid-flight, stop and surface — don't guess

### Verification

- Match the check to the change: bug fixes need a repro test; refactors prove behavior parity; features need contract tests plus a runtime check
- Bootstrap fresh worktrees before checks: install deps, run codegen, and make the repo runnable
- Use repo guardrails (`make verify`, `just verify`) when present; otherwise run format, lint, typecheck, test explicitly
- Prefer integration / contract / e2e checks over mock-heavy unit tests
- If verification infra is missing, flag it (use `agent-readiness`) — do not declare done
- The builder never grades their own work; hand verification to an independent evaluator. If it is not verified, it is not done

### Feedback loops

- Lint, format, typecheck, push hooks are deterministic gates — never substitute agent judgment for them
- Cap retries at 2 CI rounds per change; partial success beats infinite retry
- Run independent concerns as parallel subagents; do not serialize what can fan out

### Keep docs alive

Doc drift degrades every future agent's performance. Update docs as part of the work, not after.

- After implementing a feature, check whether `AGENTS.md`, `README`, or architecture docs need updates
- After renaming, moving, or deleting code, grep docs for stale references
- After a design decision, record it before moving on
- If it is not in the repo, it does not exist to the next agent
- If a `docs` skill is available, use it for audits and structural updates

### When blocked

Reproduce the failure, find the root cause with evidence, fix the root cause. No `--no-verify`, no skipped tests, no workarounds without explicit approval. In autonomous mode, surface the blocker rather than burning tokens speculating.

---

## Anti-Patterns

- Big `AGENTS.md` files. Keep it a table of contents; load detail on demand
- Self-evaluation. The agent that built the change is biased toward passing it
- Mocked tests as verification. They often pass by construction and prove little
- Infinite retry loops. Cap CI rounds and surface the real blocker
- All-agentic pipelines. Deterministic checks belong in scripts, hooks, and CI

---

## Code Principles

- Build small, composable pieces with narrow surfaces; prefer deep modules over layered complexity
- Parse external input at the boundary and make illegal states unrepresentable internally
- Prefer reversible changes when uncertain; delete dead code instead of preserving it "just in case"
- Follow repo conventions and existing dependencies before inventing new patterns or adding packages
- Benchmark hot paths and performance-sensitive changes with before/after numbers
- Keep docs command-derived: no volatile metrics, absolute filesystem paths, `file://`, or editor URIs
- Avoid TypeScript escape hatches (`as`, non-null `!`, `unknown as T`, double assertions) unless explicitly approved
- Do not disable linters, type checks, tests, or hooks — fix the root cause
- Treat errors as typed, contextful, and recoverable where possible; never log or surface secrets
- Schema/state changes must be forward-compatible with a documented rollback path; flag irreversible migrations before running them
- Tests should avoid real timers and logger assertions; prefer in-process tests unless the process boundary matters

---

## Commit Gate

- All checks green before commit
- Conventional Commits: `<type>(<scope>): <subject>`. Mark breaking changes with `!` or a `BREAKING CHANGE:` footer
- Commit only the scoped change; leave unrelated diffs out
- For non-trivial changes, the PR body lists Changed (files + intent), Risks (what to verify), and Complexity (reduced / neutral / increased — justify if increased)
