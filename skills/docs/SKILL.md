---
name: docs
description: "Maintain repo documentation and agent-facing guidance. Use when updating or cleaning up AGENTS.md, README.md, docs/, plans, specs, runbooks, or when code and harness changes risk doc drift. Do not use for harness setup or change verification."
---

# Docs

Keep the repo legible to humans and agents.

## Principles

- Docs rot silently — every code change is a possible doc change
- Routing docs stay short; depth lives in `docs/` and `references/`
- No duplication when a pointer will do
- Repo-relative links only
- Doc drift is a real failure, not polish debt

## Handoffs

- Missing boot, smoke, e2e, logs, or agent-readiness infrastructure → use `harness`
- Need to judge a diff, branch, or PR with evidence → use `verify`

## Workflow

### 1. Audit the doc surface

Check the files humans and agents actually rely on:

- `AGENTS.md`
- `README.md`
- `docs/`
- plans, specs, runbooks, decision docs

Flag stale commands, dead paths, duplicated guidance, and routing failures.

### 2. Update routing docs

Keep top-level docs terse and navigational.

- `AGENTS.md` should be a table of contents, not a wiki
- `README.md` should lead with value and the fastest path to use or contribute
- Push detail downward instead of bloating top-level files

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

## Output

After docs work, report:

- files updated
- stale or duplicated docs removed or rewritten
- commands or paths verified
- remaining doc gaps
- any handoff needed to `harness` or `verify`

## References

- [references/documentation.md](references/documentation.md) — AGENTS.md shape, scoped rules, README patterns, doc hygiene
- [references/specifications.md](references/specifications.md) — feature specs, conformance tests, spec drift, SDD trade-offs
