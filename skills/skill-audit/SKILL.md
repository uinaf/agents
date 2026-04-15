---
name: skill-audit
description: "Audit existing skills with Tessl scoring, metadata and trigger-coverage checks, repo conventions, and skill-authoring best practices. Use when creating or revising a skill, triaging weak self-activation, or comparing a skill against source-repo guidance such as `AGENTS.md`, `CLAUDE.md`, or repo rules, plus external skill guidance. Do not use to verify general application code or to rewrite unrelated docs."
---

# Skill Audit

Audit a skill before calling it ready. Favor Tessl output, repo conventions, and the skill's actual file shape over taste.

`Tessl` is the skill-evaluation CLI this repo uses to review skills, score their quality, and suggest improvements. See [tessl.io](https://tessl.io/) and the [CLI docs](https://docs.tessl.io/reference/cli-commands). If `npx tessl ...` or `tessl ...` is unavailable, install or initialize Tessl before running the audit loop.

## Principles

- Evidence beats hunches
- Discovery matters: score `name` and `description` before polishing the body
- Keep `SKILL.md` lean; move depth into `references/` or scripts only when they earn their keep
- Prefer the smallest change set that improves activation, clarity, or verification
- Audit only the requested scope; flag adjacent issues separately

## Handoffs

- Need to update AGENTS, README, or other repo docs beyond the skill surface -> use `docs`
- Need to prove a product or code change works on real surfaces -> use `verify`
- Need to review general code or a PR instead of a skill package -> use `review`

## Before You Start

1. Define scope: one skill folder or the whole skills repo
2. Load the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules, when present
3. Read the target `SKILL.md` first, then nearby `references/`, `scripts/`, and `agents/openai.yaml` only as needed
4. Pick the right Tessl loop:
   - single skill: `npx tessl skill review --json skills/<name>`
   - full repo batch: use a repo wrapper such as `./eval/review-skills.sh` if one exists; otherwise run direct Tessl reviews per skill
   - optimizer only when explicitly requested: `npx tessl skill review --optimize --yes --max-iterations 1 skills/<name>`

## Workflow

### 1. Run Tessl first

Capture the score, summary, and concrete suggestions before proposing edits. Prefer per-skill `--json` when you need a narrow audit loop or structured output. If Tessl is missing, use `npx tessl ...` first or follow the official docs before continuing.

### 2. Audit discovery

Use [references/scorecard.md](references/scorecard.md) to check:

- whether `name` is specific and memorable
- whether `description` states what the skill does, when to use it, and its main boundary
- whether likely user phrasing would activate the skill without extra prompting

Quick example:

- weak: `helper` — "Helps with skills"
- stronger: `skill-audit` — "Audits existing skills with Tessl scoring, metadata checks, and repo conventions"

### 3. Audit workflow shape

Check that the skill tells the agent how to start, what evidence to gather, what not to change, and what "done" looks like.

Concrete failure signs:

- vague verbs like "help" without a workflow
- missing output expectations
- commands or paths that cannot be run as written
- a fragile task described with high-level prose instead of tighter guardrails

### 4. Audit progressive disclosure

Check whether detail belongs in `SKILL.md`, `references/`, or executable scripts:

- keep core workflow in `SKILL.md`
- move dense doctrine, examples, or score rubrics into `references/`
- use scripts for repeated deterministic work instead of asking the model to recreate them

Use [references/best-practices.md](references/best-practices.md) when the skill feels bloated, under-specified, or hard to trigger.

### 5. Audit repo fit

Check for repo-relative links, stale paths, duplicated guidance, and conflicts with the source repo's conventions.

### 6. Synthesize the smallest useful change set

Separate blockers from polish. If edits are requested, fix the highest-leverage issues first, rerun Tessl, and report what improved.

## Output

After an audit, report:

- scope audited
- Tessl command and score
- strongest parts worth keeping
- prioritized findings with file references
- smallest recommended changes
- rerun status if edits were made

## References

- [references/scorecard.md](references/scorecard.md) — audit dimensions, severity, and a compact review template
- [references/best-practices.md](references/best-practices.md) — distilled skill-authoring guidance from common repo conventions and Claude's skill best-practices guide
