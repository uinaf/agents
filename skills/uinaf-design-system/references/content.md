# Content

Long-form text outputs that ship on **product surfaces**: blog posts, changelogs, product documentation pages (e.g. `uinaf.dev/tccutil`), terms of service, release notes.

The voice rules from [voice.md](voice.md) apply: lowercase voice, sentence fragments, no emoji, no exclamation marks.

For `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `AGENTS.md`, `CLAUDE.md`, and other repo collaboration docs, use [repo-docs.md](repo-docs.md) instead. Those files render in GitHub's chrome, not on uinaf.dev, and follow proper-case headline rules.

This file documents the *structure* and *patterns* on top of the voice rules.

## Blog post

uinaf posts read like a sharp engineer wrote them in one sitting. They're short, opinionated, and skip the preamble. No "in this post we'll explore…" intros.

```md
# title in lowercase, sentence-fragment style

2026-04-25

opening goes straight into the thing. no preamble.

a body paragraph or two. sentences run short. fragments end with periods.

## subhead in lowercase if you really need one

most posts don't need subheads. if you reach for one, ask whether the post is
actually two posts.

[link in prose](https://uinaf.dev) — affordance is the underline, color is cyan
on hover only.

closing line. one sentence.
```

Front matter (Astro / MDX / similar):

```yaml
---
title: "title in lowercase"
date: "2026-04-25"
description: "one literal sentence about what the post is."
---
```

Patterns:

- Title: lowercase fragment. No emoji. Period optional.
- Date: ISO `YYYY-MM-DD`. No day-of-week. No "Apr 25, 2026".
- Body length: 200–800 words. If it's longer, split it or scope it down.
- Headings: `text-md` (18px) for h2, `text-base` (15px) for h3 if any. No h4+.
- Paragraphs: 1–3 sentences each. Empty line between.
- Code blocks: fenced, language tagged, mono everywhere already.
- Inline code: `<code>` style from [colors_and_type.css](../assets/colors_and_type.css).
- Links: prose pattern (`.u-link` or auto-inherit inside `.u-prose`).
- No author by-line on the page (the studio voice is "we", not a personal handle).

## Changelog

Plain `CHANGELOG.md` at the repo root. Date-headed, bullet body, lowercase, terse.

```md
# changelog

## 2026-04-25

- new design system skill, opinionated to uinaf brand.
- cdn now serves brand illustrations under `/images/`.
- berkeley mono moved to variable woff2.

## 2026-04-22

- gt america added to cdn (six families, all weights).

## 2026-04-15

- repo init.
```

If you version: `## v0.1.0 — 2026-04-25`. Em dash. Lowercase `v`. ISO date.

Patterns:

- No "Added / Changed / Fixed / Deprecated" categories. The bullets are short enough that grouping is overhead.
- No emoji prefixes (no 🐛 ✨ 🎉).
- Each bullet: lowercase, period at end, one short clause.
- Newest entry on top.
- Don't link to PRs in the headline. If a bullet needs evidence, append a tiny `(github ↗)` link.

## Documentation page (product surface)

Product docs that render on uinaf.dev (e.g. `uinaf.dev/tccutil`). For docs in a GitHub repo (`README.md`, `docs/*.md` consumed in-repo), use [repo-docs.md](repo-docs.md) instead.

Same shell as a blog post but with section headings, code-heavy, scannable.

```md
# tool name

one literal sentence about what it does.

## install

\`\`\`bash
brew install tool-name
\`\`\`

## usage

\`\`\`bash
tool-name --flag value
\`\`\`

paragraph that explains the gotcha.

## options

| flag | does |
| --- | --- |
| `--flag` | one literal description. |
| `--other` | another. |

## see also

- [related-thing ↗](https://example.com)
- [another-thing ↗](https://example.com)
```

Patterns:

- Section headings: lowercase, no leading verbs ("install", not "How to install").
- Tables for option matrices, not nested lists.
- Code-block density is fine; uinaf docs are read by people who came for the code.
- "See also" footer with `↗` external arrows for outbound links.

## README

`README.md` is a repo collaboration doc, not a product surface. See [repo-docs.md](repo-docs.md) for structure, headline casing, and the canonical example. The short version: project name as H1 in canonical case, Title Case section headings, sentence-case body, uinaf voice without the lowercase rule.

## Terms of service / legal

Same voice as the rest of the site. Plain prose, conversational, sentence fragments allowed, periods at the end. Cordon long-form into its own scroll container so the rest of the page stays sparse — the codebase pattern is a 1px dashed `--neutral-800` border with overflow-y scroll.

Examples lifted from production:

- `these terms apply when you use our services, unless we agree to something else in writing.`
- `we fix bugs caused by our work.`
- `we don't guarantee perfection. software has edge cases.`

If a sentence reads like it came from a template lawyer-bot, rewrite it. The brand's legal voice is the same as its product voice.

## Release notes

Release notes are a changelog entry plus 1–3 paragraphs of context for the user. Put them in the same `CHANGELOG.md` (or a `RELEASES.md` if the project distinguishes), keyed by version.

```md
## v0.2.0 — 2026-04-25

major: cli flag `--strict` is now the default. pass `--no-strict` to opt out.

- `--strict` now defaults on. previous behavior available via `--no-strict`.
- new `report` subcommand emits a one-line summary on exit.
- bumped node engine to 22.

upgrade path:

\`\`\`bash
brew upgrade tool-name
tool-name --no-strict          # to keep prior behavior
\`\`\`
```

## Cross-cutting microcopy

| Surface | Pattern |
|---|---|
| Footer nav | `projects · terms · thanks` |
| Footer contact | `dev@uinaf.dev · github ↗ · x ↗` |
| External link in prose | `[name ↗](url)` (the `↗` is part of the link text) |
| Card title | product name, lowercase, no prefix |
| Card description | one literal sentence, period at end |
| Section subhead | lowercase: `open-source tools we actively build and maintain.` |
| Hero h1 | sentence fragment, period optional, lowercase |
| 404 / error | matter-of-fact: `not here. probably never was.` not `Oops!` |
| Loading | `loading.` not `Loading…` |
| Empty state | `nothing yet.` not `No items found!` |
| Confirm / destructive | `delete` not `Delete!` — and never confirm with `Are you sure?!` energy |
