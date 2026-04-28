# Other surfaces

Non-web outputs that still need to feel like uinaf. Voice rules from [voice.md](voice.md) and identity rules from [brand-spec.md](brand-spec.md) carry. This file translates them into surface-specific patterns.

## Slides

For decks, talks, internal presentations.

- Aspect: 16:9 (1920×1080 or 1280×720). 4:3 only when the venue forces it.
- Background: `--neutral-950` (`rgb(10,10,10)`). No gradients on slides.
- Logo: framed `uinaf-computer.png` in the top-left at ~80×80, with the 1px `--neutral-900` border. The 240×240 home-lockup size is overkill for slides. Swap to `uinaf-team.png` only when the deck is *about* the studio (intro slides at a meetup, team-presentation context).
- Page number: bottom-right, `--neutral-600`, mono small (`text-2xs` / 11px).
- Footer hairline: `border-top: 1px solid --neutral-800` separating page chrome from body.
- Body: one big idea per slide. Quote-style centered text in `text-2xl` (40px) or `text-3xl` (64px) for hero slides. Body slides use `text-xl` (28px) for the focal line and `text-md` (18px) for supporting prose.
- Transitions: cut. No fade, no slide. Keynote / Reveal users: set transition to "none".
- Animations: none, except the same `fade-up-in` from the web spec on the focal element of each slide if you must.
- Code on slides: `text-md` (18px) minimum, mono everywhere already, neutral-100 on neutral-950.

Reveal.js / similar starter:

```html
<section data-background="#0a0a0a">
  <div style="
    position:absolute; top:24px; left:32px;
    width:80px; height:80px;
    border:1px solid #171717;
  ">
    <img src="https://cdn.uinaf.dev/images/uinaf-computer.png"
         style="width:100%; height:100%; object-fit:cover;">
  </div>

  <div style="text-align:center; color:#e5e5e5;
              font: 40px 'Berkeley Mono', monospace;">
    we bet you've seen us before
  </div>

  <div style="
    position:absolute; bottom:18px; right:28px;
    color:#525252; font: 11px 'Berkeley Mono', monospace;
  ">01</div>
</section>
```

## OG / social images

- Aspect: 1200×630 for hand-built OpenGraph / Twitter `summary_large_image` assets. The CDN also ships a ready-made product image, `uinaf-computer-og-image.png` (1024×537) — use it as the default `og:image` for tools and demos; set `og:image:width` / `height` to the real dimensions. 1200×1200 for Twitter `summary` cards or square IG-style posts.
- Background: `--neutral-950`.
- Composition: centered illustration framed in a 1px `--neutral-900` square, with a single-line headline below in `text-xl` or `text-2xl`. Or, no illustration: just a centered headline with the studio mark bottom-left small.
- Mark: `uinaf-team.png` or `uinaf-computer.png` framed at ~120×120 depending on whether the card is studio-focused or product-focused, or the lowercase `uinaf` wordmark in mono `text-base`.
- Domain: bottom-right, `--neutral-600`, `text-2xs` mono.
- No corner radii. No drop shadows. No coloured backgrounds.

Render via headless Chromium / Puppeteer / Satori — the page is just an HTML doc with the body styled as below:

```html
<!doctype html>
<html><head>
  <link rel="stylesheet" href="https://cdn.uinaf.dev/fonts/berkeley-mono/variable/font.css">
  <style>
    body {
      width:1200px; height:630px; margin:0;
      background:#0a0a0a; color:#e5e5e5;
      font-family:'Berkeley Mono', monospace;
      display:flex; flex-direction:column;
      align-items:center; justify-content:center;
      gap:24px;
    }
    .frame { width:120px; height:120px; border:1px solid #171717; }
    .frame img { width:100%; height:100%; object-fit:cover; }
    h1 { font-size:40px; font-weight:400; margin:0; }
    .domain {
      position:absolute; bottom:20px; right:28px;
      color:#525252; font-size:11px;
    }
  </style>
</head><body>
  <div class="frame">
    <img src="https://cdn.uinaf.dev/images/uinaf-team.png">
  </div>
  <h1>we bet you've seen us before</h1>
  <div class="domain">uinaf.dev</div>
</body></html>
```

For per-page OG (e.g. blog post share cards), substitute the post title for the headline. Keep it lowercase, one line, fragment OK.

## Email

### Plain text (preferred)

```
hi —

short body. lowercase. fragments end with periods.

altay
uinaf — undefined is not a function LLC
dev@uinaf.dev · uinaf.dev
```

### HTML email (when forced — newsletter, transactional)

- Stick to a single column, max-width 560px.
- Mono font stack with a fallback that survives Outlook: `"Berkeley Mono", "Menlo", monospace`. Do not link to webfonts; many clients strip them.
- bg: `#0a0a0a`. body text: `#e5e5e5`. link color: inherit, with `text-decoration: underline; text-decoration-color: #404040;`.
- No images-as-text. The illustration is fine inline as `<img>` with `width="240"` and `style="display:block"`.
- No CTAs as buttons. Render call-to-action as a bracketed mono link: `[ download ↗ ]`.

### Signatures

```
altay
uinaf — undefined is not a function LLC
dev@uinaf.dev · uinaf.dev
```

No avatar image, no quote, no "sent from my phone".

## Terminal banners and CLI welcome screens

Terminal output is one of the few places the slime palette is allowed (per [brand-spec.md](brand-spec.md)). Use it for ANSI color accents — `--slime-cyan` for info, `--slime-green` for ok, `--error` for failure.

Banner pattern for a CLI bootup:

```
$ uinaf
uinaf v0.1.0 — undefined is not a function LLC.
docs:    uinaf.dev
support: dev@uinaf.dev
```

Lowercase, mono assumed (the terminal handles the type), version `vX.Y.Z` lowercase. No ASCII-art logos by default — they age fast and break on narrow terminals. If you must, render `uinaf` in a small `figlet -f mini` or hand-drawn box-drawing equivalent at most 20 cols wide.

ANSI color hints:

| Status | ANSI | Hex |
|---|---|---|
| info | `\x1b[36m` (cyan) | `#3fffe6` |
| ok | `\x1b[32m` (green) | `#6bffb0` |
| warn | `\x1b[33m` (yellow) | `#ffd166` |
| error | `\x1b[31m` (red) | `#ff5c7c` |

Reset with `\x1b[0m` after every coloured run.

## Native app starting points

The brand spec says: no production UIs were supplied. A "uinaf product dashboard" UI kit would have to be designed from scratch using these foundations — it doesn't yet exist as an artefact you can copy.

Starting points for native shells:

### iOS / SwiftUI

```swift
extension Color {
  static let uinafBg        = Color(red: 0.039, green: 0.039, blue: 0.039)  // neutral-950
  static let uinafFg        = Color(red: 0.898, green: 0.898, blue: 0.898)  // neutral-200
  static let uinafFgMuted   = Color(red: 0.639, green: 0.639, blue: 0.639)  // neutral-400
  static let uinafBorder    = Color(red: 0.149, green: 0.149, blue: 0.149)  // neutral-800
  static let uinafSlimeCyan = Color(red: 0.247, green: 1.000, blue: 0.902)  // #3fffe6
}
```

- Font: register Berkeley Mono via `CTFontManagerRegisterFontsForURL` at app launch, or fall back to `.system(.body, design: .monospaced)`.
- Corner radii: 0 or 2pt. Never above 6pt.
- Borders: 1pt hairline at `uinafBorder`. No shadows. No `.shadow(...)` modifier.
- Buttons: `.background(.uinafFg).foregroundStyle(.uinafBg)` for primary; `.overlay(RoundedRectangle(cornerRadius: 2).stroke(.uinafBorder))` for secondary.

### Android / Compose

```kotlin
val UinafBg        = Color(0xFF0A0A0A)
val UinafFg        = Color(0xFFE5E5E5)
val UinafFgMuted   = Color(0xFFA3A3A3)
val UinafBorder    = Color(0xFF262626)
val UinafSlimeCyan = Color(0xFF3FFFE6)
```

- Font: load Berkeley Mono via `FontFamily(Font(R.font.berkeley_mono_regular))`. Fallback: `FontFamily.Monospace`.
- Shapes: `RoundedCornerShape(0.dp)` or `RoundedCornerShape(2.dp)` ceiling at 6.dp.
- Elevation: `0.dp` everywhere. Use `Modifier.border(1.dp, UinafBorder)` instead.

### Electron / Tauri / web-shelled desktop

Use the web track verbatim: import [colors_and_type.css](../assets/colors_and_type.css), use the Tailwind v4 `@theme` block from [tailwind.md](tailwind.md), apply [components.md](components.md). The frame chrome (titlebar, traffic-light controls) should match the OS — don't restyle native window chrome.

### Documenting deviations

Native shells inevitably need patterns the web spec doesn't define (tab bars, navigation drawers, system dialogs, sheets, swipe gestures). When you invent one:

1. Build it on top of the foundations — mono, near-black canvas, hairline borders, no shadows, square or 2pt corners.
2. Document the addition in *that product's* local README under a `## design` section. Don't promote it to shared brand guidance until at least two products use the same pattern.
