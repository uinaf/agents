# Task: Draft a uinaf-branded README and changelog for a new tool

The studio is open-sourcing a new internal CLI called `tccutil` — a small utility for managing macOS TCC (transparency, consent, control) permissions from the command line. There's no existing README and no CHANGELOG.

Your job is to write both files in uinaf voice and shape, ready to ship at the repo root.

## Output Specification

Produce the following files at the workspace root, ready to commit as-is (no placeholders left unfilled):

- `README.md`
- `CHANGELOG.md`

## Input Files

The following file represents the current state of the repository. Extract it before beginning.

=============== FILE: package.json ===============
{
  "name": "tccutil",
  "version": "0.1.0",
  "description": "manage macOS TCC permissions from the command line",
  "license": "MIT",
  "repository": "github.com/uinaf/tccutil"
}

## What `tccutil` does (factual context only — don't quote this verbatim)

- `tccutil reset <service> [bundle-id]` — reset a privacy permission for one app or all apps
- `tccutil list` — list current privacy permissions per service
- `tccutil grant <service> <bundle-id>` — grant a specific permission (requires SIP-disabled environments)
- Installs via `brew install uinaf/tap/tccutil`
- Requires macOS 13+
- MIT licensed
- Source on GitHub at `github.com/uinaf/tccutil`
- Docs page (does not yet exist): would live at `uinaf.dev/tccutil`

## Changelog seed entries (factual; you write them up in voice)

- 2026-04-25: first public release at v0.1.0. covers `reset`, `list`, `grant`. macOS 13+.
- 2026-04-22: pre-release tagged v0.0.1 internally; brew tap configured.

## What to Produce

### `README.md`

A uinaf-shaped README. Title is the project name lowercase. Tagline is one literal sentence below. A single fenced bash block near the top showing install + the smallest useful invocation. Sections for `## why`, `## docs`, `## license`. No "features" section, no marketing badges, no benefit-statement copy.

### `CHANGELOG.md`

uinaf-shaped changelog. Date-headed (`## YYYY-MM-DD` or `## v0.1.0 — 2026-04-25`), newest entry on top. Bullet body, lowercase, period at end of each bullet. No emoji prefixes, no "Added / Changed / Fixed" categories.

## Hard rules to enforce

- Both files are 100% lowercase, except code identifiers, file paths, URLs, and the literal token `MIT` in the license section
- Zero emoji
- Zero SaaS marketing language ("empower", "unlock", "synergies", "simply", "just", "essentially", "transform", "elevate", "mission")
- No exclamation marks
- Sentence fragments are fine; periods at the end
- External links carry a trailing `↗` glyph
- Installation block is a single fenced ```bash block at the top of the README
- No section called "Features", "Highlights", or "Benefits"
- README under ~25 lines of body content; CHANGELOG under ~15 lines

## Reference

Voice rules: `skills/design-system/references/voice.md`. Long-form patterns (README, changelog): `skills/design-system/references/content.md`. Canonical brand: `skills/design-system/references/brand-spec.md`.
