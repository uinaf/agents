# Task: Bootstrap a uinaf-branded landing page on Tailwind v4

A junior dev started a fresh Vite + Tailwind v4 project to rebuild the public studio landing page (`uinaf.dev`). They've stubbed out a generic "hello world" page. Your job is to apply the uinaf design system end-to-end so the page lands on-brand.

## Project Location

The project files are at `/workspace/landing/`. The relevant files are:

- `package.json` — Vite + Tailwind v4 already installed
- `src/styles.css` — currently `@import "tailwindcss";` only
- `index.html` — Vite entry, body has `<div id="app"></div>`
- `src/main.ts` — empty entrypoint

## What to Produce

1. Update `src/styles.css` so it imports Berkeley Mono from `cdn.uinaf.dev` and registers the full uinaf `@theme` token block (neutrals, slime, type scale, motion, radii). Add a `@layer components` block for `.u-link`, `.u-link-plain`, and `.u-card`.
2. Update `index.html` head: page `<title>uinaf</title>`, favicon and apple-touch-icon pointing at `https://cdn.uinaf.dev/images/uinaf-computer-favicon.png`, OG meta pointing at `https://cdn.uinaf.dev/images/uinaf-team.png` (studio landing — match `og:image:width` / `height` to the file).
3. Replace the body content with a uinaf-shaped landing: framed-logo top-left (240×240 inside a 1px `border-neutral-900` square, `https://cdn.uinaf.dev/images/uinaf-team.png` filling it), tagline `we bet you've seen us before` as h1, two short paragraphs, an `<hr>` hairline, then a footer with two link clusters separated by middle dots.
4. Use only Tailwind utilities sourced from the `@theme` block plus the three `.u-*` component classes. No custom inline `<style>` blocks beyond what's in `src/styles.css`.

## Hard rules to enforce (the page fails if any are violated)

- Berkeley Mono is the only typeface
- All copy is lowercase (the legal entity name and proper nouns inside quotes are the only exceptions, and aren't expected on this page)
- Square corners — no `rounded-md` or above except status pills (none are needed here)
- No coloured CTAs, no shadows on UI, no gradients on UI surfaces
- No emoji, no icon fonts, no SVG icons. Unicode `↗` and `·` only
- No SaaS marketing sludge. Voice is short, dry, direct
- One link accent: cyan, on `:hover`, via the `.u-link` pattern

## Reference

The full brand spec lives at `skills/uinaf-design-system/references/brand-spec.md`. The Tailwind setup is at `skills/uinaf-design-system/references/tailwind.md`. The component patterns are at `skills/uinaf-design-system/references/components.md`.
