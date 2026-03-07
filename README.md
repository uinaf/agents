# skills

Shared agent skill library.

| Skill | Scope | Description |
|-------|-------|-------------|
| **papyrus-maximus** | universal | Project docs that stay alive. Specs, architecture diagrams, execution plans. |
| **sanity-check** | universal | Post-implementation reality check. Run after tests pass, before declaring done. |
| **sdlc-ded** | openclaw | Coding workflow — delegates to coding agents, reviews, auto-merges. |
| **definitely-not-bird** | openclaw | X/Twitter CLI for reading, searching, etc. |

## Install

```bash
# universal (works with any agent)
npx skills add uinaf/skills -g -s papyrus-maximus

# openclaw-only (symlink into ~/.openclaw/skills/)
ln -sfn /path/to/skills/openclaw/sdlc-ded ~/.openclaw/skills/sdlc-ded
```
