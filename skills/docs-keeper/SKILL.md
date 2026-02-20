# docs-keeper

Maintain project documentation with clear human/agent separation.

## Convention

Every project uses `docs/` as the single documentation directory. Two zones:

```
docs/
  README.md              ← human: project overview, setup, usage
  architecture.md        ← human: high-level design, domain concepts
  *.md                   ← human: guides, ADRs, onboarding

  agent/
    plan.md              ← agent: living project plan
    assumptions.md       ← agent: tracked assumptions
    notes/               ← agent: session notes
      YYYYMMDD-HHMM-slug.md
```

### Human zone (`docs/*.md`)

Written by humans, maintained by humans. Agents read these but don't edit unless explicitly asked.

- **README.md** — what the project does, how to set it up, how to use it. No agent jargon.
- **architecture.md** — high-level design. Describe capabilities and domain concepts, not file paths (paths go stale).
- Other docs as needed: ADRs, API guides, onboarding.

### Agent zone (`docs/agent/`)

Written and maintained by agents. Committed to git. Survives context windows and agent rotations.

- **plan.md** — the living project plan. Updated as scope changes, features ship, priorities shift. Read at session start.
- **assumptions.md** — document assumptions before acting on them. Update as confirmed or invalidated.
- **notes/** — timestamped session notes:
  - Lessons learned from debugging
  - Architecture decisions and rationale
  - Failed approaches and why
  - Investigation findings (API quirks, library gotchas)

## Session Discipline

**Start:** Read `docs/agent/plan.md` and project's `CLAUDE.md` / `AGENTS.md`.

**End:** Update plan if anything changed. Write a note if you learned something worth preserving.

## Keeper Behavior

When invoked as docs-keeper (or when documentation is stale):

1. **Audit** — check all docs exist, are accurate, aren't contradicting code
2. **Fix** — update what you can (agent zone only, unless asked for human zone)
3. **Flag** — report what needs human attention
4. **Trim** — CLAUDE.md / AGENTS.md should stay under 150 lines. Move overflow to `docs/`

## Rules

- One code example beats three paragraphs
- Describe capabilities, not file paths (paths go stale)
- Don't document what agents already know (language syntax, common patterns)
- Create `docs/agent/` and subdirectories if they don't exist
- Never edit human zone docs without explicit permission
