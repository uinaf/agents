---
name: docs
description: "Update repo documentation and durable agent-facing artifacts such as AGENTS.md, README.md, docs/, specs, plans, decisions, and runbooks. Use when code, skill, or infrastructure changes risk doc drift or when documentation needs cleanup or restructuring. Do not use for code review, runtime verification, or boot/readiness infrastructure setup."
---

# Docs

Keep the repo legible to humans and agents.

## Principles

- Docs rot silently — every code change is a possible doc change
- Describe current state; keep history only in migration notes, changelogs, and decisions
- Keep routing docs short and point to deeper docs instead of duplicating them
- Use repo-relative links for in-repo docs
- Keep repo docs, agent guidance, and work artifacts linked but distinct

## Handoffs

Not docs work: boot/readiness setup; baseline PR, issue, contributor, or security policy templates; independent code review; runtime verification.

## Workflow

### 1. Audit the doc surface

Check the files humans and agents actually rely on:

- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `docs/`
- durable specs, active plans, runbooks, and decision docs

Flag stale commands, dead paths, duplicate guidance, routing failures, and repo-internal details leaking into reader-facing docs.

Before editing, classify the target as repo docs, agent guidance, or work artifacts such as plans, specs, decisions, and handoffs.

Use the source-boundary table in [references/documentation.md](references/documentation.md) before writing cross-repo, private workspace, or local-machine facts into checked-in docs.

### 2. Update routing docs

Keep top-level docs terse and navigational.

- `AGENTS.md` should be a table of contents, not a wiki
- If the repo uses `AGENTS.md`, make `CLAUDE.md` a symlink or `@AGENTS.md` import instead of maintaining a second authored file
- `README.md` should lead with value, quick use, and links to deeper docs
- Refresh `CONTRIBUTING.md` and `SECURITY.md` when they already exist or when moving existing policy out of an overloaded `README.md`; do not invent baseline policy from scratch
- For workspace repos, keep one canonical setup doc and let `README.md` point to it
- Use the concrete top-level split and section order in [references/documentation.md](references/documentation.md)
- Use reader-facing labels in routing lists; use raw filenames only when the filename matters

### 3. Update deep docs and specs

Refresh the detailed documents that carry the knowledge.

- architecture and API docs
- task guides and runbooks
- durable feature specs and decision records
- tactical plans and handoff prompts only when future agents need them
- readiness infrastructure docs after boot, smoke, observability, or isolation changes

Write each updated section as the reader's current source of truth.

When the user asks to save a durable rule, prompt, plan, or decision, choose the owning surface: `docs/decisions/`, `docs/specs/`, `docs/plans/`, or agent guidance for behavior future agents must repeat.

For new features, use the directory layout and templates in [references/structuring.md](references/structuring.md) — specs, plans, and decisions each have their own shape.

### 4. Clean up drift

- deduplicate repeated facts
- delete or archive stale docs
- fix cross-links and moved paths
- keep naming, labels, casing, commands, and section order consistent
- keep one canonical home for setup or install commands and replace copied command blocks with pointers
- prefer reader-facing link text over raw paths unless the path is the point

Example — fixing a stale path after a rename:

```diff
 # AGENTS.md
-- Run the old bootstrap command to set up the dev environment.
+- Run the current setup command to set up the dev environment.
```

### 5. Validate reality

Verify prose against the repo.

Concrete checks:

- `rg -n "old/path|stale-command" AGENTS.md CLAUDE.md README.md docs/` when paths or commands moved
- `rg -n "<new command|new path|decision keyword>" AGENTS.md CLAUDE.md README.md docs/` to find duplicate or conflicting homes
- `test -e <path-from-docs>` before keeping a file reference
- `test ! -e AGENTS.md || { test -L CLAUDE.md && test "$(readlink CLAUDE.md)" = "AGENTS.md"; }` when normalizing agent entrypoints
- for claims sourced from outside the repo, cite or verify the upstream source before making the claim durable

## Output

After docs work, report a compact docs footer:

- files updated
- verified: command names or path checks, not output logs
- removed or rewritten: only if stale or duplicated docs changed
- gaps: remaining doc gaps, or `none`
- next: readiness setup, independent review, runtime verification, or `none`

Keep the footer to 5 labeled lines or fewer. List changed files once.

## References

- [references/documentation.md](references/documentation.md) — AGENTS.md shape, scoped rules, README patterns, doc hygiene
- [references/specifications.md](references/specifications.md) — feature specs, conformance tests, spec drift, SDD trade-offs
- [references/structuring.md](references/structuring.md) — directory layout, templates, and naming for specs, plans, and decisions
