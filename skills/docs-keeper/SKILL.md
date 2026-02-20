# docs-keeper

Maintain project documentation with clear human/agent separation.

## Convention

```
project/
  AGENTS.md              ← agent instructions (project-specific)
  CLAUDE.md              ← symlink → AGENTS.md
  docs/
    README.md            ← human: project overview, setup, usage
    architecture.md      ← human: high-level design, domain concepts
    *.md                 ← human: guides, ADRs, onboarding
    agents/
      plan.md            ← agent: living project plan
      assumptions.md     ← agent: tracked assumptions
      notes/             ← agent: session notes
        YYYYMMDD-HHMM-slug.md
```

### Project root

- **AGENTS.md** — project-specific agent instructions. Tech stack, commands, conventions, gotchas. Keep under 150 lines.
- **CLAUDE.md** — always a symlink to AGENTS.md. Ensure this exists: `ln -sf AGENTS.md CLAUDE.md`
- No README.md at root. It lives in `docs/`.

### Human zone (`docs/*.md`)

Written by humans, maintained by humans. Agents read these but don't edit unless explicitly asked.

- **docs/README.md** — what the project does, how to set it up, how to use it. No agent jargon. The project's public face.
- **architecture.md** — high-level design. Describe capabilities and domain concepts, not file paths (paths go stale).
- Other docs as needed: ADRs, API guides, onboarding.

### Agent zone (`docs/agents/`)

Written and maintained by agents. Committed to git. Survives context windows and agent rotations.

- **plan.md** — the living project plan. Updated as scope changes, features ship, priorities shift. Read at session start.
- **assumptions.md** — document assumptions before acting on them. Update as confirmed or invalidated.
- **notes/** — timestamped session notes:
  - Lessons learned from debugging
  - Architecture decisions and rationale
  - Failed approaches and why
  - Investigation findings (API quirks, library gotchas)

## Session Discipline

**Start:** Read `docs/agents/plan.md` and project's `CLAUDE.md` / `AGENTS.md`.

**End:** Update plan if anything changed. Write a note if you learned something worth preserving.

## Keeper Behavior

When invoked as docs-keeper (or when documentation is stale):

1. **Ensure structure** — AGENTS.md exists, CLAUDE.md is symlinked to it, `docs/agents/` exists
2. **Audit** — check all docs exist, are accurate, aren't contradicting code
3. **Fix** — update what you can (agents zone only, unless asked for human zone)
4. **Flag** — report what needs human attention
5. **Trim** — AGENTS.md should stay under 150 lines. Move overflow to `docs/`

## Rules

- One code example beats three paragraphs
- Describe capabilities, not file paths (paths go stale)
- Don't document what agents already know (language syntax, common patterns)
- Create `docs/agents/` and subdirectories if they don't exist
- Never edit human zone docs without explicit permission
