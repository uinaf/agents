# Documentation

Keep the repo legible to humans and agents. Docs rot silently — every code change is a potential doc change.
Documentation is part of the interface; optimize for scanability, rhythm, and visual clarity, not just correctness.

## Sources

- OpenAI AGENTS.md findings: https://openai.com/index/harness-engineering/
- Stripe scoped rules: https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents
- ETH Zurich AGENTS.md study (auto-generated content hurts): https://arxiv.org/abs/2503.01298
- Agent Skills progressive disclosure: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Agent Skills architecture: https://www.newsletter.swirlai.com/p/agent-skills-progressive-disclosure

## Contents

- [AGENTS.md](#agentsmd)
- [Scoped Rules](#scoped-rules)
- [Top-Level Doc Split](#top-level-doc-split)
- [README.md](#readmemd)
- [CONTRIBUTING.md](#contributingmd)
- [SECURITY.md](#securitymd)
- [Docs Section](#docs-section)
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
- Keep headings and bullets scannable. Prefer task-shaped labels like `Start here`, `Commands`, `Validation`, or `Repo rules` over headings that mirror internal filenames or implementation structure

### What belongs in AGENTS.md

- How to boot the app (exact command)
- How to run tests (exact command)
- Key conventions that deviate from defaults
- Links to `docs/architecture.md`, `docs/api.md`, etc.
- Scoped rules pointer (e.g., "see per-directory AGENTS.md files")
- Section order that follows agent workflow: orient, run, verify, then special rules or hotspots

### What doesn't belong

- Codebase overviews and directory listings (agents discover structure fine on their own — ETH Zurich)
- Auto-generated content (actively hurts performance — +20% cost, ETH Zurich)
- Conditional rules that apply only sometimes
- Implementation details that change frequently
- Labels or section names that read like raw filesystem output when a clearer human-facing title would do

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

## Top-Level Doc Split

Use a small default top-level set with one responsibility per file:

- **`README.md`** — what the project is, how to install it, how to use it
- **`CONTRIBUTING.md`** — contributor setup, validation commands, branch/PR workflow
- **`SECURITY.md`** — private-first vulnerability reporting path and boundaries
- **`LICENSE`** — legal terms, not contributor instructions

Do not cram all four responsibilities into `README.md` unless the repo is tiny enough that the split adds no value.

General doc-surface rules:

- Visible labels should describe purpose, not filenames. Prefer `Contributing`, `Release workflow`, or `Architecture` over `CONTRIBUTING.md` or `docs/RELEASE.md`
- Use consistent casing for visible prose and navigation. Reserve all-caps names or extension-bearing filenames for literal file references only
- Order sections and link lists by reader task flow or importance, not by directory layout or implementation order
- Apply the same rule to agent-facing docs and internal guides, not just user-facing README copy

## README.md

Use this default order unless the repo gives you a strong reason not to:

1. **Hero** — name + one-sentence purpose
2. **Install** — fastest path to getting it running or consuming it
3. **Quick usage** — one first successful flow
4. **Optional examples / variants / integration notes**
5. **Docs** — compact navigation to deeper material
6. **Contributing** — short pointer to `CONTRIBUTING.md`
7. **License** — short pointer to `LICENSE`

Guidance:

- **Lead** with one sentence: what the project is and why it exists
- **Put the fastest path to value near the top**: install, quickstart, docs, or demo
- **Link out** to deeper docs instead of duplicating them
- Keep contributing and license sections short
- For package repos, show install plus one short usage example
- For app repos, keep end-user usage in `README.md` and move contributor setup to `CONTRIBUTING.md`
- Use human-facing labels in README navigation. Prefer `Contributing`, `Architecture`, `Distribution`, or `Security` over raw filenames or paths like `CONTRIBUTING.md` or `docs/RELEASE.md`
- Order navigation for readers, not for the filesystem. Put the most useful docs first instead of mirroring path order
- Apply the same rule to section titles and callouts around the README, not just the bullet links

### Shape selection

- **Minimal product**: short value prop, one docs link
- **CLI/package**: install first, then quickstart, then docs links
- **Product + contributor**: short intro, install, usage, docs, contributing
- **With navigation/examples**: TOC, visual demo, usage examples

## CONTRIBUTING.md

Use this default order unless the repo gives you a strong reason not to:

1. **Setup**
2. **Run locally**
3. **Validation**
4. **Development notes**
5. **Pull request expectations**
6. **Release notes** only if contributors genuinely need them

Guidance:

- Put environment bootstrap first
- Keep commands copy-pastable and verified against the repo
- Include only contributor-facing commands here: install toolchain, install dependencies, run locally, run checks
- Keep repo-specific development notes only when they materially help contributors
- Link deeper docs instead of letting `CONTRIBUTING.md` turn into a handbook
- Keep visible labels and headings contributor-facing rather than file-oriented here too. For example, prefer `Pull request expectations` over a heading or bullet that just echoes a filename

## SECURITY.md

Keep it short and private-first.

Default shape:

1. **Contact**
2. **Scope**
3. **Guidelines**
4. **Supported versions**
5. **Disclosure**

Guidance:

- Tell reporters not to open public issues for vulnerabilities
- Use the repo's real security contact; do not guess
- Link from `README.md` only when it helps navigation instead of crowding the user flow

## Docs Section

When `README.md` has a `Docs` section, keep it compact and canonical.

- Link to deeper docs without dumping their contents into the README
- Common links: About, Guides, Architecture, Deployment, Security
- Do not treat it like a directory listing. Use human labels, not raw filenames or paths
- Keep `Contributing` and `License` in their own sections when the README already has those sections
- Put agent-only or generated docs last, or move them into a small `Repo Internals` section when that reads better
- Do not duplicate the same navigation list across multiple top-level files
- Keep it skimmable
- Carry the same ordering rule into other visible lists and sections across the doc surface. If a sequence reads like filesystem order instead of reader priority, rewrite it

## Architecture Docs

- `docs/ARCHITECTURE.md` — diagram-first system view and important boundaries
- `docs/*.md` — task-specific references (API, deployment, guides, decisions)
- `docs/plans/*.md` — one plan per feature with goal, design, tasks, validation hooks

## Hygiene

Run periodically or after a burst of changes:

1. **Dedup**: same fact in multiple files → pick one canonical location, replace others with pointers
2. **Consistency**: names, commands, paths in one doc match what referenced docs say
3. **Labeling**: visible labels read like a file tree or internal implementation detail → rewrite them in reader-facing language
4. **Ordering**: sections or bullet lists mirror path order instead of reader priority → reorder them
5. **Conciseness**: section restates what a referenced doc covers → replace with one-line pointer
6. **Scannability**: agent-facing docs are technically correct but visually awkward, over-cased, or hard to skim → rewrite for fast orientation
7. **Structure**: file growing past ~80 lines of prose → split detail into `references/`, keep parent as routing layer
8. **Staleness**: delete or archive docs for removed features, finished plans, superseded decisions
9. **Symlinks over copies**: two files need identical content → symlink, never two copies

## Keep Docs Alive

- After implementing a feature → check if AGENTS.md, README, or architecture docs need updating
- After renaming/moving/deleting code → grep docs for stale references
- After a design decision → record it in a decision doc or plan before moving on
- Treat doc drift the same as test failure — it degrades every future agent's performance
