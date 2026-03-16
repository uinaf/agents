---
name: verify
description: "Reality-check code after tests pass. Use when finishing a feature, bug fix, refactor, code review, or when asked to verify something works end to end."
---

# Verify

Passing tests is necessary, not sufficient. Use the harness to prove the change works.

## Rules

- If you did not run it, you did not verify it.
- Prefer generic tools the model already understands: shell commands, app entrypoints, HTTP clients, browser automation.
- Record the commands and artifacts so another agent can repeat the check.

## Subagents

When the work splits cleanly by concern, use parallel subagents. For named lanes, model guidance, and what each lane should look for, read `references/subagent-lanes.md`.

## Checks

### 1. Real Surface
- Run the shipped CLI, service, job, or UI flow with representative inputs.
- For UI flows, prefer browser automation or CDP and inspect the DOM, screenshots, and network behavior.
- For services, hit the real local endpoint and confirm the full round trip.

### 2. External Contracts
- Verify field names, enums, and response shapes against docs or real responses.
- If you cannot verify a contract detail, stop and surface the gap.

### 3. State and Config
- Verify public interfaces still work end to end.
- Verify persistence/state round trips with real data where relevant.
- Verify config changes by starting the program with the new config.

### 4. Smell Test
- Check that outputs look plausible to a human.
- Investigate anything odd instead of rationalizing it.

### 5. Proof of Work
- Keep the evidence: screenshots, logs, traces, sample responses, generated files.

## Output

Report:

- `Verified`: what you checked
- `Commands`: what you ran
- `Artifacts`: what evidence you inspected
- `Gaps`: what you could not verify
- `Confidence`: `ship it` / `needs review` / `blocked`
