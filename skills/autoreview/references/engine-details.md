# Engine Details

This vendored skill intentionally exposes only Codex and Claude review engines.

## Models And Thinking

The helper accepts `--model` globally or per engine (`engine=model`) and `--thinking` globally or per engine (`engine=level`). Repeat either flag for multiple reviewers.

Recommended model defaults:

| Engine | Default model behavior | Source note |
|--------|---------------|-------------|
| **codex** (default) | Prefers `gpt-5.6-sol`, then `gpt-5.5` when the first model is unavailable; defaults to `high` reasoning | Local preferred review model list; `gpt-5.5` remains the public documented model |
| **claude** | Prefers `claude-fable-5`, then `claude-opus-4-8` when the first model is unavailable | Local preferred review model list; Opus 4.8 full identifier follows [Claude Code model configuration](https://code.claude.com/docs/en/model-config) |

CLI flags and environment variables override these defaults.

| Engine | Model flag | Example model IDs | Thinking flag | Accepted levels |
|--------|------------|-------------------|---------------|-----------------|
| **codex** (default) | `codex --model X exec ...` | `gpt-5.6-sol`, `gpt-5.5` | `-c model_reasoning_effort=Y` | `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max` |
| **claude** | `claude --model X` | `claude-fable-5`, `claude-opus-4-8`, `claude-sonnet-4-6`, `claude-haiku-4-5` | `--effort Y` | `low`, `medium`, `high`, `xhigh`, `max` |

## Environment Defaults

CLI flags take precedence over environment variables.

| Variable | Purpose |
|----------|---------|
| `AUTOREVIEW_MODEL` | Override the built-in default `--model` for all engines |
| `AUTOREVIEW_THINKING` | Default `--thinking` for all engines |
| `AUTOREVIEW_<ENGINE>_MODEL` | Per-engine model override, for example `AUTOREVIEW_CODEX_MODEL=gpt-5.6-sol` |
| `AUTOREVIEW_<ENGINE>_THINKING` | Per-engine thinking override |
| `AUTOREVIEW_<ENGINE>_PREFERRED_MODELS` | Comma-separated preferred list used when no explicit model override is set, for example `AUTOREVIEW_CLAUDE_PREFERRED_MODELS=claude-fable-5,claude-opus-4-8` |
| `AUTOREVIEW_CODEX_CONFIG` | Semicolon-separated safe model/response tuning overrides; capability-, command-, and path-bearing keys are refused |
| `AUTOREVIEW_CODEX_SPEED` | Codex service tier: `fast`, `flex`, or `default` |

Codex maps thinking to `model_reasoning_effort`. Claude maps thinking to `--effort`. Preferred lists apply only when no explicit `--model`, inline reviewer model, `AUTOREVIEW_MODEL`, or `AUTOREVIEW_<ENGINE>_MODEL` is set. Codex tries the next preferred model only when the Codex CLI reports the selected model is unavailable. Claude maps the remaining preferred models onto Claude Code's native model-availability mechanism.

## Review Engine Isolation

When autoreview runs inside the repository under review, external reviewer CLIs must not load project-local trust or configuration that the branch controls.

| Engine | Isolation flags | Reference |
|--------|-----------------|-----------|
| **codex** | Empty temporary workspace, named read-only permission profile, auth-only config reconstruction, `project_doc_max_bytes=0`, `trust_level="untrusted"`, and `exec --ignore-user-config --ignore-rules --skip-git-repo-check` | Codex CLI `exec --help` |
| **claude** | Empty temporary workspace, `--safe-mode --setting-sources user --strict-mcp-config --disallowedTools mcp__*`, explicit web-only tools, and disabled auto-memory (`--safe-mode` requires Claude Code `v2.1.169+`) | Claude Code [CLI reference](https://code.claude.com/docs/en/cli-reference) |

Codex `--ignore-user-config` skips config loading for the exec run. Autoreview reconstructs only the documented `cli_auth_credentials_store`, `forced_login_method`, and `forced_chatgpt_workspace_id` settings from `CODEX_HOME/config.toml`, keeping authentication and workspace restrictions usable without forwarding unrelated user configuration. The reviewer runs in an empty workspace with a named permission profile that can read that workspace but not the source repository or broader host. The validated bundle is therefore its only repository input; ignored credentials, linked-worktree metadata, and project instructions remain outside the readable boundary.

Claude `--safe-mode` disables project hooks, skills, plugins, MCP servers, and CLAUDE.md while preserving normal authentication and model selection; managed settings policy can still apply. Claude also runs outside the source repository, auto-memory is disabled, and its allowed tool inventory is limited to WebSearch plus explicitly domain-constrained WebFetch rules. Filesystem and shell tools are not exposed.

## Bundle And Process Boundaries

The helper rejects sensitive paths, binary and gitlink changes, unsafe links,
non-UTF-8 input, secret-like patch content, incomplete evidence, and review
bundles above the aggregate prompt limit before starting a reviewer. Oversized
changes must be split into coherent targets so cross-file contracts stay in one
review pass. Parallel tests run with a temporary home and a small environment
allowlist, and a source-tree fingerprint invalidates review output when the
checkout changes during the run.
