# README Examples

Pick one primary shape. Copy the structure, not the wording.

## Choose A Shape

### Minimal product README

- [`shadcn/ui`](https://github.com/shadcn-ui/ui): short value proposition, one clear docs link, minimal contributor overhead.
- [`standard-readme`](https://github.com/RichardLitt/standard-readme) minimal example: clean baseline for install, usage, contributing, license.
- Use when deeper docs already exist and README should stay short.

### CLI README

- A strong CLI README: install first, then quickstart, then docs links. Keep human usage near the top and avoid burying the first successful command.
- [`opencode`](https://github.com/nicholasgriffintn/opencode): concise product statement, badges/language switcher, then an installation matrix near the top.
- [`SST`](https://github.com/sst/sst): short pitch, installation, framework-specific getting started links, concept links, contributing, then local development notes.
- Use when the fastest path to value is "install, run one command, confirm it works."

### Product + contributor README

- [`Zed`](https://github.com/zed-industries/zed): short product intro, installation, development entry points, contributing, licensing notes.
- [`Ghostty`](https://github.com/ghostty-org/ghostty): strong hero block, top navigation, then progressively deeper sections for download, docs, contribution, roadmap, and operational details.
- Use when one README must serve both end users and contributors without becoming a handbook.

### README with navigation and examples

- [`FastColabCopy`](https://github.com/McPizza0/FastColabCopy): table of contents, visual demo, usage examples, best-practice section.
- Use when examples or visuals materially help adoption.

## Layout Rules

- Lead with one sentence: what the project is and why it exists.
- Put the fastest successful path near the top: install, quickstart, docs, or demo.
- If install paths vary by platform or package manager, present them as a compact matrix instead of burying them in prose.
- If the project supports multiple frameworks or entry paths, group "get started" links by those paths instead of writing one long setup narrative.
- If the project is large, use a top navigation block so readers can jump to the right section fast.
- If the project has multiple language audiences, keep language selection near the top.
- Link out to deeper docs instead of duplicating them.
- Keep contributing and license sections short.
- Add examples or screenshots only when they clarify usage.

## Avoid

- Full architecture tours in `README.md`.
- Repeating content that already exists in `docs/*`.
- Long setup branches before the reader reaches first value.
- Decorative sections that do not help install, use, or navigate the project.
