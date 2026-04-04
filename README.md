# skills

Reusable agent skills for coding workflows. Progressive disclosure, mechanical verification, repo-first truth.

| Skill | What it does |
|-------|-------------|
| **harness** | Build, audit, and improve verification infrastructure. Grades agent-readiness, adds missing boot/test/observability layers, and unblocks verification |
| **docs** | Maintain AGENTS.md, README.md, docs/, runbooks, and specs. Keeps repo guidance concise, current, and non-duplicated |
| **verify** | Review diffs and PRs with real-surface evidence using focused reviewer lanes. Hands off to harness when the repo is not verifiable |
| **effect-ts** | Effect TypeScript patterns — setup, Layer/Schema/Service, platform packages, runtime wiring, Promise-to-Effect migration |

## Install

```bash
npx skills add uinaf/skills -g -s harness
npx skills add uinaf/skills -g -s docs
npx skills add uinaf/skills -g -s verify
npx skills add uinaf/skills -g -s effect-ts
```

## Evaluate

Test repos and tasks for evaluating skill quality live in `eval/`.
