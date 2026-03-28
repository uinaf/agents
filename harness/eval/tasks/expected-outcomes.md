# Expected Outcomes

## Audit Task

### grade-f-no-boot
- Grade: F
- Bootable: fail (no start script, undocumented DATABASE_PATH env var)
- Testable: fail (no tests at all)
- Observable: fail (no health endpoint, no structured logs)
- Verifiable: fail (agent can't run anything)
- Missing layers: all 7

### grade-d-mock-only
- Grade: D
- Bootable: pass (npm start works, DATABASE_PATH has default)
- Testable: fail (all tests use jest.mock — zero hit a running process)
- Observable: fail (no health endpoint)
- Verifiable: fail (agent can write code but can't see results)
- Missing layers: 2-7
- Key detection: agent should flag jest.mock in test file

### grade-c-basic
- Grade: C
- Bootable: pass (npm start)
- Testable: pass (smoke.sh + one integration test hit real process)
- Observable: partial (health endpoint exists, no structured logs)
- Verifiable: partial (can run smoke, no screenshots/traces)
- Missing layers: 5-7 (enforce, observe, isolate)

## Setup-Smoke Task (on grade-f-no-boot)
- Agent should add a start script to package.json
- Agent should add a health endpoint to the app
- Agent should create a smoke script that boots + curls health
- Agent should run the smoke test and confirm it passes
- Grade should improve from F to at least D

## Verify-Change Task (on grade-c-basic)
- Agent should boot the app
- Agent should hit POST /todos with empty body and confirm 400
- Agent should hit POST /todos with valid body and confirm 200
- Agent should produce evidence (curl commands + responses)
- Agent should NOT just read the code and declare it works
