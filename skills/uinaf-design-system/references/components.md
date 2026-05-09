# Components

Web track. The whole web UI vocabulary fits on one page. For long-form content patterns see [content.md](content.md); for slides / social / email / terminal / native see [surfaces.md](surfaces.md). Anything more elaborate than what's here is probably off-brand.

All examples assume Tailwind v4 with the `@theme` block from [tailwind.md](tailwind.md) wired up. Plain-CSS equivalents use the classes from [colors_and_type.css](../assets/colors_and_type.css) (`.u-link`, `.u-link-plain`, `.u-card`, `.uinaf`, `.u-prose`, etc.).

## Layout shell

Single column, narrow, framed-logo top-left, footer below.

```html
<body class="bg-neutral-950 text-neutral-200 font-mono text-sm leading-relaxed antialiased">
  <main class="max-w-xl mx-auto p-8 flex flex-col gap-6">
    <a href="/" class="u-link-plain block w-[240px] h-[240px] border border-neutral-900">
      <img src="https://cdn.uinaf.dev/images/uinaf-team.png" alt="uinaf" class="w-full h-full object-cover">
    </a>

    <section class="flex flex-col gap-3">
      <h1 class="text-lg">we bet you've seen us before</h1>
      <p class="text-neutral-400">we build software. if it has a screen, we've probably shipped something for it.</p>
      <p class="text-neutral-400">terminals, browsers, phones, TVs, set-top boxes, and more.</p>
      <p class="text-neutral-400">ten years in, still having fun.</p>
    </section>

    <hr class="border-t border-neutral-800">

    <!-- footer -->
    <footer class="flex justify-between text-xs text-neutral-600">
      <div class="flex gap-2">
        <a href="/projects" class="u-link-plain">projects</a><span class="text-neutral-700">·</span>
        <a href="/terms" class="u-link-plain">terms</a><span class="text-neutral-700">·</span>
        <a href="/thanks" class="u-link-plain">thanks</a>
      </div>
      <div class="flex gap-2">
        <a href="mailto:dev@uinaf.dev" class="u-link-plain">dev@uinaf.dev</a><span class="text-neutral-700">·</span>
        <a href="https://github.com/uinaf" class="u-link-plain">github ↗</a><span class="text-neutral-700">·</span>
        <a href="https://x.com/uinafdev" class="u-link-plain">x ↗</a>
      </div>
    </footer>
  </main>
</body>
```

## Headings

One typeface, size does the work. Keep h1/h2 at regular weight.

| Role | Size | Class |
|---|---|---|
| Page h1 | 20px | `text-lg` |
| Section h2 | 18px | `text-md` |
| Card title h3 | 15px | `text-base` |
| Display (hero, marketing) | 40px | `text-2xl` |
| Huge marketing only | 64px | `text-3xl` |

## Prose

Wrap blocks in `.u-prose` so the link pattern picks up automatically.

```html
<div class="u-prose text-neutral-400 max-w-[56ch] leading-relaxed">
  <p>we build software. if it has a screen, we've probably shipped something for it.
  <a href="/projects">terminals</a>, <a href="/projects">browsers</a>, phones, TVs,
  set-top boxes, and more.</p>
</div>
```

## Links

| Use case | Class | Hover |
|---|---|---|
| Prose anchor | `.u-link` (or auto inside `.u-prose`) | underline + color → `--color-slime-cyan` |
| Nav, footer, card title, card wrapper | `.u-link-plain` | `opacity: 0.8`, no underline |
| External link | trailing `<span aria-hidden="true">↗</span>` | inherits the parent's hover |

Cyan is the only link accent across products, brands, and sections.

## Cards — the only container pattern

```html
<a href="/healthd" class="u-card u-link-plain">
  <div class="flex justify-between items-start gap-3">
    <span class="text-neutral-200 text-base">healthd</span>
    <span aria-hidden="true" class="text-neutral-600">↗</span>
  </div>
  <p class="text-xs text-neutral-400 mt-1">small daemon for machine health checks and reporting.</p>
</a>
```

Inside: title left, `↗` right, one-line description below. Reuse for projects, thanks, "see also" lists, anything indexable. The whole card is the link — wrap in `.u-link-plain` so the underline doesn't span the entire card.

## Buttons

UI hierarchy comes from weight, not color. Three styles:

```html
<!-- primary: white fill, near-black text -->
<button class="bg-neutral-100 text-neutral-950 border border-neutral-100 px-3.5 py-2 rounded-[2px] text-[13px] hover:opacity-85 active:scale-[0.97] transition">
  ship it
</button>

<!-- secondary: hairline border, no fill -->
<button class="bg-transparent text-neutral-200 border border-neutral-700 px-3.5 py-2 rounded-[2px] text-[13px] hover:border-neutral-500 hover:bg-neutral-900/50 active:scale-[0.97] transition">
  view source
</button>

<!-- ghost: no border, muted text -->
<button class="bg-transparent text-neutral-400 border border-transparent px-3.5 py-2 rounded-[2px] text-[13px] hover:text-neutral-200 active:scale-[0.97] transition">
  cancel
</button>
```

Button fills stay neutral. The "primary" colour is white, full stop.

## Inputs

Hairline border, focus moves to `neutral-500`, no shadow, no glow.

```html
<div class="flex flex-col gap-1.5">
  <label class="text-xs text-neutral-600 tracking-wide">email</label>
  <input
    type="email"
    placeholder="dev@uinaf.dev"
    class="bg-neutral-950/50 text-neutral-100 border border-neutral-800 px-2.5 py-2 rounded-[2px] text-[13px] outline-none focus:border-neutral-500 transition placeholder:text-neutral-600"
  >
</div>
```

Terminal-prompt input (dashed border, sigil prefix):

```html
<div class="flex items-center gap-2 border border-dashed border-neutral-800 bg-neutral-950/40 px-2.5 py-2 rounded-[2px]">
  <span class="text-neutral-400">$</span>
  <input value="bun run dev" class="flex-1 bg-transparent border-0 p-0 outline-none text-[13px] text-neutral-100">
</div>
```

## Hr

Sections are separated by hairlines, not by background-color shifts.

```html
<hr class="border-t border-neutral-800">
```

## Code

```html
<code class="bg-neutral-900 text-neutral-100 border border-neutral-800 rounded-[2px] px-1.5 py-px text-[0.95em]">
  bun run dev
</code>
```

## Status dot

The only pill-shaped element in the system.

```html
<span class="inline-flex items-center gap-2 text-xs text-neutral-400">
  <span class="w-1.5 h-1.5 rounded-full bg-slime-green"></span>
  online
</span>
```

Status colors: `--color-slime-green` (ok), `--color-warn`, `--color-error`, `--color-slime-cyan` (info).

## Logo

Default to `uinaf-computer.png` for product surfaces (tools, demos, docs, app shells). Reach for `uinaf-team.png` only when the surface is *about* the studio (homepage, About page). For meta tags, use `uinaf-computer-og-image.png` as the default product OG image and `uinaf-team.png` (or a bespoke 1200×630) when the share preview should foreground the studio.

```html
<a href="/" class="u-link-plain block w-[240px] h-[240px] border border-neutral-900 transition hover:-translate-y-0.5 active:scale-[0.97]">
  <img
    src="https://cdn.uinaf.dev/images/uinaf-computer.png"
    alt="uinaf"
    class="w-full h-full object-cover transition hover:scale-[1.015]"
  >
</a>
```

The 1px `border-neutral-900` frame is part of the lockup. Keep the mark upright, original-color, unfiltered, and on black.

## Motion — fade-up-in entry

Used once per session for the home/hero entry. Plays on first paint, gated by `sessionStorage`. Reduced motion degrades to plain opacity fade.

```css
@layer utilities {
  .motion-enter {
    opacity: 0;
    transform: translateY(10px);
    animation: fade-up-in var(--duration-base) var(--ease-snappy) forwards;
    animation-delay: calc(var(--stagger-index, 0) * 45ms);
  }
  @keyframes fade-up-in {
    to { opacity: 1; transform: translateY(0); }
  }
  @media (prefers-reduced-motion: reduce) {
    .motion-enter {
      transform: none;
      animation: fade-in var(--duration-base) var(--ease-snappy) forwards;
    }
    @keyframes fade-in { to { opacity: 1; } }
  }
}
```

```html
<main>
  <h1 class="motion-enter" style="--stagger-index: 0">we bet you've seen us before</h1>
  <p class="motion-enter" style="--stagger-index: 1">we build software. if it has a screen…</p>
  <p class="motion-enter" style="--stagger-index: 2">terminals, browsers, phones…</p>
</main>

<script>
  if (sessionStorage.getItem("uinaf-entry-motion-seen")) {
    document.querySelectorAll(".motion-enter").forEach(el => {
      el.style.animation = "none";
      el.style.opacity = "1";
      el.style.transform = "none";
    });
  } else {
    sessionStorage.setItem("uinaf-entry-motion-seen", "1");
  }
</script>
```

Reload doesn't re-animate. New tab does.

## Hover patterns at a glance

| Element | Hover |
|---|---|
| Card | `translateY(-2px)` + border `neutral-500` + bg `neutral-900/40` + inner `↗` from `neutral-600` → `neutral-300` |
| Prose link | color + decoration → `slime-cyan`. No transform. |
| Plain link / nav / card title | `opacity: 0.8`. No underline. |
| Logo | `translateY(-2px)` and inner image `scale(1.015)` |
| Button (any) | varies by style; all share `:active { transform: scale(0.97) }` |

## Not in the system

- No modals, toasts, popovers, tabs, accordions, sidebars, sticky nav, breadcrumbs.
- If a real product needs one, design it from these foundations and document the addition in that product's local README.
- One documented carve-out: install snippets on OSS project pages use a small package-manager picker (brew / curl / cargo / npm) — see [oss-project-page.md](oss-project-page.md). Don't generalize this into tabs anywhere else.
