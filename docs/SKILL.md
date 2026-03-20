---
name: docs
description: "Keep project docs useful for humans and agents. Use when creating or updating README, AGENTS, architecture docs, plans, or doing a docs audit."
---

# Docs

Keep the repo legible to humans and agents.

## Use It For

- Creating or updating `README.md`, `AGENTS.md`, architecture docs, guides, decisions, or plans.
- Auditing docs after code changes.
- Turning chat knowledge into durable repo knowledge.

## Avoid

- Turning `AGENTS.md` into a manual.
- Turning `README.md` into a full project handbook.
- Putting every detail in `SKILL.md` instead of routing to deeper docs or `references/`.
- Leaking chat-only absolute filesystem links into checked-in docs or skill references.
- Writing long prose when a table, diagram, pseudocode block, or check would work better.
- Leaving durable guidance in chat, tickets, or external docs.
- Keeping stale plans or duplicated instructions around.

## Defaults

- `README.md`: human-facing overview, setup, usage, contributing.
- `AGENTS.md`: short routing layer for agents; exact commands and links to deeper docs.
- `docs/ARCHITECTURE.md`: diagram-first system view and important boundaries.
- `docs/*.md`: task-specific durable references such as API, deployment, guides, and decisions.
- `docs/plans/*.md`: one plan per feature with goal, design, tasks, and validation hooks for autonomous execution.
- For README patterns and examples, read `references/readme-examples.md`.

## Workflow

1. Inspect the repo and current docs first.
2. Keep `README.md` and `AGENTS.md` short. Move task-specific detail into `docs/*`. For README work, pick a shape from `references/readme-examples.md`.
3. Keep `SKILL.md` to triggers and workflow; move heavier detail to `references/` when it helps repeated use.
4. Update only the docs touched by the change, and ground claims in the repo or command output.
5. In checked-in docs, use repo-relative Markdown links for local files. Reserve absolute filesystem paths for chat/UI file references, not versioned docs.
6. When changing Markdown links, verify that each local link target exists and that every claimed doc path resolves inside the repo.
7. Record boot steps, validation steps, and handoff details in plans when they matter.
8. Delete or archive stale plans, duplicated guidance, and AI slop.
9. If drift keeps recurring, add a check or template instead of another paragraph.

## Keep docs alive

Docs rot silently. Every code change is a potential doc change. Update docs as part of the work, not after.

- After implementing a feature, check if AGENTS.md, README, or architecture docs need updating.
- After renaming, moving, or deleting code, grep docs for stale references.
- After a design decision, record it in a decision doc or plan before moving on.
- Treat doc drift the same as test failure — it degrades every future agent's performance.

## Hygiene

Run periodically or after a burst of changes to keep docs tight.

1. **Dedup**: search for the same fact stated in multiple files. Pick one canonical location, remove or replace the others with a pointer.
2. **Consistency**: verify that names, lanes, commands, and file paths mentioned in one doc match what the referenced doc actually says.
3. **Conciseness**: if a section restates what a referenced doc already covers, replace it with a one-line pointer.
4. **Structure**: if a file is growing past ~80 lines of prose, split detail into `references/` and keep the parent file as a routing layer.
5. **Staleness**: delete or archive docs that describe removed features, finished plans, or superseded decisions.
6. **Symlinks over copies**: if two files must have identical content, use a symlink. Never maintain two copies of the same text.
