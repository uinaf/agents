# Documentation

Keep the repo legible to humans and agents. Docs rot silently — every code change is a potential doc change.

## Sources

- OpenAI AGENTS.md findings: https://openai.com/index/harness-engineering/
- Stripe scoped rules: https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents
- ETH Zurich AGENTS.md study (auto-generated content hurts): https://arxiv.org/abs/2503.01298
- Agent Skills progressive disclosure: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Agent Skills architecture: https://www.newsletter.swirlai.com/p/agent-skills-progressive-disclosure

## Contents

- [AGENTS.md](#agentsmd)
- [Scoped Rules](#scoped-rules)
- [README.md](#readmemd)
- [Architecture Docs](#architecture-docs)
- [Hygiene](#hygiene)
- [Keep Docs Alive](#keep-docs-alive)

## AGENTS.md

OpenAI's finding: "We tried the big AGENTS.md. It failed." Context is scarce — too much guidance = non-guidance, rots instantly, hard to verify.

### Structure

- **~100 lines** — table of contents, not encyclopedia
- Points to `docs/` directory for depth
- Include: boot command, test command, key conventions, pointers to detailed docs
- Exclude: architecture tours, full API docs, every lint rule

### What belongs in AGENTS.md

- How to boot the app (exact command)
- How to run tests (exact command)
- Key conventions that deviate from defaults
- Links to `docs/architecture.md`, `docs/api.md`, etc.
- Scoped rules pointer (e.g., "see per-directory AGENTS.md files")

### What doesn't belong

- Codebase overviews and directory listings (agents discover structure fine on their own — ETH Zurich)
- Auto-generated content (actively hurts performance — +20% cost, ETH Zurich)
- Conditional rules that apply only sometimes
- Implementation details that change frequently

### Enforcement

OpenAI enforces AGENTS.md health mechanically:
- Linters + CI validate freshness, cross-linking, structure
- "Doc-gardening" agent scans for stale docs and opens fix-up PRs

## Scoped Rules

Stripe's pattern: global rules used "very judiciously." Almost all rules scoped to subdirectories or file patterns, auto-attached as the agent navigates.

### How to implement

- Per-directory `AGENTS.md` or `.cursor/rules/*.mdc` files
- Rules attached to file globs (e.g., `*.test.ts` → testing conventions)
- Same rules work for Minions, Cursor, Claude Code — no duplication

### Benefits

- Agent picks up only relevant rules for the files it's touching
- No context waste from rules that don't apply
- Easier to maintain — each team/module owns its rules
- Rules stay close to the code they govern

### Example structure

```
src/
├── AGENTS.md           # global conventions (~100 lines)
├── api/
│   ├── AGENTS.md       # API-specific conventions
│   └── routes/
├── ui/
│   ├── AGENTS.md       # UI component conventions
│   └── components/
└── lib/
    └── AGENTS.md       # shared library conventions
```

## README.md

- **Lead** with one sentence: what the project is and why it exists
- **Put the fastest path to value near the top**: install, quickstart, docs, or demo
- **Link out** to deeper docs instead of duplicating them
- Keep contributing and license sections short

### Shape selection

- **Minimal product**: short value prop, one docs link (shadcn/ui pattern)
- **CLI**: install first, then quickstart, then docs links
- **Product + contributor**: short intro, install, dev entry points, contributing
- **With navigation/examples**: TOC, visual demo, usage examples

## Architecture Docs

- `docs/ARCHITECTURE.md` — diagram-first system view and important boundaries
- `docs/*.md` — task-specific references (API, deployment, guides, decisions)
- `docs/plans/*.md` — one plan per feature with goal, design, tasks, validation hooks

## Hygiene

Run periodically or after a burst of changes:

1. **Dedup**: same fact in multiple files → pick one canonical location, replace others with pointers
2. **Consistency**: names, commands, paths in one doc match what referenced docs say
3. **Conciseness**: section restates what a referenced doc covers → replace with one-line pointer
4. **Structure**: file growing past ~80 lines of prose → split detail into `references/`, keep parent as routing layer
5. **Staleness**: delete or archive docs for removed features, finished plans, superseded decisions
6. **Symlinks over copies**: two files need identical content → symlink, never two copies

## Keep Docs Alive

- After implementing a feature → check if AGENTS.md, README, or architecture docs need updating
- After renaming/moving/deleting code → grep docs for stale references
- After a design decision → record it in a decision doc or plan before moving on
- Treat doc drift the same as test failure — it degrades every future agent's performance
