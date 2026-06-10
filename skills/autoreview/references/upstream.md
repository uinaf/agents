# Upstream

This skill tracks OpenClaw's shared agent-skills repo as its canonical upstream.

- Source: https://github.com/openclaw/agent-skills/tree/main/skills/autoreview
- Applied upstream commit: `3446a70`

This repo's version keeps `uinaf/agents` packaging files such as `tile.json`,
`agents/openai.yaml`, and this provenance note around the upstream skill core.
When borrowing future updates, prefer copying OpenClaw's `SKILL.md` and bundled
helper scripts first, then reapply only packaging metadata that belongs to this
repo.
