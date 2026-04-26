# Tailwind setup

Web track. For non-web outputs, see [content.md](content.md) (long-form), [surfaces.md](surfaces.md) (slides, OG, email, terminal, native), or [brand-spec.md](brand-spec.md) for the canon.

Tailwind v4 is the default. v3 fallback is documented at the bottom.

## Tailwind v4 — `@theme` block

Tailwind v4 ingests CSS custom properties as utilities. Drop this into the entry stylesheet (commonly `src/styles.css` or `app/globals.css`). It mirrors [colors_and_type.css](../assets/colors_and_type.css) one-for-one — keep that file as the source of truth and edit values there first.

```css
@import "tailwindcss";

/* Berkeley Mono — variable woff2 + italic via slnt -16 */
@import url("https://cdn.uinaf.dev/fonts/berkeley-mono/variable/font.css");

@theme {
  /* one font family — mono everywhere */
  --font-mono: "Berkeley Mono", ui-monospace, "SF Mono", "JetBrains Mono",
    Menlo, Consolas, monospace;
  --font-sans: var(--font-mono);
  --font-display: var(--font-mono);

  /* type — small, dense, mono-grid */
  --text-2xs: 11px;
  --text-xs: 12px;
  --text-sm: 14px;
  --text-base: 15px;
  --text-md: 18px;
  --text-lg: 20px;
  --text-xl: 28px;
  --text-2xl: 40px;
  --text-3xl: 64px;

  /* neutrals — Tailwind neutral-* mirrored, plus -050, -925 */
  --color-neutral-050: rgb(250, 250, 250);
  --color-neutral-100: rgb(245, 245, 245);
  --color-neutral-200: rgb(229, 229, 229);
  --color-neutral-300: rgb(212, 212, 212);
  --color-neutral-400: rgb(163, 163, 163);
  --color-neutral-500: rgb(115, 115, 115);
  --color-neutral-600: rgb(82, 82, 82);
  --color-neutral-700: rgb(64, 64, 64);
  --color-neutral-800: rgb(38, 38, 38);
  --color-neutral-850: rgb(32, 32, 32);
  --color-neutral-900: rgb(23, 23, 23);
  --color-neutral-925: rgb(16, 16, 16);
  --color-neutral-950: rgb(10, 10, 10);

  /* slime — IMAGERY ONLY. never as button fills, never as gradient washes. */
  --color-slime-lime: #d4ff3f;
  --color-slime-green: #6bffb0;
  --color-slime-cyan: #3fffe6;
  --color-slime-blue: #4b7bff;
  --color-slime-purple: #8a4bff;
  --color-slime-magenta: #e646ff;
  --color-slime-pink: #ff6bd6;

  /* status — terminals/dashboards, sparingly */
  --color-ok: #6bffb0;
  --color-warn: #ffd166;
  --color-error: #ff5c7c;
  --color-info: #3fffe6;

  /* radii — square is default, 2px is the norm, 6px is the cap */
  --radius-none: 0;
  --radius-xs: 2px;
  --radius-sm: 4px;
  --radius-md: 6px;

  /* motion */
  --ease-snappy: cubic-bezier(0.22, 1, 0.36, 1);
  --duration-fast: 160ms;
  --duration-base: 220ms;

  /* layout */
  --container-narrow: 36rem;
  --container-base: 48rem;
  --container-wide: 72rem;
}
```

## Component layer

Add the link, card, and prose patterns as `@layer components` next to the theme. These are the affordances Tailwind utilities can't express in a single class because they couple base + hover + decoration.

```css
@layer components {
  /* prose link — underline is the affordance, cyan on hover */
  .u-link,
  .u-prose a {
    @apply underline underline-offset-[3px] decoration-1;
    color: inherit;
    text-decoration-color: var(--color-neutral-700);
    transition:
      color var(--duration-fast) var(--ease-snappy),
      text-decoration-color var(--duration-fast) var(--ease-snappy);
  }
  .u-link:hover,
  .u-prose a:hover {
    color: var(--color-slime-cyan);
    text-decoration-color: var(--color-slime-cyan);
  }
  .u-link:active,
  .u-prose a:active { opacity: 0.8; }

  /* plain link — nav, footer, card titles, card wrappers */
  .u-link-plain {
    color: inherit;
    text-decoration: none;
    transition: opacity var(--duration-fast) var(--ease-snappy);
  }
  .u-link-plain:hover { opacity: 0.8; }

  /* card — the only container pattern */
  .u-card {
    @apply block border border-neutral-800/90 bg-neutral-950/40
           rounded-[2px] p-3;
    transition:
      transform var(--duration-fast) var(--ease-snappy),
      border-color var(--duration-fast) var(--ease-snappy),
      background-color var(--duration-fast) var(--ease-snappy);
  }
  .u-card:hover {
    @apply border-neutral-500;
    background: rgba(23, 23, 23, 0.40);
    transform: translate3d(0, -2px, 0);
  }
  .u-card:active { transform: scale(0.97); }
}
```

## Body shell

```html
<body class="bg-neutral-950 text-neutral-200 font-mono text-sm leading-relaxed antialiased">
  <main class="max-w-xl mx-auto p-8">
    <h1 class="text-lg">we bet you've seen us before</h1>
    <p class="text-neutral-400">we build software. if it has a screen, we've probably shipped something for it.</p>
    <hr class="border-neutral-800 my-6">
  </main>
</body>
```

`max-w-xl` (36rem) is the default for prose-driven pages. Wider surfaces (dashboards, internal tools) cap at `max-w-3xl` (48rem) or `max-w-7xl` (72rem) — pick from `--container-base` / `--container-wide`.

## Subtle body gradient

The `sm+` body gets a barely-perceptible diagonal between neutral-950 and neutral-900. Don't mistake this for decoration — it should be invisible at a glance.

```css
@media (min-width: 640px) {
  body {
    background: linear-gradient(135deg,
      var(--color-neutral-950) 0%,
      var(--color-neutral-900) 100%);
  }
}
```

## Tailwind v3 fallback

Tailwind v3 still uses `tailwind.config.js`. Mirror the same tokens via `theme.extend`:

```js
// tailwind.config.js
module.exports = {
  content: ["./src/**/*.{html,js,jsx,ts,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        mono: ['"Berkeley Mono"', "ui-monospace", '"SF Mono"', '"JetBrains Mono"', "Menlo", "Consolas", "monospace"],
      },
      fontSize: {
        "2xs": "11px",
        xs: "12px",
        sm: "14px",
        base: "15px",
        md: "18px",
        lg: "20px",
        xl: "28px",
        "2xl": "40px",
        "3xl": "64px",
      },
      colors: {
        neutral: {
          "050": "rgb(250,250,250)",
          850: "rgb(32,32,32)",
          925: "rgb(16,16,16)",
        },
        slime: {
          lime: "#d4ff3f",
          green: "#6bffb0",
          cyan: "#3fffe6",
          blue: "#4b7bff",
          purple: "#8a4bff",
          magenta: "#e646ff",
          pink: "#ff6bd6",
        },
      },
      borderRadius: { xs: "2px", sm: "4px", md: "6px" },
      transitionTimingFunction: { snappy: "cubic-bezier(0.22, 1, 0.36, 1)" },
      transitionDuration: { fast: "160ms", base: "220ms" },
      maxWidth: { narrow: "36rem" },
    },
  },
};
```

## What you DON'T configure

- No custom `boxShadow` keys. Shadows are off-brand on UI.
- No custom `gradients`. The body gradient is the only one allowed.
- No `borderWidth` extensions beyond the default 1px.
- No icon plugin (`@tailwindcss/heroicons`, `lucide-react`, etc.). Use Unicode glyphs.

## Verifying

After wiring tokens:

1. `font-mono` → renders Berkeley Mono. If it falls back to monospace, the CDN import didn't load (check the network panel for `cdn.uinaf.dev`).
2. `bg-neutral-950 text-neutral-200` → near-black canvas, off-white text.
3. `text-slime-cyan` → only appears on link `:hover`, never as a default.
4. `rounded-md` and above don't exist in the design system. If you wrote `rounded-lg` you broke the brand.
