# AGENTS.md

Repo-local contributor guidance. Global agent behavior lives in [`rules/agents.md`](rules/agents.md).

- Keep top-level docs short. Put skill depth in `skills/<name>/references/` only when it earns its keep.
- Skill frontmatter has `name` and `description` only.
- Descriptions should self-activate: what it does, when to use it, and the main boundary.
- Put shared guidance in one owning skill or reference.
- Check reality before editing docs or examples; keep commands and paths repo-valid.
- Run `npx tessl@0.79.1 skill review skills/<name>` for skill changes, or `./scripts/skills/review.sh` for broad changes.
- Use repo-relative links in checked-in Markdown. No absolute local paths, `file://`, or editor URIs.
