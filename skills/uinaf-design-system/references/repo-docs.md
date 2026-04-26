# Repo collaboration docs

Use this when shaping `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `AGENTS.md`, `CLAUDE.md`, or other top-level docs in a uinaf-owned repository (e.g. `github.com/uinaf/*`).

These files target collaborators and tooling — humans cloning the repo, agents reading instructions, GitHub's chrome rendering the page. They are not product-surface content. Treat them differently from anything that ships on `uinaf.dev`.

## Casing carve-out

Repo collaboration docs use **proper-case headlines** and **sentence-case body**. The lowercase product voice does not apply here.

- H1 is the project name in its canonical case. Most uinaf projects are lowercase code identifiers, so the H1 reads `# react-json-logic`, `# tccutil`, `# healthd`. If the project's canonical name is mixed-case, keep it.
- H2/H3 section headings use Title Case: `## Installation`, `## Basic Usage`, `## API Overview`, `### Component Props`. Not `## installation`.
- Body sentences capitalize their first word and proper nouns. `Use stable data-rjl-* attributes…` not `use stable data-rjl-* attributes…`.
- Code identifiers, file paths, URLs, and quoted proper nouns keep their canonical case as always (`AGENTS.md`, `pnpm`, `JsonLogic`, `Berkeley Mono`).

Why: GitHub renders these files in a serif/sans chrome where lowercase headings read as a typo, not a brand. The lowercase voice is calibrated for Berkeley Mono on a near-black canvas, which repo docs never get. Forcing the same rule into READMEs makes the repo look unfinished and gives agents a precedent to spread it everywhere.

## What stays from the brand voice

Casing is the only carve-out. Everything else still applies:

- Short, direct, dry. No SaaS sludge, no marketing flattery, no "We're on a mission to…".
- Sentence fragments are still fine. Periods at the end.
- No emoji. No exclamation marks.
- No `Unlock`, `Empower`, `Easily`, `Simply`, `Just`, `Reimagine`.
- Product/project blurbs follow the literal pattern: `react-json-logic — build and evaluate JsonLogic rules with React components.` The project name on the left stays in its canonical case.

If a sentence reads like a generic SaaS landing page, rewrite it.

## README.md

Default order. Skip a section when the repo genuinely doesn't need it; don't invent filler.

1. Hero — project name (H1), one literal sentence under it, optional one-line positioning sentence.
2. Installation — single fenced block with the canonical install command.
3. Basic Usage — smallest useful working example.
4. API Overview / Reference — exports, props, key types. Lists or tables, not prose.
5. Styling / Configuration — how to customize, when relevant.
6. Repo and Development — workspace shape and the commands a contributor or curious reader will actually run from the root.
7. Contributing — short, points to `CONTRIBUTING.md`.
8. Security — short, points to `SECURITY.md`.
9. License — short, points to `LICENSE`.

Patterns:

- Hero stays compact. Project name, one sentence, no logo block unless the project has a real recognizable mark. uinaf brand illustrations from `cdn.uinaf.dev` are fine when the repo warrants one — but most don't.
- Badges only when they signal real status: CI, version, license, downloads if relevant. No decorative badges. If using shields, match the uinaf monochrome treatment (`colorA=000000`, `colorB=000000`, `style=flat`).
- Use human-facing labels in section names (`Contributing`, `Security`, `License`), not raw filenames. The link target is the file.
- Don't dump every top-level file under a `Docs` section. Keep `Contributing`, `Security`, and `License` as their own sections.
- Don't include a "Features" bullet list. If the one-line description doesn't sell it, a bullet list won't.
- Repo-relative links for in-repo files (`[CONTRIBUTING.md](CONTRIBUTING.md)`). External links get the `↗` arrow as part of the link text.

## CONTRIBUTING.md

Default order:

1. Scope — what packages/apps live in the repo and what the publishable surface is.
2. Local Setup — install toolchain, install deps. One fenced block.
3. Daily Workflow — the canonical commands (`verify`, `test`, `check`, `build`, `dev:*`).
4. Commit and Pull Request Rules — Conventional Commits, PR focus, validation evidence.
5. Release and Deployment Notes — only when contributors actually need to know how the release pipeline behaves.

Patterns:

- Put environment bootstrap first. The reader is here to start working.
- Copy-pastable commands only, verified against the repo. No placeholder `<your-command>` left in.
- `pnpm verify` (or the repo's equivalent) is the canonical pre-PR gate. Mention it explicitly.
- Don't restate end-user usage; that lives in `README.md`.
- Keep the PR section short. If the repo has `.github/pull_request_template.md`, that file owns the detailed checklist; `CONTRIBUTING.md` points at it.

## SECURITY.md

Short, private-first. Default contact for uinaf repos is `dev@uinaf.dev`.

Sections (one or two short paragraphs each):

1. Reporting a Vulnerability — email `dev@uinaf.dev`. Do not open public issues.
2. What to Include — affected package/path, reproduction steps, impact, suggested mitigation.
3. Response Expectations — triaged as quickly as possible. Don't promise SLAs the studio can't keep.

Link from `README.md` when it materially helps navigation.

## AGENTS.md and CLAUDE.md

`AGENTS.md` is the single authored guidance file for AI agents working in the repo. Keep it a focused table of contents — what the repo is, the toolchain, where the meaningful code lives, the few conventions a fresh agent will trip on, and the commit rule. Push deeper detail into linked files.

- Keep `AGENTS.md` short. If it crosses ~150 lines, move detail into `references/` or `docs/`.
- `CLAUDE.md` should be a symlink to `AGENTS.md`, not a second authored file:
  ```bash
  ln -s AGENTS.md CLAUDE.md
  ```
- Use proper-case headlines here too. Agents read these files in editor and terminal contexts where lowercase headings break scanning.
- Don't paste the brand spec into `AGENTS.md`. If brand work is a real concern in the repo, link to this skill or the relevant docs.

## LICENSE

Most uinaf projects ship under MIT. The `LICENSE` file is the canonical text; `README.md` links to it from a one-line `License` section.

## Verify and delivery — the short version

The detailed model lives in other skills (`viteplus`, `agent-readiness`, `uinaf-frontend-repos` for cross-reference). uinaf's expectations at the repo-doc level:

- One repo-local `verify` entrypoint (`pnpm verify` for TypeScript) that gates everything.
- Every merge to `main` is assumed publishable or deployable. Document the publish path in `CONTRIBUTING.md` so contributors aren't surprised when their merged commit ships.
- Conventional Commits for commit messages. `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `ci`, `build`. Breaking changes marked with `!` or a `BREAKING CHANGE:` footer.
- VitePlus is the default toolchain for new TypeScript repos. Drive `vp` per package, `pnpm` workspace-wide. Don't invoke `vite` or `vitest` directly.

If the repo can't currently boot, verify, or deliver autonomously, that's an `agent-readiness` problem, not a docs problem — but the docs should reflect reality, not aspiration.

## Reference example

[github.com/uinaf/react-json-logic](https://github.com/uinaf/react-json-logic) is the closest published example of this shape. Read its `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, and `AGENTS.md` before reshaping a different repo. Copy the structure, not the wording.

## Checklist

- H1 uses the project's canonical case. H2/H3 use Title Case.
- Body uses sentence case, uinaf voice, no SaaS sludge, no emoji, no exclamation marks.
- `README.md` answers what the project is, how to install it, and how to use it within the first screen.
- `CONTRIBUTING.md` puts setup first and surfaces the canonical `verify` command.
- `SECURITY.md` is private-first and points to `dev@uinaf.dev`.
- `AGENTS.md` exists when agents are expected to work in the repo. `CLAUDE.md` is a symlink to it.
- `LICENSE` exists and is linked from `README.md`.
- Every command, link, badge target, and contact address is verified against the repo.
- No absolute filesystem paths, `file://` links, or editor-specific URIs in checked-in docs.
