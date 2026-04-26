# AGENTS.md

Instructions for contributors in this repo. For the *global behavioral rules* synced to every machine, see [`rules/agents.md`](rules/agents.md) — different file, different scope.

- Treat `AGENTS.md` as a table of contents, not a manual. Put skill-specific depth in each skill's `references/`.
- Use progressive disclosure. Keep core workflow in `SKILL.md`; move deeper detail to `references/` when it earns its keep.
- Keep `README.md` and `AGENTS.md` concise. Put task-specific detail in `docs/*`.
- Do not duplicate guidance across skills.
- Every skill must have frontmatter `name` and `description` only.
- Make each skill description self-activating: say what it does, when to use it, and the main boundary when overlap is likely.
- Prefer iterative versions (`v0`, `v1`, ...) over giant first drafts.
- Keep examples practical and review-oriented.
- Keep the repo as the system of record. If guidance matters, write it into versioned files.
- Prefer mechanical enforcement over prose when a rule can be checked by scripts, templates, or CI.
- Prefer harness evidence over intuition. Inspect files, run commands, and tune wording from what the repo actually does.
- When changing a skill, run `npx tessl skill review skills/<name>`; for broader skill work, run `./scripts/skills/review.sh` and use the feedback to tighten wording and workflow.
- In checked-in Markdown, use repo-relative links for local docs and references. Never commit absolute filesystem targets such as `/Users/...`, `file://...`, or `vscode://...`.
