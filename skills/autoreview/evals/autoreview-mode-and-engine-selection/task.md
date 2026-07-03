# Autoreview Setup and Target Selection

## Problem Description

A mid-size engineering team recently adopted an autoreview helper to run structured code reviews as part of their development workflow. One of the senior engineers has been asked to document the correct way to invoke the helper for three common situations that arise in day-to-day work:

1. A developer has made changes locally and has not yet committed them — the edits are sitting in the working tree as unstaged or staged modifications.
2. A developer has pushed a feature branch and opened a pull request against `main`, but the branch has not yet been merged.
3. A developer has just pushed a small fix directly to `main`, and now wants a review of that most recent commit.

The team uses the autoreview helper as a global skill. The environment does not have any special engine override requested — the team wants to use whatever the normal, recommended default engine is.

A new team member will follow this documentation exactly, so every invocation must use the correct mode flag, the correct environment setup, and must avoid any options that the team has not explicitly asked for.

## Output Specification

Write a shell script named `review-plan.sh` that covers all three scenarios described above. Each scenario should be clearly labeled with a comment explaining which situation it addresses. The script should:

- Set up the environment variables needed to reference the helper (assume global skill installation)
- Invoke the helper with the appropriate flags for each of the three scenarios
- Not include any flags or options that were not requested (e.g., multi-engine panels, Claude engine override)

The file `review-plan.sh` should be executable and syntactically valid shell.
