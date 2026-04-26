# Blog Post and Documentation Page for healthd

## Problem/Feature Description

The studio is releasing `healthd` — a small daemon for machine health checks and reporting — as an open-source project. The tool has been running internally for two years; this is its first public release at v0.1.0.

Two pieces of content need to ship alongside the code: a blog post on the studio site announcing the release, and a product documentation page that will live at `uinaf.dev/healthd`. Both need to be written in the uinaf voice and follow the studio's content conventions.

The blog post should be concise and direct — the kind of thing a sharp engineer writes in an hour. The documentation page needs to be scannable and code-heavy; it's written for people who came for the commands, not the backstory.

## What `healthd` does (factual context — write this up, don't quote it verbatim)

- Runs as a background daemon on Linux and macOS
- Exposes machine health metrics (CPU, memory, disk, network) via a lightweight HTTP endpoint at `localhost:9090/health`
- Supports a `--strict` mode that exits non-zero when any metric exceeds configured thresholds
- CLI entry: `healthd start`, `healthd stop`, `healthd status`, `healthd report`
- Configures via `~/.healthd/config.toml` or environment variables
- MIT licensed
- Install via: `brew install uinaf/tap/healthd` (macOS), `cargo install healthd` (Linux)
- Requires macOS 13+ or Linux kernel 5.15+
- GitHub: `github.com/uinaf/healthd`

## Available flags (for the documentation page)

- `--port <n>` — Port to expose the HTTP endpoint (default: 9090)
- `--strict` — Exit non-zero if any threshold exceeded
- `--config <path>` — Path to config file (default: ~/.healthd/config.toml)
- `--interval <s>` — Check interval in seconds (default: 30)
- `--quiet` — Suppress stdout output

## What to Produce

### `blog.md`

A blog post announcing the open-source release. Include front matter with title, date (use today's date: 2026-04-26), and a one-sentence description. The post body should cover what the tool does, why the studio built it, and where to get it. Keep it tight.

### `docs.md`

A product documentation page for `healthd`. Include sections covering what it does, installation, usage examples, available flags, configuration, and links to related resources. Use the GitHub repo and docs URL `uinaf.dev/healthd` as the canonical references.

## Output Files

Write both files to the working directory:
- `blog.md`
- `docs.md`
