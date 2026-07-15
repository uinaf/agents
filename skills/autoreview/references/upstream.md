# Upstream

This skill tracks OpenClaw's shared agent-skills repo as its canonical upstream.

- Source: https://github.com/openclaw/agent-skills/tree/main/skills/autoreview
- Reviewed and applied upstream commit: `bd8773e`.

This repo's version keeps `uinaf/agents` packaging files such as
`.tessl-plugin/plugin.json`, `agents/openai.yaml`, and this provenance note
around the upstream skill core.
It prunes engine/platform branches Altay does not use: the local helper is
Codex + Claude Code only, with no Droid, Copilot, Pi, OpenCode, Cursor,
PowerShell harness, or PowerShell parallel-test shell.

The `bd8773e` refresh keeps the portable upstream hardening: bundle-only
reviewer workspaces, named Codex permissions, Claude tool confinement, source
mutation detection, sanitized parallel tests, binary/gitlink/link/input guards,
and the expanded secret scanner. It also keeps safe Codex model/response tuning
and service-tier controls.

OpenClaw-specific Testbox/Blacksmith credential staging, `behavior-validator`
coupling, extra review engines, the Sol-to-Terra fallback surface, and
independent multi-pass clean verdicts remain excluded. The helper refuses a
bundle above the single-pass aggregate limit because separate chunks cannot
prove cross-chunk contracts. Local preferred model lists remain
`gpt-5.6-sol,gpt-5.5` and `claude-fable-5,claude-opus-4-8`.

When borrowing future updates, start from OpenClaw's current helper and tests,
then reapply this repo's packaging, Codex + Claude boundary, model policy, and
platform pruning. Update this pin only after the adapted hardening suite passes.
