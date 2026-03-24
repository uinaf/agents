# skills

Reusable agent skills for coding workflows. Progressive disclosure, mechanical verification, repo-first truth.

| Skill | What it does |
|-------|-------------|
| **docs** | Keep project docs legible to humans and agents. AGENTS as TOC, deeper guidance in versioned docs, command-backed audits |
| **effect-ts** | Effect TypeScript patterns — setup, Layer/Schema/Service, platform packages, runtime wiring, Promise-to-Effect migration |
| **harness** | Evaluate, set up, and improve agent-testable verification infrastructure (bootable env, interaction layer, observability) |
| **verify** | Post-implementation reality check. Run after tests pass, before declaring done — produces evidence, not assertions |

**harness** builds the tools. **verify** uses them.

## Install

```bash
npx skills add uinaf/skills -g -s harness
```
