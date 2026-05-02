---
name: cross-harness-review
description: "Run a read-only code review through the opposite AI coding harness and return uinaf `review`-style findings, evidence, unverified gaps, and a ship-it / needs-review / blocked verdict. Use for `/review-with-claudex`, cross-harness review, opposite-model review, Claude reviewing Codex work, or Codex reviewing Claude work. Not an implementation or fix loop."
---

# Cross-Harness Review

Use the other coding harness as the independent reviewer, then report in the compact `review` verdict shape.

## Workflow

1. Define the review target from the user's request: uncommitted diff, branch vs base, commit, PR, or named paths. If unspecified, review the current uncommitted diff.
2. Detect the active harness:
   - In Codex/OpenAI, invoke Claude Code for the review.
   - In Claude/Anthropic, invoke Codex for the review.
3. Run the preflight checks for the opposite harness.
4. Delegate with the shared prompt below, filled with the target.
5. Preserve the other harness's findings; note any local confirmation or dispute.
6. Stop after one other-model review unless the user explicitly asks for an iterative loop.

For CLI flag details, fallback commands, and hosted-review cautions, read [references/headless-modes.md](references/headless-modes.md).

## Preflight

Check only the opposite harness:

```bash
# Codex active -> Claude reviewer
command -v claude
claude --version
claude auth status

# Claude active -> Codex reviewer
command -v codex
codex --version
codex login status
```

Report only installed/authenticated status. Do not print account details, tokens, or config contents.

## Shared Prompt

```text
Use /review or $review if available. Otherwise follow the uinaf review contract:
findings first, then verdict exactly one of ship it / needs review / blocked,
then evidence, unverified, next, and optional notes.

Target: <uncommitted diff | branch vs base | commit | PR | paths>

Review read-only. Do not edit files, stage changes, commit, or apply fixes.
Prioritize bugs, regressions, missing tests, silent failures, and contract drift. Use concise evidence with file/line references and targeted command results.
```

## Codex Active

Use Claude Code print mode:

```bash
claude -p \
  --permission-mode dontAsk \
  --allowedTools "Read,Glob,Grep,LS,Bash(git *),Bash(rg *),Bash(jq *),Bash(npm *),Bash(pnpm *)" \
  "<review prompt>"
```

Do not use hosted `claude ultrareview` unless the user explicitly asks and accepts the cost.

## Claude Active

Use Codex exec review:

```bash
codex exec review --uncommitted --ephemeral - <<'PROMPT'
<shared prompt with Target set to current uncommitted diff>
PROMPT
```

Variants: branch review uses `--base <base-ref>`, commit review uses `--commit <sha>`, and custom scope belongs in the prompt.

## Output

Match `review`:

```text
- findings: none
- verdict: ship it
- evidence: Claude review covered the uncommitted diff and found no material issues
- unverified: runtime smoke not rerun
- next: verify
```

If the opposite harness cannot run:

```text
- findings: none
- verdict: blocked
- evidence: Claude Code is not installed or authenticated, so no independent cross-harness review ran
- unverified: review target not inspected by the opposite harness
- next: review
```
