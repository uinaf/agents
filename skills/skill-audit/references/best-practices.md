# Skill Authoring Best Practices

This reference distills two sources of guidance that commonly shape good skills:

- [Claude skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- source-repo conventions and contributor guidance, when present

Use it when an audit finds weak activation, a bloated `SKILL.md`, or unclear workflow boundaries.

## Metadata And Discovery

- `name` should be concrete and easy to say out loud
- `description` should be in third person and include both what the skill does and when to use it
- the main overlap boundary should be explicit so similar skills do not all half-trigger
- generic names like `helper`, `tools`, or `utils` are usually a discovery smell

## Body Shape

- keep `SKILL.md` focused on the workflow, principles, boundaries, and routing
- assume the model is already smart; spend tokens on repo-specific judgment
- match the level of instruction to the task:
  - high freedom for contextual judgment
  - medium freedom when a preferred pattern exists
  - low freedom for fragile or high-risk operations
- say what evidence to gather and what a complete result should include

## Progressive Disclosure

- put durable detail, rubrics, and long examples in `references/`
- keep references one hop away from `SKILL.md`
- use scripts for repeated deterministic work instead of rewriting the same logic in prose
- if a reference is not worth loading on demand, it probably does not belong in the skill

## Repo Conventions To Enforce

- frontmatter must contain only `name` and `description`
- checked-in Markdown should use repo-relative links for local files
- practical, review-oriented examples beat generic filler
- if a mechanical check exists, prefer it over prose
- after changing a skill, rerun Tessl and tighten wording from the findings

## Audit Questions

- Would a realistic user request trigger this skill from metadata alone
- Does the first screenful tell the agent how to begin
- Is any paragraph teaching common knowledge instead of repo-specific judgment
- Are there stale commands, dead paths, or duplicated doctrine
- Is there a concrete evaluation loop, or only style advice
