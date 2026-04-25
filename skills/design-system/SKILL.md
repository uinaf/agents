---
name: uinaf-design-system
description: "Apply the uinaf brand identity to anything that ships under the uinaf name — web interfaces, blog posts, changelogs, documentation, READMEs, slides, OG / social images, email, terminal banners, app or product UI starting points. Covers voice, design tokens, components, motion, and brand assets, with a Tailwind v4 path for web work. Use when producing or restyling any uinaf-branded artefact. Skip for non-uinaf work; this is opinionated brand guidance, not a generic UI kit."
---

# uinaf design system

Apply uinaf's identity to any creative output that ships under the studio name. Web is the most-supported track, but the same voice, type, and visual rules carry across content, slides, social, email, terminal, and native surfaces.

The canonical brand spec is [references/brand-spec.md](references/brand-spec.md). Read it before producing anything new — it is the upstream source for every other reference in this skill.

## Hard rules — universal (apply to every uinaf output)

- **Berkeley Mono** is the only typeface. No serifs, no sans, no second face. Off-uinaf fallback: JetBrains Mono.
- **Lowercase voice.** Headings, nav, button labels, post titles, changelog entries, file names that show in UI, the studio name. Always.
- **No emoji.** Anywhere. Brand artwork is the only flair.
- **Voice is short, direct, dry.** No SaaS sludge ("empower", "unlock", "synergies"). Sentence fragments end with periods.
- **Illustrations live on pure black with no chrome.** The slime palette (lime / green / cyan / blue / purple / magenta / pink) stays *inside* artwork, terminal output, and rare data-viz — never as button fills, gradient washes, or default text.

## Hard rules — UI surfaces (web, slides, native, email HTML)

- **Square corners.** Cap radius at 6px; 2px is the norm. Status dots are the only pill.
- **No coloured CTAs.** UI is monochrome neutrals. Hierarchy comes from weight and box position, not fill color.
- **No shadows on UI.** Borders do all the elevation work.
- **No icon fonts, no SVG icon sets.** Unicode `↗ → ← ↑ ↓` and middle-dot `·` carry the iconography.
- **One link accent: cyan.** Underline is the affordance; color shifts on hover, no transform.

## Workflow

1. Confirm what you are producing — web interface, long-form content (blog / changelog / docs / README / terms), slide deck, OG / social asset, email, terminal banner, or app / native UI starting point.
2. Read the matching reference under "Read by task". For mixed outputs (e.g. a blog post on the website), combine the relevant references.
3. Pull fonts from `https://cdn.uinaf.dev/fonts/berkeley-mono/variable/font.css` and illustrations from `https://cdn.uinaf.dev/images/` (see [references/assets.md](references/assets.md) for the full chart — `uinaf-computer.png`, `uinaf-computer-favicon.png`, `uinaf-computer-og-image.png`, `uinaf-team.png`). Bundled copies live under [assets/](assets/) for offline / standalone use.
4. Write copy against [references/voice.md](references/voice.md) regardless of surface. Voice is the most-violated rule and the easiest to spot.
5. Verify against the hard rules above before declaring done. Visual rules apply only where there is a visual surface; voice rules always apply.

## Read by task

- **Full brand spec** (voice, visual, iconography canon) → [references/brand-spec.md](references/brand-spec.md)
- **Voice and copy** (universal, every surface) → [references/voice.md](references/voice.md)
- **Brand assets** (fonts, illustrations, CDN paths, fallbacks) → [references/assets.md](references/assets.md)
- **Web — Tailwind v4 setup, `@theme` mappings, font wiring** → [references/tailwind.md](references/tailwind.md)
- **Web — components, layout, motion** (cards, links, buttons, inputs, hr, footer, fade-up-in) → [references/components.md](references/components.md)
- **Long-form content** (blog post, changelog, docs page, README, terms-of-service) → [references/content.md](references/content.md)
- **Other surfaces** (slides, OG / social, email, terminal banners, native app starting points) → [references/surfaces.md](references/surfaces.md)

## Bundled files

- [assets/colors_and_type.css](assets/colors_and_type.css) — drop-in stylesheet for web (tokens, semantic vars, base element styles, `.u-link`, `.u-link-plain`, `.u-card`). Imports Berkeley Mono from `cdn.uinaf.dev`. Use as-is for plain HTML, or as the source of truth for Tailwind theme values.
- [assets/uinaf-computer.png](assets/uinaf-computer.png) — primary mark for in-page / hero use on product surfaces (tools, demos, docs, slides). The default studio mark unless the surface is *about* the studio.
- [assets/uinaf-computer-favicon.png](assets/uinaf-computer-favicon.png) — favicon + apple touch icon (256×256 raster on the CDN; use the same URL for both `<link rel="icon">` and `<link rel="apple-touch-icon">`).
- [assets/uinaf-computer-og-image.png](assets/uinaf-computer-og-image.png) — default Open Graph / Twitter image for product and tool pages (1024×537; set `og:image:width` / `height` to match).
- [assets/uinaf-team.png](assets/uinaf-team.png) — about / social mark (studio homepage, About pages, studio-focused share cards). 240×240 in a 1px frame, square crop on solid black.

For production, prefer the CDN URLs over the bundled copies:

- Fonts: `https://cdn.uinaf.dev/fonts/berkeley-mono/variable/font.css`
- Images: `https://cdn.uinaf.dev/images/uinaf-team.png`, `https://cdn.uinaf.dev/images/uinaf-computer.png`, `https://cdn.uinaf.dev/images/uinaf-computer-favicon.png`, `https://cdn.uinaf.dev/images/uinaf-computer-og-image.png`

## Handoffs

- Need to verify a finished artefact lives up to these rules → use `verify`
- Reviewing someone else's branded output for ship-readiness → use `review`
- Drift in this skill's own docs → use `docs`
