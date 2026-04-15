# Skill Audit Scorecard

Use this scorecard after Tessl so the audit stays evidence-based and repo-aware.

## Blockers

Treat these as must-fix before calling the skill ready:

- invalid frontmatter or missing `name` or `description`
- `description` fails discovery because it does not say what the skill does and when to use it
- commands, paths, or links are stale or broken
- workflow has no clear start, no evidence loop, or no completion criteria
- the skill conflicts with the target repo's guidance or conventions

## Major Findings

These usually lower trust or activation even if the skill technically works:

- `name` is vague, generic, or forgettable
- `SKILL.md` is bloated with detail that belongs in `references/`
- boundaries and handoffs are missing or muddy
- the skill asks the model to invent deterministic steps that should be scripted
- examples are abstract instead of practical
- optimizer use is suggested without explicit approval

## Minor Findings

These are worth tightening after the blockers and majors:

- wording is repetitive or over-explains obvious concepts
- output format is implied instead of stated
- references exist but are not linked from `SKILL.md`
- `agents/openai.yaml` lags behind the skill's current wording

## Audit Dimensions

Score each dimension qualitatively as `strong`, `mixed`, or `weak`:

- Discovery: can the right request trigger the skill from metadata alone
- Workflow: does the body tell the agent how to proceed and what evidence to gather
- Progressive disclosure: is detail placed in the right file
- Repo fit: does it match local conventions and links
- Verification: does it use Tessl or another concrete loop instead of taste-only review
- Boundaries: does it say when not to use the skill and where to hand off

## Compact Review Template

```text
scope audited:
Tessl:
strengths:
findings:
recommended changes:
rerun:
```
