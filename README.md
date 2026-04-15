# skills

Reusable agent skills for coding workflows. Progressive disclosure, mechanical verification, repo-first truth.

| Skill | What it does |
|-------|-------------|
| **agent-readiness** | Audit and build the infrastructure a repo needs so agents can work autonomously. Grades readiness, adds missing boot/test/observability layers, and unblocks verification |
| **docs** | Maintain AGENTS.md, README.md, docs/, runbooks, and specs. Keeps repo guidance concise, current, and non-duplicated |
| **review** | Review existing code, diffs, branches, and PRs with concern-specific reviewer personas and evidence |
| **skill-audit** | Audit skills with Tessl scoring, repo conventions, and skill-authoring best practices before calling them ready |
| **verify** | Verify your own completed change against the existing infrastructure and real surfaces before calling it done |
| **effect-ts** | Effect TypeScript patterns — setup, Layer/Schema/Service, platform packages, runtime wiring, Promise-to-Effect migration |
| **viteplus** | Migrate frontend repos to the stock VitePlus workflow across scripts, tests, CI, and packaging |

## Install

```bash
npx skills add uinaf/skills -g -s agent-readiness
npx skills add uinaf/skills -g -s docs
npx skills add uinaf/skills -g -s review
npx skills add uinaf/skills -g -s skill-audit
npx skills add uinaf/skills -g -s verify
npx skills add uinaf/skills -g -s effect-ts
npx skills add uinaf/skills -g -s viteplus
```

## Evaluate

Use [Tessl](https://tessl.io/), the skill-evaluation CLI used in this repo, to review and optionally optimize skills. If `npx tessl ...` does not resolve locally, check the [CLI docs](https://docs.tessl.io/reference/cli-commands) before running the review loop.

```bash
./eval/review-skills.sh
./eval/optimize-skills.sh review
```

The eval helpers and workflow notes live in `eval/`.

CI also runs `./eval/review-skills.sh` on pull requests and pushes to `main`.
