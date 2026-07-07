# Upstream

This skill tracks OpenClaw's shared agent-skills repo as its canonical upstream.

- Source: https://github.com/openclaw/agent-skills/tree/main/skills/autoreview
- Applied upstream commit: `91828ce` for bundle/credential hardening.

This repo's version keeps `uinaf/agents` packaging files such as
`.tessl-plugin/plugin.json`, `agents/openai.yaml`, and this provenance note
around the upstream skill core.
It also prunes engine/platform branches Altay does not use: the local helper is
Codex + Claude Code only, with no Droid, Copilot, Pi, OpenCode, Cursor, or
PowerShell harness wrapper. Updates from `91828ce` were ported selectively:
credential-path scanning, diff secret normalization, oversized-bundle refusal,
and truncation fail-closed behavior were kept; extra review engines were not.
When borrowing future updates, prefer copying OpenClaw's `SKILL.md` and bundled
helper scripts first, then reapply only this repo's packaging and pruning.
