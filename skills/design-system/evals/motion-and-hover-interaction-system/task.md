# Interactive Studio Showcase Page

## Problem/Feature Description

The uinaf studio is shipping a new internal demo page — a single-page showcase that lists a handful of open-source tools the studio actively maintains. The designer has signed off on a static comp, but the front-end needs its motion layer before it can go live.

The page has two interaction systems that need to be wired up. First, an entry animation: when a visitor arrives for the first time in a browsing session, the content should animate in. Second, hover and press interactions on the cards and the logo lockup need to feel consistent and deliberate — snappy but not bouncy, with specific behaviours on the arrow glyphs inside each card.

The team is particular about the exact feel. The motion must degrade gracefully for users who have enabled reduced-motion system preferences — in that case, the transition should simplify appropriately.

The dev who will maintain this has asked for a self-contained HTML file so it's easy to inspect and demo locally without a build step.

## Output Specification

Produce a single file `showcase.html` — a self-contained HTML page with inline or embedded CSS and JavaScript. The page should include:

- A logo lockup (framed square image using `https://cdn.uinaf.dev/images/uinaf-computer.png`)
- An `<h1>` headline
- At least two project cards (each with a title, a one-line description, and a `↗` glyph)
- A footer with nav links

The full animation and interaction layer must be implemented: entry animation for page content, hover states on cards and logo, and press states. Reduced-motion support is required.

Write all CSS and JavaScript inline in the HTML file so the grader can read the implementation without a build step.
