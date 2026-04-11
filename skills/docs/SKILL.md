---
name: docs
description: "Update repo documentation and agent-facing guidance such as AGENTS.md, README.md, docs/, specs, plans, and runbooks. Use when code, skill, or harness changes risk doc drift or when documentation needs cleanup or restructuring. Do not use for code review, runtime verification, or harness setup."
---

# Docs

Keep the repo legible to humans and agents.

## Principles

- Docs rot silently — every code change is a possible doc change
- Routing docs stay short; depth lives in `docs/`
- No duplication when a pointer will do
- Use repo-relative links for in-repo docs; external links are fine in sources and references
- Doc drift is a real failure, not polish debt

## Handoffs

- Missing boot, smoke, e2e, logs, or agent-readiness infrastructure → use `harness`
- Need to judge existing code, a diff, branch, or PR with evidence → use `review`
- Need to validate your own completed change on the real surface → use `verify`

## Workflow

### 1. Audit the doc surface

Check the files humans and agents actually rely on:

- `AGENTS.md`
- `README.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `docs/`
- plans, specs, runbooks, decision docs

Flag stale commands, dead paths, duplicated guidance, and routing failures.

### 2. Update routing docs

Keep top-level docs terse and navigational.

- `AGENTS.md` should be a table of contents, not a wiki
- `README.md` should lead with value and the fastest path to use the project
- `CONTRIBUTING.md` should hold contributor setup, validation, and workflow
- `SECURITY.md` should hold private-first vulnerability reporting guidance
- Push detail downward instead of bloating top-level files
- Use the concrete top-level split and section order in [references/documentation.md](references/documentation.md) instead of inventing a new shape every time
- Prefer terse routing over narrative sprawl, for example `README.md` should link to deeper docs instead of re-explaining them inline

### 3. Update deep docs and specs

Refresh the detailed documents that actually carry the knowledge.

- architecture and API docs
- task guides and runbooks
- feature plans and specs
- harness usage docs after harness changes

### 4. Clean up drift

- deduplicate repeated facts
- delete or archive stale docs
- fix cross-links and moved paths
- keep naming and commands consistent across files

### 5. Validate reality

Do not trust prose. Check that commands, file paths, and entry points still match the repo.

Concrete checks:

- `rg -n "old/path|stale-command" AGENTS.md README.md docs/` when paths or commands moved
- `test -e <path-from-docs>` before keeping a file reference

## Output

After docs work, report:

- files updated
- stale or duplicated docs removed or rewritten
- commands or paths verified
- remaining doc gaps
- any handoff needed to `harness`, `review`, or `verify`

## References

- [references/documentation.md](references/documentation.md) — AGENTS.md shape, scoped rules, README patterns, doc hygiene
- [references/specifications.md](references/specifications.md) — feature specs, conformance tests, spec drift, SDD trade-offs
