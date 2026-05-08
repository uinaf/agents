---
name: docs
description: "Update repo documentation and agent-facing guidance such as AGENTS.md, README.md, docs/, specs, plans, and runbooks. Use when code, skill, or infrastructure changes risk doc drift or when documentation needs cleanup or restructuring. Do not use for code review, runtime verification, or `agent-readiness` setup."
---

# Docs

Keep the repo legible to humans and agents.

## Principles

- Docs rot silently — every code change is a possible doc change
- Documentation is part of the interface; optimize for scanability, rhythm, and visual clarity, not just correctness
- Describe the current state, not the edit history; use before/after wording only when migration context helps the reader
- Routing docs stay short; depth lives in `docs/`
- No duplication when a pointer will do
- Use repo-relative links for in-repo docs; external links are fine in sources and references
- Doc drift is a real failure, not polish debt

## Handoffs

- Missing boot, smoke, e2e, logs, or agent-readiness infrastructure → use `agent-readiness`
- Need to judge existing code, a diff, branch, or PR with evidence → use `review`
- Need to validate your own completed change on the real surface → use `verify`

## Workflow

### 1. Audit the doc surface

Check the files humans and agents actually rely on:

- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `docs/`
- plans, specs, runbooks, decision docs

Flag stale commands, dead paths, duplicated guidance, routing failures, and places where filenames or implementation order are leaking into the visible docs surface.

### 2. Update routing docs

Keep top-level docs terse and navigational.

- `AGENTS.md` should be a table of contents, not a wiki
- If the repo uses `AGENTS.md`, keep `CLAUDE.md` at the same level as a symlink to `AGENTS.md` instead of maintaining a second authored file
- `README.md` should lead with value and the fastest path to use the project
- `CONTRIBUTING.md` should hold contributor setup, validation, and workflow
- `SECURITY.md` should hold private-first vulnerability reporting guidance
- Push detail downward instead of bloating top-level files
- For coordination or workspace repos, keep one canonical setup doc and let `README.md` point to it instead of repeating the full bootstrap flow inline
- Use the concrete top-level split and section order in [references/documentation.md](references/documentation.md) instead of inventing a new shape every time
- Keep visible docs copy human-facing and task-ordered; let the reference file own the detailed labeling and scannability rules
- Use document titles or purpose labels in routing/index lists. Prefer `Contributing`, `Release workflow`, `Architecture`, or `Agent guide` over visible labels like `CONTRIBUTING.md`, `docs/RELEASE.md`, or `AGENTS.md`
- Prefer terse routing over narrative sprawl, for example `README.md` should link to deeper docs instead of re-explaining them inline

### 3. Update deep docs and specs

Refresh the detailed documents that actually carry the knowledge.

- architecture and API docs
- task guides and runbooks
- feature specs, plans, and decision records
- readiness infrastructure docs after agent-readiness changes

Write each updated section as the reader's current source of truth. Avoid "previously/now" or "before/after" framing unless the doc is a migration note, changelog, or decision record.

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
-- Run `scripts/bootstrap.sh` to set up the dev environment.
+- Run `scripts/setup.sh` to set up the dev environment.
```

### 5. Validate reality

Do not trust prose. Check that commands, file paths, and entry points still match the repo.

Concrete checks:

- `rg -n "old/path|stale-command" AGENTS.md CLAUDE.md README.md docs/` when paths or commands moved
- `test -e <path-from-docs>` before keeping a file reference
- `test ! -e AGENTS.md || { test -L CLAUDE.md && test "$(readlink CLAUDE.md)" = "AGENTS.md"; }` when normalizing agent entrypoints

## Output

After docs work, report a compact docs footer:

- files updated
- verified: command names or path checks, not output logs
- removed or rewritten: only if stale or duplicated docs changed
- gaps: remaining doc gaps, or `none`
- next: `agent-readiness`, `review`, `verify`, or `none`

Keep the footer to 5 labeled lines or fewer. Do not repeat the same file list in prose after listing changed files.

## References

- [references/documentation.md](references/documentation.md) — AGENTS.md shape, scoped rules, README patterns, doc hygiene
- [references/specifications.md](references/specifications.md) — feature specs, conformance tests, spec drift, SDD trade-offs
- [references/structuring.md](references/structuring.md) — directory layout, templates, and naming for specs, plans, and decisions
