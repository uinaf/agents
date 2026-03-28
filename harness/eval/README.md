# Harness Skill Evaluation

Test whether coding agents can actually follow the harness skill.

## How it works

1. Each `tasks/*.md` defines a task prompt + expected outcomes
2. Each `repos/` subdirectory is a minimal repo at a specific harness grade
3. Run an agent (Codex, Claude Code) in each repo with the task prompt
4. Compare output against expected outcomes

## Quick run

```bash
# Run a single eval
cd eval/repos/grade-f-no-boot
acpx --approve-all codex exec "$(cat ../../tasks/audit.md)"

# Compare output against expected
# (manual for now, automated grader TODO)
```

## Repos

| Repo | Grade | Description |
|------|-------|-------------|
| `grade-f-no-boot` | F | Express app, no start script, no tests, manual env setup |
| `grade-d-mock-only` | D | Express app, boots but all tests are mocked |
| `grade-c-basic` | C | Express app, boots with one command, one real smoke test |

## Tasks

| Task | File | What it tests |
|------|------|---------------|
| Audit | `tasks/audit.md` | Does the agent grade correctly? |
| Setup | `tasks/setup-smoke.md` | Can the agent add a smoke test? |
| Verify | `tasks/verify-change.md` | Does the agent verify on real surfaces? |

## Metrics

For each run, record:
- **Skill invoked?** Did the agent read the harness skill?
- **Grade correct?** Does the audit grade match expected?
- **Layers identified?** Did it name the right missing layers?
- **Evidence produced?** Screenshots, logs, response bodies?
- **Turns taken** — fewer = better skill guidance
- **Task completed?** Binary pass/fail per expected outcome
