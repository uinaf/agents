---
name: docs
description: "Update repo documentation and durable agent-facing artifacts such as AGENTS.md, README.md, docs/, specs, plans, decisions, and runbooks. Use when code, skill, or infrastructure changes risk doc drift or when documentation needs cleanup or restructuring. Do not use for code review, runtime verification, or boot/readiness infrastructure setup."
---

# Docs

Keep the repo legible to humans and agents.

## Principles

- Docs rot silently — every code change is a possible doc change
- Describe the current state, not the edit history; use before/after wording only when migration context helps the reader
- Routing docs stay short; depth lives in `docs/`
- No duplication when a pointer will do
- Use repo-relative links for in-repo docs; external links are fine in sources and references
- Keep current-state repo docs separate from agent work artifacts like plans, handoff prompts, specs, and decisions

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

Flag stale commands, dead paths, duplicated guidance, routing failures, and places where filenames or implementation order are leaking into the visible docs surface.

Before editing, classify the target: current-state repo docs for readers and contributors, agent guidance for future behavior, or agent work artifacts for planning, specs, decisions, and handoffs. Keep those surfaces linked but not blended.

Use the source-boundary table in [references/documentation.md](references/documentation.md) before writing cross-repo, private workspace, or local-machine facts into checked-in docs.

### 2. Update routing docs

Keep top-level docs terse and navigational.

- `AGENTS.md` should be a table of contents, not a wiki
- If the repo uses `AGENTS.md`, make `CLAUDE.md` a symlink or `@AGENTS.md` import instead of maintaining a second authored file
- `README.md` should lead with value, quick use, and links to deeper docs
- Refresh `CONTRIBUTING.md` and `SECURITY.md` when they already exist, or when redistributing current content out of an overloaded `README.md`; do not invent baseline policy from scratch
- For coordination or workspace repos, keep one canonical setup doc and let `README.md` point to it instead of repeating the full bootstrap flow inline
- Use the concrete top-level split and section order in [references/documentation.md](references/documentation.md)
- Use reader-facing labels in routing lists: `Contributing`, `Release workflow`, `Architecture`, or `Agent guide`, not raw filenames unless the filename matters

### 3. Update deep docs and specs

Refresh the detailed documents that actually carry the knowledge.

- architecture and API docs
- task guides and runbooks
- durable feature specs and decision records
- tactical plans and handoff prompts only when future agents need them
- readiness infrastructure docs after boot, smoke, observability, or isolation changes

Write each updated section as the reader's current source of truth. Use "previously/now" or "before/after" framing only in migration notes, changelogs, and decision records.

When the user asks to save a durable rule, prompt, plan, or decision, choose the owning repo surface first: `docs/decisions/` for durable choices, `docs/specs/` for contracts, `docs/plans/` for tactical execution, and agent guidance only for behavior future agents must repeat. Do not fold tactical agent plans into `README.md`, `CONTRIBUTING.md`, or general architecture docs.

For new features, use the directory layout and templates in [references/structuring.md](references/structuring.md) — specs, plans, and decisions each have their own shape.

### 4. Clean up drift

- deduplicate repeated facts
- delete or archive stale docs
- fix cross-links and moved paths
- keep naming and commands consistent across files
- keep one canonical home for setup or install commands in workspace-style repos, and replace copied command blocks elsewhere with short pointers
- normalize visible labels, casing, and section order when the docs read like a file tree instead of a user guide. Link targets may be paths; visible link text should usually be the document title or reader-facing purpose

Example — fixing a stale path after a rename:

```diff
 # AGENTS.md
-- Run the old bootstrap command to set up the dev environment.
+- Run the current setup command to set up the dev environment.
```

### 5. Validate reality

Verify prose against the repo. Check that commands, file paths, and entry points still match.

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
