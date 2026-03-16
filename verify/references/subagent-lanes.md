# Subagent Lanes

Use narrow review lanes. Each subagent should own one concern, gather evidence, and report only meaningful findings.

## Good Review Lanes

- `security`: auth, secrets, injection, access control, unsafe input handling.
- `tests`: missing behavioral coverage, weak edge-case coverage, brittle tests.
- `silent-failures`: swallowed errors, broad catches, hidden fallbacks, poor user feedback.
- `types-and-contracts`: type design, invariants, API contracts, schema drift.
- `maintainability`: unnecessary complexity, duplication, awkward abstractions, simplification opportunities, inaccurate comments, misleading docs.

## Good Sanity-Check Lanes

- `ui-surface`: browser flow, DOM state, screenshots, navigation, regressions.
- `api-surface`: endpoints, status codes, payloads, error shapes.
- `state-and-config`: persistence round trips, config boot, migrations, environment assumptions.
- `external-contracts`: third-party APIs, enum values, response shapes, integration assumptions.

## Main Agent Role

- Spawn subagents only when lanes are independent.
- Wait for all subagents before concluding.
- Merge their findings into one prioritized result.
- Filter aggressively. Prefer a few high-confidence issues over many weak ones.

## Avoid

- One vague "review everything" subagent.
- Parallel writes to the same files.
- Splits where one lane depends on another lane's output.
