# Assets

Berkeley Mono and the two brand illustrations. That's the entire asset library.

## Berkeley Mono — fonts

uinaf-controlled web projects load Berkeley Mono from `cdn.uinaf.dev`. The CDN ships a single stylesheet that wires the variable woff2 (covers all weights) plus italic via `slnt -16`.

### Usage

```html
<link rel="stylesheet" href="https://cdn.uinaf.dev/fonts/berkeley-mono/variable/font.css">
```

```css
font-family: "Berkeley Mono", ui-monospace, "SF Mono", "JetBrains Mono",
  Menlo, Consolas, monospace;
```

Already done in [colors_and_type.css](../assets/colors_and_type.css) — drop that file in and you're wired.

### CORS / cache

The CDN serves `/fonts/*` with `Access-Control-Allow-Origin: *` and immutable cache headers. No CORS config needed on the consumer side.

### License

Berkeley Mono is a commercial typeface from [Berkeley Graphics](https://berkeleygraphics.com/typefaces/berkeley-mono/). The CDN is hosted under uinaf's license — only uinaf-owned properties may pull from it.

**Off-uinaf consumers** need their own license, or should swap to JetBrains Mono as the rough-match ship-time fallback:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap">
```

```css
font-family: "JetBrains Mono", ui-monospace, "SF Mono", Menlo, Consolas, monospace;
```

## Brand illustrations

Two illustrations exist. Don't generate or commission look-alikes; commission new originals if more are needed.

Pick by what the surface is *about*:

### `uinaf-computer.png` — primary mark (product surfaces), full source

- The melting CRT alone, 1024×1024
- Default studio identifier on **product surfaces**: tools, demos, internal dashboards, docs sites, slides, embedded app shells, README hero images
- Iconic enough to identify the studio without competing with the page's actual content
- Renders at 240×240 inside a 1px `--neutral-900` square frame for hero placement, or 60–80px in tool chrome

### `uinaf-computer-favicon.png` — favicon raster

- 256×256 downscale of the computer mark
- Use for `rel="icon"` and `rel="apple-touch-icon"` (browsers downscale; smaller bytes than the 1024×1024 full source)
- **Not** the product hero image — for chrome only

### `uinaf-computer-og-image.png` — generic Open Graph / social share

- Centered mark on a black canvas, 1024×537 — default **product** OG when you don't have a custom render yet
- Use `og:image` + `og:image:width` / `og:image:height` matching the file

### `uinaf-team.png` — about / social mark

- Two robed skeletons at a melting CRT
- Used on the **studio homepage** (`uinaf.dev`), About pages, team listings, and share images where the **studio itself** is the subject
- Renders well at 240×240 as a monolithic lockup when the studio is the focus
- Same 1px `--neutral-900` framing rules

### CDN paths (preferred for production)

```
https://cdn.uinaf.dev/images/uinaf-team.png
https://cdn.uinaf.dev/images/uinaf-computer.png
https://cdn.uinaf.dev/images/uinaf-computer-favicon.png
https://cdn.uinaf.dev/images/uinaf-computer-og-image.png
```

### Bundled paths (offline / standalone)

The skill ships local copies for offline work, slide-deck mocks, and the case where the CDN isn't reachable:

- [assets/uinaf-team.png](../assets/uinaf-team.png)
- [assets/uinaf-computer.png](../assets/uinaf-computer.png)

### Hard rules

- Never rotate, recolor, gradient-fill, or filter the illustrations.
- Always present on pure black with no surrounding chrome.
- Logo lockup is the framed 240×240 square. The 1px `--neutral-900` border is part of the mark.
- Avatar / small-icon usage: 60–80px on the same black canvas.
- Favicon usage: `uinaf-computer-favicon.png` (256×256) — the computer mark only, not the team illustration
- Default to `uinaf-computer.png` for in-page hero / logo placement. Use `uinaf-computer-og-image.png` as the generic product OG. Reach for `uinaf-team.png` when the surface is *about* the studio (homepage, About, or a studio-focused share card)

### Favicon wiring

```html
<link rel="icon" type="image/png" href="https://cdn.uinaf.dev/images/uinaf-computer-favicon.png">
<link rel="apple-touch-icon" href="https://cdn.uinaf.dev/images/uinaf-computer-favicon.png">
```

### Open Graph (generic product surface)

```html
<meta property="og:image" content="https://cdn.uinaf.dev/images/uinaf-computer-og-image.png">
<meta property="og:image:width" content="1024">
<meta property="og:image:height" content="537">
<meta property="twitter:card" content="summary_large_image">
<meta name="twitter:image" content="https://cdn.uinaf.dev/images/uinaf-computer-og-image.png">
```

For a studio- or about-focused page, a share image can still use `uinaf-team.png` or a bespoke 1200×630 render — match `og:image:width` / `height` to the actual asset.

## Wordmark

There is no separate text wordmark file. The text `uinaf` set in Berkeley Mono lowercase is the wordmark wherever the framed image is overkill (social handles, command-line prompts, embedded mentions).
