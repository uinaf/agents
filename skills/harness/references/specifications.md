# Specifications

Spec-Driven Development concepts for when features warrant upfront specification.

## Sources

- Drew Breunig — The Rise of SDD: https://www.dbreunig.com/2026/02/06/the-rise-of-spec-driven-development.html
- Drew Breunig — The SDD Triangle: https://www.dbreunig.com/2026/03/04/the-spec-driven-development-triangle.html
- GitHub Spec Kit: https://github.com/speckit/speckit
- SDD vs TDD: https://dev.to/planu/sdd-vs-tdd-why-spec-driven-development-changes-the-game-for-ai-assisted-coding-5gba
- Anthropic sprint contracts: https://www.anthropic.com/engineering/harness-design-long-running-apps
- AWS Kiro (SDD-native IDE): https://kiro.dev

## Contents

- [When to Spec](#when-to-spec)
- [The SDD Triangle](#the-sdd-triangle)
- [The 70/30 Rule](#the-7030-rule)
- [Conformance Tests](#conformance-tests)
- [Practical Workflow](#practical-workflow)
- [Spec Drift](#spec-drift)
- [Limitations](#limitations)

## When to Spec

Not everything needs a spec. Use specs for:
- Non-trivial features with ambiguous requirements
- Features touching multiple modules or teams
- Work where acceptance criteria matter (compliance, contracts, user-facing flows)
- Tasks where "done" is hard to define without discussion

Skip specs for:
- Config changes, dependency updates, simple fixes
- Work where existing tests define the contract
- Exploratory/prototype work (vibe code first, spec later if it sticks)

## The SDD Triangle

Drew Breunig's key insight: SDD is not a one-way equation (spec → code). It's a feedback loop.

```
    Spec
   ↗ ↓  ↘
  |  Tests  |
  |    ↓    |
Decisions ← Code
```

- **Spec → Tests**: spec defines conformance tests (the mechanical "done" criteria)
- **Spec → Code**: spec defines what to build
- **Tests → Code**: tests validate the implementation
- **Code → Decisions**: implementing surfaces ambiguities, edge cases, tradeoffs
- **Decisions → Spec**: decisions flow back to update the spec
- **Spec updates → Tests**: when spec changes, tests must change too

**The key insight**: implementing code *improves* the spec. No spec is perfect upfront. The act of building surfaces ambiguities, edge cases, and architectural choices that weren't anticipated. All three nodes must stay in sync.

## The 70/30 Rule

~70% of effort should go to problem definition (spec, acceptance criteria, context), ~30% to agent execution. This ratio keeps showing up independently across sources.

**Why**: the quality ceiling of agent output is set by the quality of input specification, not model capability. A well-specified task with a mediocre model beats a vague task with a frontier model.

Practical implications:
- Invest time in spec review before starting implementation
- Have the agent ask clarifying questions about tradeoffs before coding
- Capture decisions during implementation and flow them back to the spec
- A spec that takes 2 hours to write for a 30-minute agent task is correct allocation

## Conformance Tests

The bridge between specs and code. Not unit tests — acceptance tests that verify spec compliance.

### What they look like

```yaml
# conformance/rounding.yaml
- input: 1.005
  precision: 2
  expected: 1.01
  rule: "Round half up"

- input: -1.005
  precision: 2
  expected: -1.00
  rule: "Round toward zero for negative"
```

### Characteristics

- Language-agnostic where possible (YAML/JSON inputs + expected outputs)
- Derived from spec requirements, not implementation details
- Each test maps to a specific spec section or rule
- Can be used across multiple implementations (Breunig's whenwords: one spec, many language implementations)

### As acceptance criteria

Conformance tests are the mechanical definition of "done":
- Sprint/feature not complete until all conformance tests pass
- New edge cases discovered during implementation → new conformance tests → spec update
- Anthropic's sprint contracts: generator and evaluator negotiate what "done" looks like as testable criteria before each sprint

## Practical Workflow

### New feature

1. **Write the spec**: what, why, acceptance criteria, non-goals. Keep to 1-2 pages
2. **Review and refine**: human reviews for completeness, edge cases, constraints
3. **Agent interview**: have the agent ask clarifying questions before coding
4. **Break into tasks**: agent decomposes into small, testable, reviewable chunks
5. **Implement**: agent works through tasks. Human reviews focused changes
6. **Capture decisions**: as implementation surfaces ambiguities, capture and flow back to spec
7. **Reconcile**: verify spec ↔ code ↔ tests are in sync

### Existing codebase

- Create specs for new features that reference existing architecture
- Use conformance tests derived from existing behavior as baseline
- Spec modifications go through the same review cycle as code changes

## Spec Drift

The fundamental tension: specs and code live at different cadences. Without enforcement, specs go stale immediately.

### Mitigation

- **Commit hooks** (Plumb pattern): on commit, evaluate diff against spec, surface unreviewed decisions, fail if spec is out of sync
- **Decision logging**: capture *why* decisions were made, not just *what*
- **Treat spec drift like test failure**: if the spec doesn't match the code, something is wrong
- **Periodic reconciliation**: after a burst of changes, explicitly verify spec ↔ code alignment

### The hard truth

"A skill is a suggestion. A tool needs to be a checkpoint." — Drew Breunig. Specs work best when enforcement is mechanical (hooks, CI checks), not just cultural.

## Limitations

- Creating good conformance tests is the hardest part — most successful SDD projects borrowed existing test suites
- Full SDD adds ceremony that may not be warranted for small features
- For truly novel work where you don't know what you're building, vibe code first → spec later
- Specs can become stale overhead if the team doesn't have the discipline to maintain them
- "Agentic engineering enables waterfall volume at the cadence of agile" — don't accidentally reintroduce waterfall
