# agents

Reusable agent skills, global behavioral rules, and cross-machine sync for AI coding agents (Claude Code, Codex, Cursor, Pi, openclaw). Progressive disclosure, mechanical verification, repo-first truth.

## Layout

- `skills/` — reusable skill packages (the table below)
- `rules/agents.md` — global behavioral rules synced into every agent on every machine via `scripts/sync/sync.sh`
- `scripts/sync/` — cross-machine helper: `sync.sh` (symlink rules + manifest skills)
- `scripts/skills/` — repo-local Tessl helpers (`review.sh`, `optimize.sh`)
- `docs/` — deeper notes
- `AGENTS.md` (root) — contributor guide for working on this repo (separate from `rules/agents.md`)

| Local skill | What it does |
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
git clone git@github.com:uinaf/agents.git
cd agents
./scripts/sync/sync.sh
```

This symlinks `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.pi/agent/AGENTS.md` to `rules/agents.md`, then installs or updates the skills listed in `scripts/sync/skills.json` into whichever supported agents you have on the box. The manifest includes these local skills plus selected external skills. Sync is additive by default: it does not remove skills that are not in this manifest. To remove stale globally installed skills whose source is `uinaf/agents`, run `./scripts/sync/sync.sh --prune`. Re-run any time.

## Install individual skills

```bash
npx skills add uinaf/agents -g -s agent-readiness
npx skills add uinaf/agents -g -s docs
npx skills add uinaf/agents -g -s review
npx skills add uinaf/agents -g -s skill-audit
npx skills add uinaf/agents -g -s verify
npx skills add uinaf/agents -g -s effect-ts
npx skills add uinaf/agents -g -s viteplus
npx skills add uinaf/agents -g -s gh-release-pipeline
npx skills add uinaf/agents -g -s gh-deploy-pipeline
npx skills add uinaf/agents -g -s uinaf-design-system
```

## Evaluate

Use [Tessl](https://tessl.io/), the skill-evaluation CLI used in this repo, to review and optionally optimize skills. If `npx tessl ...` does not resolve locally, check the [CLI docs](https://docs.tessl.io/reference/cli-commands) before running the review loop.

```bash
./scripts/skills/review.sh
./scripts/skills/optimize.sh review
```

The local Tessl helper scripts and workflow notes live in `scripts/skills/`.

CI also runs `./scripts/skills/review.sh` on pull requests and pushes to `main`.
