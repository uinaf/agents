---
name: skill-audit
description: "Audit, score, or improve existing skills with Tessl review output, metadata checks, repo conventions, and skill-authoring best practices. Use when creating or revising a skill, asking why a skill did not activate, checking skill quality, comparing a skill against `AGENTS.md`, `CLAUDE.md`, or repo rules, or preparing a skill for publish. Do not use to verify general application code or to rewrite unrelated docs."
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

- Updating AGENTS, README, or other repo docs beyond the skill surface is documentation work.
- Proving a product or code change works on real surfaces is runtime verification work.
- Reviewing general code or a PR instead of a skill package is outside this skill's scope.

## Before You Start

1. Define scope: one skill folder or the whole skills repo
2. Load the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules, when present
3. Read the target `SKILL.md` first, then nearby `references/`, `scripts/`, and `agents/openai.yaml` only as needed
4. Run the common single-skill audit path first:

```bash
skill_dir="skills/<name>"
npx tessl@0.80.0 plugin lint "$skill_dir"
npx tessl@0.80.0 review run --workspace uinaf --threshold 0 --json "$skill_dir"
```

For a full repo batch, use the repo wrapper such as `./scripts/skills/review.sh` when present; otherwise repeat the direct Tessl review per skill. Use optimizer only when explicitly requested:

```bash
npx tessl@0.80.0 skill review --optimize --yes --max-iterations 1 skills/<name>
```

## Workflow

### Quick experiential feedback mode

Use this when the ask is "what did the skills fail to guide well during the last task?" rather than a formal skill audit.

1. Skip Tessl unless the user asks for scoring or the proposed edits touch trigger text.
2. Reconstruct the task failure from actual run evidence: wrong tool selected, bespoke script invented, missing hardening gate, unclear boundary, stale path, or excessive ceremony.
3. Map each failure to the smallest repo-owned skill/doc update that would have changed agent behavior.
4. Edit only those surfaces, then run the repo's normal skill review gate if available.

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

After an audit, report a compact audit footer:

- scope audited
- Tessl command and score
- findings: highest-priority issues only, or `none`
- changes: files changed or smallest recommended change
- rerun status if edits were made

Keep details compact:

- Report the Tessl score and actionable suggestions; summarize long output
- Keep the footer to 5 labeled lines or fewer
- If edits were made, name the behavioral change and verification

## References

- [references/scorecard.md](references/scorecard.md) — audit dimensions, severity, and a compact review template
- [references/best-practices.md](references/best-practices.md) — distilled skill-authoring guidance from common repo conventions and Claude's skill best-practices guide
