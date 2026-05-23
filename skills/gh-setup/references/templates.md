# Templates

Use this reference when creating or aligning GitHub-facing templates and contributor policy docs.

## Pull Request Template

Use a compact template for non-trivial repos:

```md
## Summary

## Changed

## Risks

## Verification

## Complexity
```

Guidance:

- Summary names the net change.
- Changed lists files or surfaces by intent, not a noisy commit log.
- Risks names what could regress and what reviewers should verify.
- Verification lists meaningful local, CI, preview, or live proof.
- Complexity is reduced, neutral, or increased; justify increased complexity.

Avoid long template checklists that authors learn to ignore.

## Issue Templates

Create issue templates only when they improve triage.

Useful split:

- bug report
- feature request
- support or question, only when the repo accepts that kind of issue

Security vulnerabilities should route to `SECURITY.md`, not public issues.

## Security Policy

`SECURITY.md` should be short and private-first:

- Tell reporters not to open public issues for vulnerabilities.
- Provide the private reporting route.
- State what information helps triage.
- Avoid promising response times unless the maintainer can meet them.
- Keep product- or organization-specific contact details in the owning overlay, not in this generic base skill.

## Contributor Docs

`CONTRIBUTING.md` should explain:

- setup
- validation commands
- branch and PR workflow
- release/deploy documentation pointers, when contributors need them

Keep release/deploy mechanics in deeper docs such as `docs/DISTRIBUTION.md` or deployment runbooks. Do not copy the same workflow checklist into README, CONTRIBUTING, templates, and AGENTS.

## Repository Metadata

Repository descriptions and topics should help humans route the repo quickly:

- one-sentence description
- homepage or docs URL when there is a canonical public surface
- topics that reflect language, framework, artifact type, and purpose

Do not encode private org, client, machine, or unrelated repo facts into public metadata.
