# OSS project page

Use this when building a project landing page on `uinaf.dev` (e.g. `/projects/healthd`, `/projects/tccutil-rs`, `/projects/react-json-logic`). One page per OSS project — describes what it is, how to install it, what it looks like in use, and links out to the repo and package registry.

These pages are product surfaces, so the universal rules from [brand-spec.md](brand-spec.md) and the web vocabulary from [components.md](components.md) apply. This file adds the four patterns that aren't covered there: the repo-style header, the section eyebrow label, the install snippet (tabs + copy), and the terminal output block.

## Scope

A project page is single-column inside the same layout shell as the rest of the site, but uses the small computer mark (`uinaf-computer.png`) instead of the team mark, and a slightly wider container (`max-w-3xl`) so install commands and terminal output fit without wrapping mid-token. Sections are separated by `<hr>` hairlines, in the same vocabulary as the home page.

Stack: header → install → optional terminal usage → optional commands or feature list → footer (handled by the layout). No nav, no sticky elements, no in-page jumps.

## Repo-style header

Pattern lifted from a GitHub repo's title strip. Project name reads as `org/name` with the org muted and the slash even fainter — the eye lands on the project name. Description is one literal sentence below; meta is a dot-separated row underneath.

```html
<header>
  <h1 class="text-xl text-balance text-neutral-200">
    <span class="text-neutral-400">uinaf</span><span class="text-neutral-700 mx-0.5">/</span>healthd
  </h1>
  <p class="text-pretty text-xs text-neutral-400 mt-2.5 mb-3 max-w-[60ch]">
    small daemon for machine health checks. designed to be invisible.
  </p>
  <div class="flex flex-wrap gap-2 text-xs text-neutral-600 tracking-wide">
    <span>macos / linux</span><span class="text-neutral-700" aria-hidden="true">·</span>
    <span>go</span><span class="text-neutral-700" aria-hidden="true">·</span>
    <span>MIT</span>
  </div>
</header>
```

Meta values are platform / language / license, in that order. Skip any that don't apply. Don't show stars or version unless they're statically baked at build time — the page is static and you don't want a dead "v0.4.0" sticking around.

## Section eyebrow

Section labels on a project page sit on top of their section, smaller and dimmer than body. They are not section h2s in the heading sense — there's only one h1 (the repo header), and the sections are demarcated by these eyebrows + hairlines, not by hierarchy.

```html
<h2 class="m-0 text-xs font-normal text-neutral-600">install</h2>
```

Lowercase, `text-xs`, neutral-600. No uppercase, no tracking — the size and color are the differentiation, in line with the brand's lowercase-on-product-surfaces rule.

## Install snippet

Package-manager picker on top, command snippet below, copy-to-clipboard affordance on the right. The picker is a row of small buttons that swap which command is shown — the only place tabs appear in the system. (See "Not in the system" in [components.md](components.md) — install pickers are the documented carve-out.)

```html
<div class="flex flex-col" data-install>
  <div class="flex w-fit overflow-hidden rounded-t-[2px] border border-b-0 border-neutral-800 bg-neutral-950" role="tablist">
    <button type="button" role="tab" aria-selected="true"
      class="cursor-pointer border-0 bg-transparent text-[11px] text-neutral-600 px-3 py-[5px] hover:text-neutral-200 aria-selected:bg-black/50 aria-selected:text-neutral-200 transition-colors"
      data-tab="0">brew</button>
    <button type="button" role="tab" aria-selected="false"
      class="cursor-pointer border-0 bg-transparent text-[11px] text-neutral-600 px-3 py-[5px] border-l border-neutral-800 hover:text-neutral-200 aria-selected:bg-black/50 aria-selected:text-neutral-200 transition-colors"
      data-tab="1">cargo</button>
  </div>
  <div class="relative min-w-0 border border-neutral-800 rounded-b-[2px] rounded-tr-[2px] bg-black/50 text-sm text-neutral-200 leading-relaxed py-2.5 pl-3.5 pr-[76px] tabular-nums">
    <button type="button"
      class="absolute top-1/2 right-2 -translate-y-1/2 cursor-pointer bg-transparent border border-neutral-800 rounded-[2px] text-neutral-600 text-[10px] px-2.5 py-[5px] tracking-wide uppercase leading-none hover:text-neutral-200 hover:border-neutral-500 active:scale-[0.97] data-copied:text-slime-green data-copied:border-slime-green transition"
      data-copy>copy</button>
    <code class="block m-0 [white-space:pre-wrap] [overflow-wrap:anywhere]" data-pane="0">
      <span class="text-slime-cyan select-none mr-2.5">$</span>brew install uinaf/tap/healthd
    </code>
    <code class="block m-0 [white-space:pre-wrap] [overflow-wrap:anywhere]" data-pane="1" hidden>
      <span class="text-slime-cyan select-none mr-2.5">$</span>cargo binstall healthd
    </code>
  </div>
</div>
```

Connecting borders are the load-bearing detail: tabs row has `border-b-0`, the snippet has all four borders, the active tab's `bg-black/50` matches the snippet's background so the active tab visually dissolves into it. Inactive tabs sit on the page background.

The `$` prompt uses `mr-2.5` (10px) instead of a literal space — keep this convention so the prompt color stays a clean span boundary. Copy strips the prompt before writing to the clipboard.

Copy button on success: swap the label to `copied` and add `data-copied` for the slime-green ring, then revert after ~1.4s. Don't animate the swap; the color shift is enough.

Long install commands wrap rather than overflow — `[white-space:pre-wrap] [overflow-wrap:anywhere]` on the pane.

```html
<script>
  document.querySelectorAll('[data-install]').forEach((root) => {
    const tabs = root.querySelectorAll('[data-tab]');
    const panes = root.querySelectorAll('[data-pane]');
    const copyBtn = root.querySelector('[data-copy]');
    let resetTimer;
    tabs.forEach((tab) => {
      tab.addEventListener('click', () => {
        const idx = tab.dataset.tab;
        tabs.forEach((t) => t.setAttribute('aria-selected', 'false'));
        tab.setAttribute('aria-selected', 'true');
        panes.forEach((p) => { p.hidden = p.dataset.pane !== idx; });
      });
    });
    copyBtn?.addEventListener('click', async () => {
      const visible = root.querySelector('[data-pane]:not([hidden])');
      const prompt = visible?.querySelector('span')?.textContent ?? '';
      const text = (visible?.textContent ?? '').replace(prompt, '').trim();
      try { await navigator.clipboard.writeText(text); copyBtn.textContent = 'copied'; copyBtn.dataset.copied = 'true'; }
      catch { copyBtn.textContent = 'failed'; }
      clearTimeout(resetTimer);
      resetTimer = setTimeout(() => { copyBtn.textContent = 'copy'; delete copyBtn.dataset.copied; }, 1400);
    });
  });
</script>
```

## Terminal output

For `usage` / `quickstart` / `status` sections that show real CLI output. Same border + background as the install snippet; this is the one place the slime palette is allowed in UI.

```html
<pre class="m-0 overflow-x-auto rounded-[2px] border border-neutral-800 bg-black/50 text-sm text-neutral-200 leading-relaxed py-3 px-3.5 tabular-nums"><span class="text-slime-cyan">$</span>healthd status
disk     <span class="text-slime-green">ok</span>
battery  <span class="text-slime-green">ok</span>
fans     <span class="text-warn">degraded</span>
network  <span class="text-slime-green">ok</span></pre>
```

Convention: `$` in `slime-cyan` for prompts, `slime-green` for `ok`, `--color-warn` (#FFD166) for `degraded`/`warn`, `--color-error` (#FF5C7C) for `error`. Output lines start at column 0; they don't try to align under the command name. Open the `<pre>` tag tight against the first character — newlines inside `<pre>` are preserved literally, so any leading whitespace from JSX/HTML indentation will show up in the rendered output.

For longer multi-line content (config samples, JSON output) where you don't have inline status spans, drop the spans and just use the wrapping `<pre>`:

```html
<pre class="m-0 overflow-x-auto rounded-[2px] border border-neutral-800 bg-black/50 text-sm text-neutral-200 leading-relaxed py-3 px-3.5 tabular-nums">[notify]
cooldown = "5m"

[[notify.backend]]
name  = "ntfy-phone"
type  = "ntfy"
topic = "replace-with-strong-random-topic"</pre>
```

## Bulleted list

For "why" sections, feature recaps, or short explanations. The system uses `-` markers, never `•`.

```html
<ul role="list" class="m-0 flex flex-col gap-1.5 list-none p-0">
  <li class="flex gap-2 text-neutral-300">
    <span class="text-neutral-600 select-none" aria-hidden="true">-</span>
    monitor local daemons and services.
  </li>
  <li class="flex gap-2 text-neutral-300">
    <span class="text-neutral-600 select-none" aria-hidden="true">-</span>
    catch machine drift (disk, network, gateway).
  </li>
</ul>
```

Items run short — single sentences, lowercase, period at the end. Keep them tight (`gap-1.5`).

## Layout assembly

```html
<main class="max-w-3xl mx-auto p-8 flex flex-col gap-6">
  <a href="/" class="u-link-plain block w-24 h-24 border border-neutral-900">
    <img src="https://cdn.uinaf.dev/images/uinaf-computer.png" alt="uinaf" class="w-full h-full object-cover">
  </a>

  <!-- repo-style header -->
  <header>…</header>

  <hr class="border-t border-neutral-800">

  <section class="flex flex-col gap-3">
    <h2 class="text-xs font-normal text-neutral-600">install</h2>
    <!-- install snippet -->
  </section>

  <hr class="border-t border-neutral-800">

  <section class="flex flex-col gap-3">
    <h2 class="text-xs font-normal text-neutral-600">usage</h2>
    <!-- terminal output -->
  </section>
</main>
```

The page's footer is the same one the rest of the site uses — see the layout shell in [components.md](components.md). On a project page the footer's `github` link points at the project repo, and an extra `npm ↗` slot appears between `github` and `x` when the project ships an npm package.

## Variants

- **Static doc page** (CLIs, daemons): header → why → install → usage / quickstart → commands / feature list. `tccutil-rs`, `healthd`.
- **Live demo page** (npm package): header → install → interactive widget. The widget itself is project-specific — there's no canonical pattern for "embed an arbitrary React component on a brand page" yet. Keep it inside a `border border-neutral-800 bg-neutral-950/40 rounded-[2px] p-4` shell so it sits in the same vocabulary as everything else.
