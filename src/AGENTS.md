# Agent Guidelines

Behavioral guidelines for AI coding agents. Merge with project-specific instructions.

---

## Core Behavior

- Be direct. Lead with the answer, then reasoning
- Cite evidence when relevant (file paths, command output, errors, docs)
- If an approach is weak, say so and propose better
- Fix only what was asked. Flag related issues, wait for approval
- If instructions are unclear, contradictory, or have multiple interpretations, pause and ask
- Priority order when rules conflict: safety/correctness > explicit user constraints > style/tone

---

## Workflow

### Plan before code

A task is non-trivial if it touches multiple files/modules, changes a public contract, touches persistence/external I/O, or needs new tests/migrations. Trivial tasks (single-file, safe, obvious) skip planning — just implement and verify.

For non-trivial tasks:

1. Research current code/docs/contracts
2. Confirm assumptions: what changes, what must NOT change, what "done" looks like, constraints
3. Short plan: what, where, why, verification, non-goals
4. Proceed with implementation unless the plan has unresolvable ambiguities — then stop and surface them
5. Implement, then verify using the checks below

If the plan breaks mid-flight, stop and re-plan.

### Verification

- Bug fix → reproducing test first, then fix
- Refactor → before/after behavior parity
- Feature → contract-level tests + runtime check
- Fresh worktree → bootstrap first (`pnpm install`, `cargo fetch`, codegen, etc.) before running checks

Use repo guardrails first (`make verify`, `just verify`, project scripts). If none exist, run explicit format/lint/typecheck/test.

After tests pass, verify the change works in practice. Run the binary, hit the endpoint, check the output. If a `verify` skill is available, use it. If verification infra is missing (no bootable env, no integration tests), flag the gap — use the `harness` skill to build it.

For code review, split by concern using parallel subagents: correctness, safety, test quality, contracts/types. Each concern gathers evidence independently; merge into one prioritized result.

**Use an independent evaluator context to verify runtime behavior. The builder should never grade their own work.**

If it isn't verified, it isn't done.

### Feedback loops

- **Deterministic vs agentic split**: lint, format, type check, push hooks = hardcoded, never left to agent judgment. Implementation, fixes, review = agentic
- **Cap retries**: max 2 CI rounds per change. Diminishing returns on more. Partial success beats infinite retry
- **Subagents for parallelism**: independent concerns = independent subagents. Don't serialize what can be parallelized

### Keep docs alive

Doc drift degrades every future agent's performance. Update docs as part of the work, not after.

- After implementing a feature, check if AGENTS.md, README, or architecture docs need updating
- After renaming, moving, or deleting code, grep docs for stale references
- After a design decision, record it before moving on
- If it's not in the repo, it doesn't exist to the next agent
- If a `docs` skill is available, use it for audits and structural updates

### When blocked

Stop. Reproduce. Find root cause with evidence. Fix root cause only. No workarounds without explicit approval. In autonomous mode, **surface the blocker** — don't burn tokens speculating.

---

## Anti-Patterns

- Big AGENTS.md (> 150 lines) — fails. Keep it a table of contents, load detail on demand
- Self-evaluation — agent grades own work, always passes. Use an independent evaluator context
- Mocked tests as verification — pass by construction, verify nothing real
- Infinite retry — max 2 CI rounds. Partial success beats token burn
- All-agentic pipeline — deterministic steps left to LLM judgment waste context and reliability

---

## Code Principles

### Design and structure

- **SICP:** Composition over layered complexity. Build from small, composable pieces
- **Ousterhout:** Deep modules with small stable surfaces. Minimize cognitive load. Complexity is the enemy
- **Hanson & Sussman:** Extension points are earned by real use-cases, not speculation
- **Elm Architecture:** Unidirectional data flow. Model → Update → View. State is explicit, side effects at edges
- **Domain Modeling (Wlaschin):** Make illegal states unrepresentable. Types encode domain rules. Railway-oriented error handling
- **Hexagonal Architecture:** Business logic knows nothing about infrastructure. Dependencies point inward
- **Parse, don't validate** ([original](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/), [TS edition](https://bardeworks.com/blog/parse-dont-validate-typescript/)): Push validation to the boundary, produce typed evidence of correctness
- **[Great software is composed, not written](https://altay.wtf/decade/):** Types are the ultimate contract. Declarative over imperative. Simplicity over cleverness. Pragmatism over perfection
- Prefer reversible changes when uncertain
- For hot paths or perf-sensitive changes, include before/after benchmark numbers in the PR

### Conventions

- Inspect and follow existing repo conventions (structure, naming, patterns, test style)
- Don't invent new patterns unless necessary — if you do, explain why
- Never hardcode volatile metrics in docs (test counts, line counts, coverage numbers). Let commands be the source of truth
- In checked-in Markdown, use repo-relative links. Never commit absolute filesystem paths
- Never put a period directly after a code span, URL, or code block

### Safety

- Parse external data at boundaries; operate on typed/validated structures internally
- No unsafe casts, ignore directives, suppressed checks, skipped tests, or lowered thresholds unless explicitly approved
- Never log or surface secrets in error output

### Dependencies

- Don't add or update dependencies unless necessary
- Prefer what's already in the stack before reaching for something new

### Error handling

- No silent catches. Add context to errors. Surface useful failures

### Migrations and state changes

- Schema/state changes must be forward-compatible. Document rollback path in the PR
- If a migration is not safely reversible, flag it before proceeding

### Testing

- No real timers in tests (mock them)
- No assertions on logger calls. Mute loggers in test suites
- Prefer in-process tests: expose callable entry functions, test those directly
- Subprocess tests only for true process-boundary behavior
- Coverage must represent executed production code for the full test run

---

## Commit Gate

All checks green before commit. If creating a PR, use repo template or: Summary, Changes, Validation, Linked Issues.
- Use Conventional Commits for commit messages: `<type>: <subject>` or `<type>(<scope>): <subject>`
- Prefer standard types such as `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, or `ci`
- Mark breaking changes with `!` in the header or a `BREAKING CHANGE:` footer
- Commit only the scoped change. Leave unrelated diffs out

**Change Summary** (non-trivial): Changed (files + intent), Risks (what to verify), Complexity (net reduced / neutral / increased — if increased, justify).
