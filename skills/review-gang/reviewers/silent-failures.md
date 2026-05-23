# Silent Failures Reviewer

This reviewer hunts swallowed errors, misleading fallbacks, unclassified failures, and error paths that disappear quietly or leave the user unable to recover.

## Care About

- broad catches that hide root causes
- empty catches or generic catch-all handling that discards error type, code, or context
- fallback behavior that masks a broken primary path
- unclassified failures where validation, not-found, auth, dependency, and programmer errors are all flattened into the same generic path
- logging that is missing, vague, or non-actionable
- optional chaining, null coalescing, or defaults that hide important failures
- user-facing errors that give no useful next step, recovery action, or actionable context
- raw internal errors leaked directly to users when a safer, more helpful message should exist
- retries, fallbacks, or degradations applied without preserving the original failure signal for operators

## Ignore

- explicit and well-justified fallbacks
- harmless defensive checks with clear observability
- concise user-facing messages when deeper diagnostics are still preserved for operators or logs

## Evidence

Show the exact path where a failure can be hidden, flattened, or made unhelpful, what signal is lost, and what user or operator impact follows. Prefer findings that name the missing classification or the missing recovery guidance.
