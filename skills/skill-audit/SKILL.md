---
name: skill-audit
description: "Audit, score, or improve existing skills with Tessl review output, metadata checks, repo conventions, and skill-authoring best practices. Use when creating or revising a skill, asking why a skill did not activate, checking skill quality, comparing a skill against `AGENTS.md`, `CLAUDE.md`, or repo rules, or preparing a skill for publish. Do not use to verify general application code or to rewrite unrelated docs."
---

# Skill Audit

Audit a skill before calling it ready. Favor Tessl output, repo conventions, and the skill's actual file shape over taste.

## Principles

- Evidence beats hunches
- Discovery matters: score `name` and `description` before polishing the body
- Keep `SKILL.md` lean; move depth into `references/` or scripts only when they earn their keep
- Prefer the smallest change set that improves activation, clarity, or verification
- Audit only the requested scope; flag adjacent issues separately

## Boundaries

- Do not expand an audit into unrelated repo documentation, product/runtime verification, or general code review.
- Report an out-of-scope gap as a capability and required next step. Do not add cross-package invocation, routing, or requirements to the audited package.

## Before You Start

1. Define scope: one skill folder or the whole skills repo
2. Choose the mode before collecting evidence:
   - **Formal audit** for scoring, publish readiness, general quality review, or edits not anchored to a concrete recent failure
   - **Experiential feedback** only when the ask is explicitly about what a skill failed to guide in a recent task
3. Load the target repo's guidance files such as `AGENTS.md`, `CLAUDE.md`, or repo rules, when present
4. Read the target `SKILL.md` first, then nearby `references/`, `scripts/`, and `agents/openai.yaml` only as needed

For formal audit commands, batch behavior, and the explicitly requested optimizer path, follow [references/tessl.md](references/tessl.md). Never let a fallback silently resolve the latest Tessl CLI.

## Workflow

### 1. Collect mode-appropriate evidence

For a formal audit, capture the Tessl score, summary, and concrete suggestions before proposing edits. Prefer per-skill `--json` for a narrow or structured audit loop. If Tessl is missing, install the repo's audited version or follow the official docs before continuing.

For experiential feedback:

- Reconstruct the concrete failure from run evidence: wrong tool selected, bespoke script invented, missing hardening gate, unclear boundary, stale path, or excessive ceremony
- Map each failure to the smallest repo-owned skill or doc update that would have changed behavior
- Skip Tessl scoring unless the user asks for it or the proposed edit touches `name` or `description`
- After edits, still run plugin lint and the repo's normal skill gate when available

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

Use the scorecard's major findings as the detailed rubric. Treat unrunnable commands or paths, missing output gates, and vague or fragile workflows as blockers.

### 4. Audit progressive disclosure

Check whether detail belongs in `SKILL.md`, `references/`, or executable scripts:

- keep core workflow in `SKILL.md`
- move dense doctrine, examples, or score rubrics into `references/`
- use scripts for repeated deterministic work instead of asking the model to recreate them

Use [references/best-practices.md](references/best-practices.md) when the skill feels bloated, under-specified, or hard to trigger.

### 5. Audit repo fit

Check for repo-relative links, stale paths, duplicated guidance, and conflicts with the source repo's conventions.

Treat `agents/openai.yaml` as picker-facing metadata: keep `interface.default_prompt` to one scope-aligned sentence. Do not invent undocumented Codex limits; use the real loader or a shared versioned linter when deterministic enforcement is necessary.

Require package independence across frontmatter, picker metadata, bodies, references, scripts, and evals. A skill may state prerequisites and boundaries, but it must explain them locally instead of naming or requiring sibling skills.

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
- For a portfolio audit, name the compared packages in the report and distinguish metadata overlap from duplication that merits a merge, split, or new package; do not encode those comparisons as package dependencies

## References

- [references/scorecard.md](references/scorecard.md) — audit dimensions, severity, and a compact review template
- [references/best-practices.md](references/best-practices.md) — distilled skill-authoring guidance from common repo conventions and Claude's skill best-practices guide
- [references/tessl.md](references/tessl.md) — pinned formal-review, batch, and optimizer commands
