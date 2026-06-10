# Autoreview Troubleshooting

## Long Reviews

Structured review can take up to 30 minutes while the model call is active,
especially with Codex tools or web search. Treat heartbeat lines like
`review still running: ... elapsed=... pid=...` as healthy progress. Do not kill
a review just because it has been quiet for 2-5 minutes; inspect the process only
after missing multiple expected heartbeats, after 30 minutes, or after an
obviously failed subprocess.

Pass `--stream-engine-output` when live engine text is useful. Codex and Claude
filter tool/file chatter while preserving structured validation.

## Gitcrawl Repair

If `gh`/Gitcrawl reports `database disk image is malformed`, run
`gitcrawl doctor --json` once to let the portable cache repair before retrying
review; do not bypass the shim unless repair fails and freshness requires live
GitHub.

If Gitcrawl reports a portable manifest mismatch, source/runtime DB health error,
or stale portable-store checkout, run `gitcrawl doctor --json` and inspect
`source_db_health`, `runtime_db_health`, and `portable_store_status` before
falling back to live GitHub.

## Regression Provenance

Keep roles separate: blamed code author, blamed PR author, PR merger/committer,
current PR author, and PR/date. If no blamed PR is traceable, use the blamed
commit as the provenance: commit SHA, date, and author username. Do not guess a
merger or frame missing PR metadata as a separate finding.

If the blamed PR was merged by `clawsweeper[bot]` or another automation,
identify the human trigger when practical. Check timeline/comments first; if
rate-limited, use gitcrawl/cache or public PR HTML. Look for maintainer commands
such as `@clawsweeper automerge`, `/landpr`, or labels/status comments that
armed automerge. Report `automerge triggered by @login`; if not found, say
trigger unknown.

## Security-Audit Suppression Closeout

For security-audit suppression changes, verify accepted findings remain auditable:
suppressed findings stay in structured output, active output keeps an
unsuppressible suppression notice, and aggregate findings cannot hide unrelated
active risk.

## Conscious Rejections

If rejecting a finding as intentional or not worth fixing, add a brief inline
code comment only when it explains a real invariant or ownership decision that
future reviewers should know.
