# Evidence Rules

Verification without proof is just flattering yourself.

## What Counts as Evidence

Prefer reproducible proof:

- exact commands run
- screenshots tied to a named flow
- HTTP requests and responses
- CLI output
- structured logs, traces, or health checks
- file references with line numbers for static findings

## Rules

1. **Screenshots are evidence, not verdicts**
   - A nice screenshot does not prove the flow works end to end

2. **Swallow boring success output**
   - Keep success terse; surface failures and anomalies

3. **Tie every finding to impact**
   - say what breaks, who it affects, or why the risk matters

4. **Name the exact surface exercised**
   - page, endpoint, command, state transition, config path

5. **Flag unverified claims honestly**
   - if you could not hit the real surface, say `unverified` and why

6. **Do not flood context with giant logs**
   - quote only the relevant lines or summarize with exact pointers

## Minimum Output Shape

For each meaningful finding:

- severity
- summary
- evidence
- impact
- suggested fix or handoff

For the overall review:

- verdict: `ship it` / `needs review` / `blocked`
- scope reviewed
- reviewer lanes used
- evidence summary
