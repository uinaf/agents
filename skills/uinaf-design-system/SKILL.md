---
name: uinaf-design-system
description: "Apply the uinaf brand identity to anything that ships under the uinaf name — web interfaces, blog posts, changelogs, documentation, READMEs, slides, OG / social images, email, terminal banners, app or product UI starting points. Covers voice, design tokens, components, motion, and brand assets, with a Tailwind v4 path for web work. Use when producing or restyling any uinaf-branded artefact. Skip for non-uinaf work; this is opinionated brand guidance, not a generic UI kit."
---

# uinaf design system

Apply uinaf's identity to any creative output that ships under the studio name. Web is the most-supported track, but the same voice, type, and visual rules carry across content, slides, social, email, terminal, and native surfaces.

The canonical brand spec is [references/brand-spec.md](references/brand-spec.md). Read it when changing brand canon or when the task is ambiguous; otherwise load only the matching task reference below.

## Hard rules — universal (apply to every uinaf output)

- **Berkeley Mono** is the only typeface. No serifs, no sans, no second face. Off-uinaf fallback: JetBrains Mono.
- **Lowercase voice on product and marketing surfaces.** Headings, nav, button labels, post titles, file names that show in UI, the studio name. Always on uinaf-controlled product and marketing surfaces. Documentation surfaces (`README.md`, `CHANGELOG.md`, product docs pages, `docs/*.md`, `CONTRIBUTING.md`, `SECURITY.md`, `AGENTS.md`, `CLAUDE.md`, GitHub templates) use proper-case headlines and sentence-case body; see [references/repo-docs.md](references/repo-docs.md) for repo docs.
- **No emoji.** Anywhere. Brand artwork is the only flair.
- **Voice is short, direct, dry.** No SaaS sludge ("empower", "unlock", "synergies"). Sentence fragments end with periods. This applies everywhere, including repo docs.
- **Illustrations live on pure black with no chrome.** The slime palette (lime / green / cyan / blue / purple / magenta / pink) stays *inside* artwork, terminal output, and rare data-viz — never as button fills, gradient washes, or default text.

## Hard rules — UI surfaces (web, slides, native, email HTML)

- **Square corners.** Cap radius at 6px; 2px is the norm. Status dots are the only pill.
- **No coloured CTAs.** UI is monochrome neutrals. Hierarchy comes from weight and box position, not fill color.
- **No shadows on UI.** Borders do all the elevation work.
- **No icon fonts, no SVG icon sets.** Unicode `↗ → ← ↑ ↓` and middle-dot `·` carry the iconography.
- **One link accent: cyan.** Underline is the affordance; color shifts on hover, no transform.

## Workflow

1. Confirm what you are producing — web interface, marketing/content page (blog / terms / release announcement), documentation surface (`README.md` / `CHANGELOG.md` / product docs page / `docs/*.md` / `CONTRIBUTING.md` / `SECURITY.md` / `AGENTS.md` / `CLAUDE.md`), slide deck, OG / social asset, email, terminal banner, or app / native UI starting point.
2. Read the smallest matching reference set under "Read by task". For mixed outputs (e.g. a blog post on the website), combine only the relevant references.
3. Pull fonts from `https://cdn.uinaf.dev/fonts/berkeley-mono/variable/font.css` and illustrations from `https://cdn.uinaf.dev/images/` (see [references/assets.md](references/assets.md) for filenames and when to use each). Images are hosted on the CDN only; do not duplicate them locally.
4. Write copy against [references/voice.md](references/voice.md). Voice rules apply to every surface; the lowercase rule is scoped to product and marketing surfaces only.
5. Verify against the hard rules above before declaring done. Visual rules apply only where there is a visual surface; voice rules always apply, with the casing carve-out for documentation surfaces.

## Read by task

- **Full brand spec** (canon changes or ambiguous tasks) → [references/brand-spec.md](references/brand-spec.md)
- **Voice and copy** (every surface, with casing scope) → [references/voice.md](references/voice.md)
- **Brand assets** (fonts, illustrations, CDN paths, fallbacks) → [references/assets.md](references/assets.md)
- **Web — Tailwind v4 setup, `@theme` mappings, font wiring** → [references/tailwind.md](references/tailwind.md)
- **Web — components, layout, motion** (cards, links, buttons, inputs, hr, footer, fade-up-in) → [references/components.md](references/components.md)
- **OSS project page** (project landing on `uinaf.dev`, e.g. `/projects/healthd`) → [references/oss-project-page.md](references/oss-project-page.md)
- **Product/marketing long-form and documentation casing** (blog post, terms, changelog, product docs page, release notes) → [references/content.md](references/content.md)
- **Repo collaboration docs** (`README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `AGENTS.md`, `CLAUDE.md`, GitHub templates) → [references/repo-docs.md](references/repo-docs.md)
- **Other surfaces** (slides, OG / social, email, terminal banners, native app starting points) → [references/surfaces.md](references/surfaces.md)

## Bundled files

- [assets/colors_and_type.css](assets/colors_and_type.css) — drop-in stylesheet for web (tokens, semantic vars, base element styles, `.u-link`, `.u-link-plain`, `.u-card`). Imports Berkeley Mono from `cdn.uinaf.dev`. Use as-is for plain HTML, or as the source of truth for Tailwind theme values.

## Image URLs (production)

Do not vendor brand illustrations. Link hot to `cdn.uinaf.dev` (see [references/assets.md](references/assets.md) for roles and `og` wiring):

- `https://cdn.uinaf.dev/images/uinaf-computer.png` — primary in-page / hero mark
- `https://cdn.uinaf.dev/images/uinaf-computer-favicon.png` — favicon and apple touch icon
- `https://cdn.uinaf.dev/images/uinaf-computer-og-image.png` — default product OG / Twitter image
- `https://cdn.uinaf.dev/images/uinaf-team.png` — studio / about / studio-focused share cards

## Handoffs

- Need to verify a finished artefact lives up to these rules → use `verify`
- Reviewing someone else's branded output for ship-readiness → use `review`
- Need to update brand guidance or references → use `docs`
