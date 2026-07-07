# Engine Details

This vendored skill intentionally exposes only Codex and Claude review engines.

## Models And Thinking

The helper accepts `--model` globally or per engine (`engine=model`) and `--thinking` globally or per engine (`engine=level`). Repeat either flag for multiple reviewers.

Recommended model defaults:

| Engine | Default model behavior | Source note |
|--------|---------------|-------------|
| **codex** (default) | Tries `gpt-5.6-sol`, then `gpt-5.5` when the first model is unavailable | Local preferred review model list; `gpt-5.5` remains the public documented fallback |
| **claude** | Starts with `claude-fable-5` and passes `claude-opus-4-8` as the Claude Code fallback model | Local preferred review model list; Opus 4.8 full identifier follows [Claude Code model configuration](https://code.claude.com/docs/en/model-config) |

CLI flags and environment variables override these defaults.

| Engine | Model flag | Example model IDs | Thinking flag | Accepted levels |
|--------|------------|-------------------|---------------|-----------------|
| **codex** (default) | `codex --model X exec ...` | `gpt-5.6-sol`, `gpt-5.5` | `-c model_reasoning_effort=Y` | `none`, `minimal`, `low`, `medium`, `high`, `xhigh` |
| **claude** | `claude --model X` | `claude-fable-5`, `claude-opus-4-8`, `claude-sonnet-4-6`, `claude-haiku-4-5` | `--effort Y` | `low`, `medium`, `high`, `xhigh`, `max` |

Claude also supports `--fallback-model a,b` for availability-based fallback chains ([model-config](https://code.claude.com/docs/en/model-config)). Claude docs note that auth, billing, rate-limit, request-size, and transport errors do not trigger fallback, and the changelog documents interactive-session support in `v2.1.166`.

## Environment Defaults

CLI flags take precedence over environment variables.

| Variable | Purpose |
|----------|---------|
| `AUTOREVIEW_MODEL` | Override the built-in default `--model` for all engines |
| `AUTOREVIEW_THINKING` | Default `--thinking` for all engines |
| `AUTOREVIEW_FALLBACK_MODEL` | Default Claude `--fallback-model` chain |
| `AUTOREVIEW_<ENGINE>_MODEL` | Per-engine model override, for example `AUTOREVIEW_CODEX_MODEL=gpt-5.6-sol` |
| `AUTOREVIEW_<ENGINE>_THINKING` | Per-engine thinking override |
| `AUTOREVIEW_CODEX_PREFERRED_MODELS` | Comma-separated Codex preferred list used only when no explicit Codex model override is set |
| `AUTOREVIEW_CLAUDE_PREFERRED_MODELS` | Comma-separated Claude preferred list; first entry is `--model`, remaining entries become `--fallback-model` when no explicit Claude model or fallback override is set |
| `AUTOREVIEW_CLAUDE_FALLBACK_MODEL` | Claude-only fallback chain |

Codex maps thinking to `model_reasoning_effort`. Claude maps thinking to `--effort`. Codex retries the next preferred model only when the Codex CLI reports the selected model is unavailable. Claude uses Claude Code's native `--fallback-model` chain for its remaining preferred models. Only Claude accepts explicit `--fallback-model`; global CLI/env fallback requires at least one Claude reviewer, and engine-specific fallback overrides require that reviewer to be selected. Non-Claude fallback overrides fail closed instead of being silently ignored.

## Review Engine Isolation

When autoreview runs inside the repository under review, external reviewer CLIs must not load project-local trust or configuration that the branch controls.

| Engine | Isolation flags | Reference |
|--------|-----------------|-----------|
| **codex** | Auth-only config overrides, `-c project_doc_max_bytes=0`, repo `trust_level="untrusted"`, `exec --ignore-user-config --ignore-rules`, plus read-only sandbox | Codex CLI `exec --help` |
| **claude** | `--safe-mode --setting-sources user --strict-mcp-config --disallowedTools mcp__*` plus explicit `--allowedTools` (`--safe-mode` requires Claude Code `v2.1.169+`) | Claude Code [CLI reference](https://code.claude.com/docs/en/cli-reference) |

Codex `--ignore-user-config` skips config loading for the exec run. Autoreview reconstructs only the documented `cli_auth_credentials_store`, `forced_login_method`, and `forced_chatgpt_workspace_id` settings from `CODEX_HOME/config.toml`, keeping authentication and workspace restrictions usable without forwarding unrelated user configuration. The explicit repo trust override and zero project-doc budget keep reviewed-repo `AGENTS.md` and `.codex/` trust surfaces out of the review prompt. `--ignore-rules` skips user/project execpolicy rules.

Claude `--safe-mode` disables project hooks, skills, plugins, MCP servers, and CLAUDE.md while preserving normal authentication, model selection, built-in tools, and permissions; managed settings policy can still apply. `--setting-sources user` avoids project/local settings from the reviewed checkout. `--strict-mcp-config` and `--disallowedTools mcp__*` keep MCP unavailable to the review run. `--bare` is not used here because Claude's headless docs say it skips OAuth and keychain reads.
