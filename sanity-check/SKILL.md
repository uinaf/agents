---
name: sanity-check
description: "Post-implementation reality check. Run after tests pass, before declaring done. Use when completing a feature, bug fix, refactor, or integration — or when asked to verify, sanity check, or confirm something actually works."
allowed-tools: Bash
---

# Sanity Check

Passing tests is necessary but not sufficient. Before declaring done, verify your code matches the real world.

## When to Run

After implementation is complete and tests pass. Before committing or declaring done.

## Checks

### 1. Run with Real Data

- Execute the program with real inputs (dry-run if available).
- Check output makes sense — wrong numbers, weird dates, implausible results → investigate.
- If no dry-run mode exists, call real endpoints in a throwaway script and confirm the response matches your code's assumptions.

### 2. Cross-Check External APIs

- Verify every field name, enum value, and response shape against actual API docs.
- Don't trust what you "know" — open the docs and confirm.
- If you can't verify a field, response shape, or identifier from docs or real responses, **stop and ask**. A wrong guess that passes tests is worse than a blocker that gets flagged.

### 3. Smell Test

- Does the output look right to a human?
- Are the numbers in the right ballpark?
- Would you trust this if you saw it in production?

### 4. Contract Boundaries

- Changed a public API/interface? Verify all callers still work.
- Touched persistence/state? Verify read/write roundtrip with real data.
- Changed config? Verify the program starts with the new config.
- Schema/state changes must be forward-compatible. Document rollback path.

## If Something Smells Off

Don't rationalize it. Investigate. Don't burn tokens on workarounds — surface the issue.

## Output

After running checks, report:

- **Verified:** what you checked and how
- **Gaps:** things you couldn't verify and why
- **Confidence:** `ship it` / `needs review` / `blocked`
