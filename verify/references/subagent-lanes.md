# Subagent Lanes

Use narrow review lanes. Each subagent should own one concern, gather evidence, and report only meaningful findings.

Every lane should challenge the implementation, not just confirm the requested change.

## Why subagents

Moving noisy work off the main thread prevents [context pollution and context rot](https://research.trychroma.com/context-rot). The main agent stays focused on requirements and decisions; subagents return summaries, not raw logs.

## References

- [Anthropic's PR Review Toolkit](https://github.com/anthropics/claude-code/tree/main/plugins/pr-review-toolkit/agents) — agent-per-concern implementation
- [OpenAI Codex Subagents](https://developers.openai.com/codex/concepts/subagents) — concepts and model selection guidance

## Choosing lanes

Pick the smallest set of independent lanes that can challenge the change from different angles.

- UI change: usually `ui-surface` plus `tests` or `maintainability`; add `types-and-contracts` if data shape or state rules changed.
- API or backend behavior change: usually `api-surface` plus `tests`; add `silent-failures` or `external-contracts` when integrations or fallbacks are involved.
- State, migration, or config change: usually `state-and-config` plus `tests`; add `types-and-contracts` when invariants changed.
- If the risk is broader than the request, verify broadly anyway.

## Review Lanes

### `security`
Auth, secrets, injection, access control, unsafe input handling.
- Check for hardcoded credentials, leaked tokens, or secrets in config.
- Review auth flows for bypass or privilege escalation paths.
- Look for unsanitized user input reaching SQL, shell, eval, or template engines.
- Verify access control is enforced at the right layer (not just UI).

### `tests`
Missing behavioral coverage, weak edge-case coverage, brittle tests.
- Focus on behavioral coverage, not line coverage.
- Check nearby behavior and likely regressions, not just the named happy path.
- Identify untested error handling paths that could cause silent failures.
- Look for missing edge cases at boundary conditions (empty, null, max, concurrent).
- Flag tests that test implementation details instead of behavior.
- Check that new code paths have at least one test proving they work.

### `silent-failures`
Swallowed errors, broad catches, hidden fallbacks, poor user feedback.
- Zero tolerance for catch blocks that swallow errors without logging or surfacing.
- Every fallback must be explicit and justified — falling back silently hides bugs.
- Probe degraded states and adjacent failure paths.
- Verify error messages are actionable: what went wrong, what can the user do.
- Check for empty catch blocks, `catch (e) {}`, or catches that only log at debug level.
- Look for optional chaining chains that silently return undefined through important paths.

### `types-and-contracts`
Type design, invariants, API contracts, schema drift.
- Evaluate encapsulation: can invalid states be constructed?
- Check that invariants are enforced at construction, not scattered across callers.
- Check whether the new shape makes misuse easier.
- Look for stringly-typed fields that should be enums or branded types.
- Verify API contracts (request/response shapes) match docs and real usage.
- Flag types with many optional fields that hide required-in-practice constraints.

### `maintainability`
Unnecessary complexity, duplication, awkward abstractions, simplification opportunities.
- Where does understanding one concept require bouncing between many small files?
- Where have pure functions been extracted just for testability but the real bugs hide in how they're called?
- Where do tightly coupled modules create integration risk at their seams?
- Check for collateral complexity introduced by the fix.
- Look for code that could be simplified while preserving all functionality.
- Flag inaccurate comments, misleading docs, and comment rot.

## Sanity-Check Lanes

These are run-it-and-prove-it lanes. Each one should execute commands and capture evidence, not just read code.

### `ui-surface`
Browser flow, DOM state, screenshots, navigation, regressions.
- Navigate the real UI flow end to end with browser automation or CDP.
- Capture screenshots at each step as proof.
- Check structure and legibility: hierarchy, spacing, alignment, overflow, contrast, typography, and whether the primary action is obvious.
- Verify responsive behavior on the relevant viewport(s), not just the default desktop screenshot.
- Check for console errors, broken links, missing assets.
- If the surface looks weak, do not stop at evidence collection. Route the finding back into implementation, then re-run the flow and capture fresh proof.

### `api-surface`
Endpoints, status codes, payloads, error shapes.
- Hit real local endpoints with representative requests.
- Verify status codes, response shapes, and error responses match expectations.
- Exercise one or two adjacent/error cases likely to regress.
- Check auth and unauthenticated paths both work correctly.

### `state-and-config`
Persistence round trips, config boot, migrations, environment assumptions.
- Write data, restart, read it back.
- Boot with the new config and confirm the app starts cleanly.
- Check both fresh-state and existing-state behavior when relevant.
- Verify migrations run without errors on a fresh and existing state.

### `external-contracts`
Third-party APIs, enum values, response shapes, integration assumptions.
- Compare actual API responses against expected shapes in code.
- Watch for optional fields, missing fields, and version drift.
- If you cannot hit the real API, surface the gap explicitly.

## Model and reasoning effort

Match model weight to the lane's complexity:

- **High reasoning** (complex logic, edge cases, ambiguity): security, types-and-contracts.
- **Medium reasoning** (balanced default): tests, maintainability, silent-failures.
- **Low reasoning** (speed over depth): ui-surface, api-surface, state-and-config scans.

Use faster/lighter models for read-heavy exploration lanes. Use stronger models for the main agent and any lane requiring judgment.

## Main Agent Role

- Spawn subagents only when lanes are independent.
- Spawn them when a single pass would miss broader product or regression risk.
- Wait for all subagents before concluding.
- Merge their findings into one prioritized result.
- Filter aggressively. Prefer a few high-confidence issues over many weak ones.

## Avoid

- One vague "review everything" subagent.
- Parallel writes to the same files.
- Splits where one lane depends on another lane's output.
- Spawning subagents without explicit user request or clear justification.
