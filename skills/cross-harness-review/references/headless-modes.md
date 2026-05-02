# Headless Modes

Use this reference only when command choice or flags matter.

## Claude Code

- Headless entrypoint: `claude -p` or `claude --print`
- Structured output: add `--output-format json` or `--output-format stream-json`
- Fresh throwaway run: add `--no-session-persistence`
- Avoid `--bare` by default; it skips CLAUDE.md auto-discovery and other context loading
- Avoid `claude ultrareview` by default; it is hosted, can be expensive, and may not carry the local uinaf review contract unless explicitly prompted

## Codex

- General headless entrypoint: `codex exec`
- Review headless entrypoint: `codex exec review`
- Simple review alias: `codex review`
- Throwaway run: add `--ephemeral`
- Event stream: add `--json`
- Last response capture: add `-o <path>` or `--output-last-message <path>`
- Use `codex exec review -` when you need to inject the uinaf review contract or custom focus text

## OpenAI Claude Code Plugin

OpenAI's Claude Code plugin can provide `/codex:review`. It is fine for a plain native Codex review from Claude Code, but prefer `codex exec review -` when this skill needs custom prompt text or local output handling.
