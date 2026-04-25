# Brand Spec

The canonical voice, visual, and iconography rulebook for uinaf. This file is the upstream source — every other reference in this skill defers to it.

## Studio context

**uinaf** ("undefined is not a function LLC") is a small independent software studio. They build practical systems: developer tools, automation, agent infrastructure, internal products, "weird useful internet machinery". Tagline: **"we bet you've seen us before."**

## The brand in one paragraph

uinaf looks like a terminal you'd actually want to live in. Near-black canvas, a single typeface (Berkeley Mono) used at every size from footer-meta to display, hairline neutral borders, no shadows, no gradients-as-decoration. Square corners. Lowercase, sentence-fragment voice. The only loud thing is the brand artwork — line-drawn skulls and melting CRTs in halftone, with neon "slime" running through them in cyan / green / magenta / purple. Those slime colors stay in the imagery. The UI itself stays monochrome.

## Content fundamentals

**Voice.** Short, direct, a little dry. Sounds like a sharp engineer who has nothing to prove. No SaaS-marketing sludge ("empower", "unlock", "synergies"). No exclamation marks. No em-dash drama. Sentence fragments are fine. Periods at the end. Wit lives in the *content*, not in punctuation or formatting.

**Casing.** **Everything lowercase on product surfaces.** Headings, nav, button labels, product names, the company name itself ("uinaf"). The only capitalised thing in body copy is the legal entity name when it has to appear ("undefined is not a function LLC"), and proper nouns inside quotes / code identifiers. URLs and code are mono-cased as written.

The lowercase rule is scoped to surfaces uinaf controls visually — `uinaf.dev`, blog, changelog, terms, OG/social, slides, email, terminal banners, in-product UI strings. It does **not** apply to repo collaboration docs (`README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `AGENTS.md`, `CLAUDE.md`, GitHub templates), which render in GitHub's chrome and use proper-case headlines with sentence-case body. See [repo-docs.md](repo-docs.md). Voice (short, direct, dry, no SaaS sludge, no emoji) still applies everywhere.

**Pronouns.** First-person plural — **"we"** — for the studio. Second-person — **"you"** — for the reader, used sparingly and in actual instructions, never in marketing-flattery ("you deserve…").

**Length.** Single sentences win. Paragraphs are 1–3 sentences. Lists use `-` bullets and run short. Long-form prose (terms, docs) is cordoned off in its own scroll container so the rest of the page stays sparse.

**No emoji. No emoji. No emoji.** Not in copy, not in nav, not in marketing. The brand's "loud" energy is delivered exclusively through the illustrations. Unicode arrows are fine and used: `↗` for external links, `→` for forward, `·` (middle dot) as a separator. Never decorative bullets like `★` or `•` outside of `-`.

**Specific examples (lifted from production):**

- Hero h1: `we bet you've seen us before`
- Body: `we build software. if it has a screen, we've probably shipped something for it.`
- Body: `terminals, browsers, phones, TVs, set-top boxes, and more.`
- Body: `ten years in, still having fun.`
- Section subheading: `open-source tools we actively build and maintain.`
- Acknowledgement subheading: `credit where it's due.`
- Terms preamble: `these terms apply when you use our services, unless we agree to something else in writing.`
- Terms bullet: `we fix bugs caused by our work.`
- Terms bullet: `we don't guarantee perfection. software has edge cases.`

**What it never sounds like:** "Empowering teams to ship faster." "AI-native automation for the modern enterprise." "Reimagining the developer workflow." If a sentence could appear on a generic SaaS landing page, rewrite it.

**Product / project copy.** Name on the left, one-line description below. The description is a literal description of what it does, not a benefit statement. e.g. `tccutil — CLI helpers for managing macOS TCC permissions.` not `tccutil — take back control of macOS privacy.`

**Footer microcopy.** Use the platform's recognizable short name with a trailing `↗` for external links: `github ↗`, `x ↗`, `npm ↗`. Lists like `projects · terms · thanks` separate with the middle dot.

## Visual foundations

**Backdrop.** A near-black page (`--neutral-950`, `rgb(10,10,10)`). On `sm+` viewports the body background can carry a *very* subtle diagonal gradient `from-neutral-950 to-neutral-900`. On the framed content area itself, the same gradient is layered. There are no full-bleed photos, no patterns, no textures behind UI. Texture lives only inside the brand illustrations.

**Type.** One typeface — **Berkeley Mono** — at every size and role. Headings are not heavier than body; differentiation comes from *size*, not weight. Bold is used sparingly. Default body is `text-sm` / 14px with `leading-relaxed` (~1.55). Page h1 is `text-xl` / 20px. Display sizes only appear in marketing or hero contexts and even then they're modest. All-mono means the visual rhythm comes from glyph alignment — keep things on a roughly 8px vertical grid.

**Color.** Monochrome neutrals do all the UI work. Neutral-200 for primary text, neutral-400 for secondary, neutral-600 for tertiary/footer, neutral-800 for borders, neutral-500 for hover-borders. **No coloured CTAs.** Links and primary actions get their hierarchy from box-position and border-treatment, not fill color. The "slime" palette (cyan / green / magenta / purple) is reserved for: brand illustrations, occasional terminal output, dashboard data-viz, and rare in-product highlights (a single `<mark>` glow, a status dot). Never as button fills, never as gradient washes.

**Links.** uinaf has **one** accent color and it lives on links. Pattern adopted from `altay.wtf` (the founder's personal site) and unified across the studio:

- Prose anchors carry a *low-contrast underline by default* (`text-decoration-color: --neutral-700`), text in `inherit`. The underline is the affordance — never rely on color alone.
- Hover swaps both color and underline-color to `--slime-cyan` (`#3FFFE6`). Nothing else animates. The link does not lift, does not bold, does not shadow.
- Wrap prose blocks in `.u-prose` to inherit the pattern, or apply `.u-link` directly. Use `.u-link-plain` for nav, footer, card titles, and any anchor that wraps a larger composite — those use opacity-fade hover and no underline. Cards that wrap an `<a>` should use `.u-link-plain` so the underline doesn't span the whole card.
- Cyan is the *only* link accent. Don't introduce per-brand link colors (the way altay.wtf colors `uinaf` amber, `klarna` pink, etc.) — that's a personal-site move; the studio voice is one accent.

**Spacing.** Generous outer padding (`p-8` / 32px on framed content), tight internal density (`gap-2` / `gap-3` / `gap-4`). Containers cap at `max-w-xl` (36rem) for prose-driven pages — the site is intentionally narrow and legible. Sections are separated by `<hr>` hairlines, not by background-color shifts.

**Backgrounds & imagery.** No stock photography, ever. The two studio illustrations (`uinaf-team.png`, `uinaf-computer.png`) are the entire image library. Style: heavy black ink line-art with halftone shading, strong B&W base, with one passage of neon "slime" gradient (cyan→green→magenta→purple) per piece. Always presented on pure black with no surrounding chrome — let them sit as monoliths. When using them in product surfaces, frame them inside a 1px `--neutral-900` border with no rounded corners, square crop. They translate up small (avatar/logo at 60–80px) and full size at the top of pages.

**Hover states.** Three patterns:
- **Cards** lift `translateY(-2px)`, border goes from `neutral-800` → `neutral-500`, background subtly warms (`bg-neutral-900/40`). The trailing `↗` arrow inside the card flips from `neutral-600` → `neutral-300`.
- **Prose links** keep their default underline; color and underline-color both shift to `--slime-cyan`. No transform.
- **Plain links / nav / card titles** drop to `opacity: 0.8`. No underline appears.
- **Logo** lifts `translateY(-2px)` and the inner image scales `1.015`.

**Press states.** Universal `transform: scale(0.97)` on `:active` for cards, links, logo. No background flash, no ripple.

**Borders.** 1px solid is the entire border vocabulary. Two colors: `--neutral-800` (default) and `--neutral-500` (hover/focus). Dashed 1px `--neutral-800` for "this is a special bounded region" (e.g. the scroll container around the terms-of-service body). Never thicker than 1px.

**Shadows.** **None on UI.** Hierarchy comes from borders and background gradients. The only allowed shadow is a faint coloured glow on a single brand-accent element (e.g. a hero callout, a status dot, a slime-colored heading) — sparingly.

**Corner radii.** Square is the default. When something needs softening it gets `rounded-sm` (2px) — that's the upper limit for UI. Status dots / pills are the only exception. **Never `rounded-lg` and above.**

**Cards.** `border: 1px solid neutral-800/90`, `bg-neutral-950/40`, `rounded-sm` (2px), `p-3`. Inside: title on the left in neutral-200, `↗` on the right in neutral-600, one-line description below in `text-xs neutral-400`. That's the pattern; reuse it for projects, thanks, "see also" lists, anything indexable.

**Layout rules.** Single column, narrow (max-w-xl). Logo always top-left in a 240×240 framed square. Footer sits below the framed content, separated by a hairline on mobile and by whitespace on desktop. Footer is always two clusters: nav links left, contact + socials right, separated by middle-dot characters. No fixed elements. No sticky nav. No floating CTAs.

**Transparency & blur.** Used only on layered surfaces — cards use `bg-neutral-950/40` over the body gradient. No backdrop-blur anywhere. The brand explicitly avoids glassmorphism.

**Image color vibe.** Cool neon over high-contrast B&W line work. Never warm, never sepia, never desaturated/grain-filtered. The illustrations should feel like they were printed in a zine and then dipped in coolant.

**Motion.**
- Easing: `cubic-bezier(0.22, 1, 0.36, 1)` (the codebase's `--ease-snappy`). Snappy decel, no bounce.
- Durations: `--duration-fast: 160ms` (hover, press), `--duration-base: 220ms` (entry).
- Entry: `fade-up-in` — opacity 0→1 + 10px Y translation. Staggered with `--stagger-step: 45ms` via a `--stagger-index` custom property on each child.
- Plays once per session — `sessionStorage` key `uinaf-entry-motion-seen` gates it. Reload doesn't re-animate; new tab does.
- Reduced motion: degrades to a plain opacity fade, all transforms removed.

## Iconography

uinaf is a low-icon brand. The codebase uses **zero icon fonts and zero SVG icons**. Where another product would put an icon, uinaf puts either a Unicode glyph or nothing at all.

**The vocabulary, in full:**

- `↗` — every external link gets one as a trailing affordance (`github ↗`, `x ↗`, `name ↗` inside a card)
- `·` (U+00B7 middle dot) — separator in footer link clusters
- `—` (em dash) — used in copy, never as decoration
- `→` `←` `↑` `↓` — directional, in dashboards/terminals (sparingly)
- Hairline `<hr>` — does the work that section dividers usually do
- The `↗` inside a card is given its own `aria-hidden="true"` and color-shifts on hover (`neutral-600` → `neutral-300`)

**No emoji.** Not in nav, not in headings, not in body, not in error messages. The brand artwork is the only place visual flair lives.

**No icon fonts, no Lucide/Heroicons.** If you find yourself reaching for one, you're probably designing for a different brand. If a real icon is unavoidable (tool dashboard, IDE-like product), default to Lucide at `1px` stroke (the closest match for the hairline aesthetic) and render it in `--neutral-400`, never coloured. Document the substitution in that product's local README.

**Logo / mark.**

uinaf has two illustrations and they serve two different jobs. Pick by what the surface is *about*:

- **Primary mark** = the melting CRT, `https://cdn.uinaf.dev/images/uinaf-computer.png`. The default studio identifier on **product surfaces** — tools, demos, internal dashboards, docs sites, slides, embedded app shells. Iconic enough to identify the studio without competing with the page's actual content. Render at 240×240 inside a 1px `border-neutral-900` square frame, no rounding, no shadow. Smaller framed sizes (60–80px) are common in tool chrome.
- **About / social mark** = the two skeleton figures at desks, `https://cdn.uinaf.dev/images/uinaf-team.png`. Use on the studio homepage (`uinaf.dev`), About pages, team listings, and any context where the studio itself is the subject. Same 1px framing rules; renders well at 240×240 as a monolithic lockup. For OG / Twitter, prefer this or a custom 1200×630 render when the *page is about the studio*; for generic product / tool share cards use `https://cdn.uinaf.dev/images/uinaf-computer-og-image.png` and match `og:image` dimensions to the file.
- **Favicon mark** = `https://cdn.uinaf.dev/images/uinaf-computer-favicon.png` (256×256 raster on the CDN). Use the same URL for `<link rel="icon">` and `<link rel="apple-touch-icon">` on every uinaf-owned property.

Neither illustration has a separate text wordmark — the lowercase `uinaf` set in Berkeley Mono can act as one when needed (social handles, command-line prompts).
- The text `uinaf` set in Berkeley Mono, lowercase, can act as a wordmark when needed (e.g. social handles `@uinafdev`, command-line prompts).
- **Never** rotate, recolor, gradient-fill, or place the logo on a non-black background.

## Caveats

- **Berkeley Mono is a commercial font.** uinaf-controlled web projects should load it from `cdn.uinaf.dev`. Anyone else using this system needs their own license from Berkeley Graphics. Ship-time substitute (rough match): JetBrains Mono.
- The studio has only two illustrations. Anything else needs to be commissioned — do not generate look-alikes with AI.
- No real product UIs were supplied — the system replicates `uinaf.dev` (the website) only. A "uinaf product dashboard" UI kit would have to be designed from scratch using these foundations; it doesn't yet exist as an artefact you can copy.
