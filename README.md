# skills

Reusable agent skills, global behavioral rules, and cross-machine sync for AI coding agents (Claude Code, Codex, Cursor, Pi, openclaw). Progressive disclosure, mechanical verification, repo-first truth.

> Repo will be renamed to `uinaf/agents` once the merged layout settles. The previous `uinaf/agents` repo is preserved as `uinaf/agents-old` for history.

## Layout

- `skills/` — reusable skill packages (the table below)
- `rules/AGENTS.md` — global behavioral rules synced into every agent on every machine via `sync/pull.sh`
- `sync/` — cross-machine helpers: `pull.sh` (symlink rules + install skills), `push.sh` (publish local skill set into `sync/skills.json`)
- `scripts/` — repo-local Tessl helpers (`review-skills.sh`, `optimize-skills.sh`)
- `docs/` — deeper notes
- `AGENTS.md` (root) — contributor guide for working on this repo (separate from `rules/AGENTS.md`)

| Skill | What it does |
|-------|-------------|
| **agent-readiness** | Audit and build the infrastructure a repo needs so agents can work autonomously. Grades readiness, adds missing boot/test/observability layers, and unblocks verification |
| **docs** | Maintain AGENTS.md, README.md, docs/, runbooks, and specs. Keeps repo guidance concise, current, and non-duplicated |
| **review** | Review existing code, diffs, branches, and PRs with concern-specific reviewer personas and evidence |
| **skill-audit** | Audit skills with Tessl scoring, repo conventions, and skill-authoring best practices before calling them ready |
| **verify** | Verify your own completed change against the existing infrastructure and real surfaces before calling it done |
| **effect-ts** | Effect TypeScript patterns — setup, Layer/Schema/Service, platform packages, runtime wiring, Promise-to-Effect migration |
| **viteplus** | Migrate frontend repos to the stock VitePlus workflow across scripts, tests, CI, and packaging |
| **gh-release-pipeline** | Standardize a repo's GitHub Actions release flow — verify → semantic-release tags + publishes (npm, CocoaPods/SwiftPM, Go, Rust, GitHub Action) → version-bump back to main with `[skip ci]` |
| **gh-deploy-pipeline** | Standardize a repo's GitHub Actions deploy flow — push to main → detect lanes → verify + e2e against built artifacts → deploy each lane (Cloudflare Pages, AWS Amplify, GHCR + VPS) → smoke check |
| **uinaf-design-system** | Apply the uinaf brand identity to any uinaf output — web (Tailwind v4), blog / changelog / docs / READMEs, slides, OG / social, email, terminal banners, native app starting points |

## Sync (rules + skills together)

```bash
git clone git@github.com:uinaf/skills.git
cd skills
./sync/pull.sh
```

This symlinks `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.pi/agent/AGENTS.md` to `rules/AGENTS.md`, then installs the skills listed in `sync/skills.json` into whichever supported agents you have on the box. Re-run any time. To publish your local skill set into `sync/skills.json` and push, use `./sync/push.sh`.

## Install individual skills

```bash
npx skills add uinaf/skills -g -s agent-readiness
npx skills add uinaf/skills -g -s docs
npx skills add uinaf/skills -g -s review
npx skills add uinaf/skills -g -s skill-audit
npx skills add uinaf/skills -g -s verify
npx skills add uinaf/skills -g -s effect-ts
npx skills add uinaf/skills -g -s viteplus
npx skills add uinaf/skills -g -s gh-release-pipeline
npx skills add uinaf/skills -g -s gh-deploy-pipeline
npx skills add uinaf/skills -g -s uinaf-design-system
```

## Evaluate

Use [Tessl](https://tessl.io/), the skill-evaluation CLI used in this repo, to review and optionally optimize skills. If `npx tessl ...` does not resolve locally, check the [CLI docs](https://docs.tessl.io/reference/cli-commands) before running the review loop.

```bash
./scripts/review-skills.sh
./scripts/optimize-skills.sh review
```

The local Tessl helper scripts and workflow notes live in `scripts/`.

CI also runs `./scripts/review-skills.sh` on pull requests and pushes to `main`.
