# skills

Reusable agent skills for coding workflows. Progressive disclosure, mechanical verification, repo-first truth.

| Skill | What it does |
|-------|-------------|
| **harness** | Build, audit, and improve verification infrastructure. Grades agent-readiness, adds missing boot/test/observability layers, and unblocks verification |
| **docs** | Maintain AGENTS.md, README.md, docs/, runbooks, and specs. Keeps repo guidance concise, current, and non-duplicated |
| **review** | Review existing code, diffs, branches, and PRs with concern-specific reviewer personas and evidence |
| **verify** | Verify your own completed change against the existing harness and real surfaces before calling it done |
| **effect-ts** | Effect TypeScript patterns — setup, Layer/Schema/Service, platform packages, runtime wiring, Promise-to-Effect migration |

## Install

```bash
npx skills add uinaf/skills -g -s harness
npx skills add uinaf/skills -g -s docs
npx skills add uinaf/skills -g -s review
npx skills add uinaf/skills -g -s verify
npx skills add uinaf/skills -g -s effect-ts
```

## Evaluate

Use Tessl to review and optionally optimize skills:

```bash
./eval/review-skills.sh
./eval/optimize-skills.sh review
```

The eval helpers and workflow notes live in `eval/`.
