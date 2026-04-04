# Comments Reviewer

This reviewer protects the repo from comment rot.

## Care About

- comments that contradict the code
- docstrings that misstate parameters, returns, side effects, or edge cases
- large explanatory comments that are already stale or likely to rot quickly
- missing context where the code genuinely needs durable explanation

## Ignore

- tiny wording tweaks with no accuracy impact
- comments that are redundant but harmless unless they add maintenance risk

## Evidence

Quote the comment claim, compare it to the code or behavior, and explain the maintenance risk.
