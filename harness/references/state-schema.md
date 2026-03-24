# Harness State File

Location: `.harness/state.json` in project root. Commit this file.

## Schema

```json
{
  "grade": "C",
  "evaluated_at": "2026-03-24T18:00:00Z",
  "dimensions": {
    "bootable": {
      "status": "pass",
      "evidence": "npm run dev starts on port 3000, health endpoint responds",
      "gap": null
    },
    "testable": {
      "status": "partial",
      "evidence": "47 unit tests (all mocked), 2 integration tests hit /api/health",
      "gap": "No e2e tests for user flows, no Playwright setup"
    },
    "observable": {
      "status": "fail",
      "evidence": "console.log only, no structured logging",
      "gap": "No structured logs, no health endpoint with version/uptime"
    },
    "verifiable": {
      "status": "partial",
      "evidence": "Agent can curl API endpoints",
      "gap": "No screenshot capability for UI, no golden file tests for CLI output"
    }
  },
  "gaps": [
    "No Playwright setup for e2e tests",
    "No structured logging",
    "No git hooks for mechanical enforcement",
    "No CI gate for smoke tests"
  ],
  "changes": [
    {
      "date": "2026-03-24",
      "description": "Added health endpoint and smoke test",
      "grade_before": "D",
      "grade_after": "C"
    }
  ]
}
```

## Rules

- `status`: one of `pass`, `partial`, `fail`
- `evidence`: specific file, command, or config backing the status
- `gap`: what's missing (null if status is pass)
- `gaps`: ordered by impact (highest first)
- `changes`: append-only log of harness improvements
- `grade`: overall = lowest dimension grade (see `grading.md`)
- Update this file after every evaluation or change
