#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  tmux-agent.sh start <codex|claude> <session> <workdir> <prompt-file>
  tmux-agent.sh handshake <session>    # legacy, noop in non-interactive mode
  tmux-agent.sh ready <session>        # legacy, noop in non-interactive mode
  tmux-agent.sh tail <session> [lines]
  tmux-agent.sh done <session>
  tmux-agent.sh status <session>       # running / done / failed / unknown
  tmux-agent.sh steer <session> <msg>  # only works in interactive mode
  tmux-agent.sh stop <session>
  tmux-agent.sh kill <session>         # also cleans temp files
  tmux-agent.sh ls                     # shows session status
EOF
}

cmd=${1:-}
if [[ -z "$cmd" ]]; then usage; exit 1; fi

# ---------------------------------------------------------------------------
# Temp file paths — keyed by session name for uniqueness and easy cleanup.
# ---------------------------------------------------------------------------
prompt_file_for()  { echo "/tmp/tmux-agent-${1}-prompt.txt"; }
wrapper_file_for() { echo "/tmp/tmux-agent-${1}-wrapper.sh"; }
status_file_for()  { echo "/tmp/tmux-agent-${1}-status.txt"; }

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Validate session name: alphanumeric, hyphens, underscores, dots only.
# Prevents path traversal or injection via crafted session names.
validate_session() {
  local session="$1"
  if [[ ! "$session" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "invalid session name: $session (allowed: [A-Za-z0-9._-]+)" >&2
    exit 1
  fi
}

# Check that a tmux session exists; exit with message if not.
require_session() {
  local session="$1"
  if ! tmux has-session -t "$session" 2>/dev/null; then
    echo "no such tmux session: $session" >&2
    exit 1
  fi
}

# Strip ANSI escape sequences from stdin.
# Uses $'...' quoting so bash converts \x1b/\x07/etc. to real bytes before
# passing to sed — required on macOS where BSD sed doesn't interpret \xNN.
strip_ansi() {
  sed -e $'s/\x1b\\[[0-9;?]*[A-Za-z]//g' \
      -e $'s/\x1b\\][^\x07]*\x07//g' \
      -e $'s/\x1b[()][A-B012]//g' \
      -e $'s/\x1b[>=<]//g' \
      -e $'s/\x0f//g' \
      -e $'s/\x0e//g'
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

start() {
  local agent="$1" session="$2" workdir="$3" prompt_src="$4"
  validate_session "$session"
  [[ -f "$prompt_src" ]] || { echo "prompt file not found: $prompt_src" >&2; exit 1; }
  [[ -d "$workdir" ]]    || { echo "workdir not found: $workdir" >&2; exit 1; }

  local workdir_abs
  workdir_abs="$(cd "$workdir" && pwd -P)"

  # Deterministic temp paths based on session name.
  local prompt_tmp wrapper status_tmp
  prompt_tmp="$(prompt_file_for "$session")"
  wrapper="$(wrapper_file_for "$session")"
  status_tmp="$(status_file_for "$session")"

  # Write prompt verbatim with __DONE__ instruction appended.
  # Using cat + printf into a file — no shell expansion can occur.
  {
    cat "$prompt_src"
    printf '\n\nWhen finished, print exactly: __DONE__'
  } > "$prompt_tmp"

  # Clean stale status file from a previous run.
  rm -f "$status_tmp"

  # Build wrapper script.
  # Single-quoted heredoc ('WRAPPER') prevents any expansion at write time.
  # At runtime, PROMPT_FILE / STATUS_FILE / TRUST_CFG are environment
  # variables exported into the tmux session via -e flags below.
  case "$agent" in
    codex)
      cat > "$wrapper" <<'WRAPPER'
#!/usr/bin/env bash
PROMPT="$(cat "$PROMPT_FILE")"
codex -c "$TRUST_CFG" --yolo "$PROMPT"
EXIT_CODE=$?
echo "$EXIT_CODE" > "$STATUS_FILE"
echo ""
echo "Agent exited with code $EXIT_CODE. Session kept alive for inspection."
sleep 86400
WRAPPER
      ;;
    claude)
      cat > "$wrapper" <<'WRAPPER'
#!/usr/bin/env bash
PROMPT="$(cat "$PROMPT_FILE")"
claude --dangerously-skip-permissions -p "$PROMPT"
EXIT_CODE=$?
echo "$EXIT_CODE" > "$STATUS_FILE"
echo ""
echo "Agent exited with code $EXIT_CODE. Session kept alive for inspection."
sleep 86400
WRAPPER
      ;;
    *)
      echo "unknown agent: $agent (use codex|claude)" >&2
      rm -f "$prompt_tmp" "$wrapper"
      exit 1
      ;;
  esac
  chmod +x "$wrapper"

  # Kill any pre-existing session with this name.
  tmux kill-session -t "$session" 2>/dev/null || true

  # Export paths as env vars so the single-quoted wrapper can reference them.
  local trust_cfg="projects.\"${workdir_abs}\".trust_level=\"trusted\""
  tmux new-session -d -s "$session" -c "$workdir_abs" \
    -e "PROMPT_FILE=$prompt_tmp" \
    -e "STATUS_FILE=$status_tmp" \
    -e "TRUST_CFG=$trust_cfg" \
    -- bash -l "$wrapper"

  echo "started: $session (agent=$agent, workdir=$workdir_abs)"
}

# Legacy commands — noop for non-interactive (-p / --yolo) mode.
# Kept for backward compatibility with orchestrators that call them.
handshake() { echo "handshake: noop in non-interactive mode"; }
ready()     { echo "ready: noop in non-interactive mode"; }

tail_out() {
  local session="$1" lines="${2:-220}"
  require_session "$session"
  tmux capture-pane -ept "$session" -S "-$lines"
}

# Get session status: running / done / failed / unknown.
get_status() {
  local session="$1"
  local status_tmp
  status_tmp="$(status_file_for "$session")"

  # If session doesn't exist, check for leftover status file.
  if ! tmux has-session -t "$session" 2>/dev/null; then
    if [[ -f "$status_tmp" ]]; then
      local code
      code="$(cat "$status_tmp")"
      [[ "$code" == "0" ]] && echo "done" || echo "failed"
    else
      echo "unknown"
    fi
    return
  fi

  # Session exists — check if agent has exited (status file written).
  if [[ -f "$status_tmp" ]]; then
    local code
    code="$(cat "$status_tmp")"
    [[ "$code" == "0" ]] && echo "done" || echo "failed"
    return
  fi

  echo "running"
}

done_check() {
  local session="$1"
  local status_tmp
  status_tmp="$(status_file_for "$session")"

  # Check 1: status file says exit code 0.
  # Works even if session was killed after agent finished.
  if [[ -f "$status_tmp" ]] && [[ "$(cat "$status_tmp")" == "0" ]]; then
    return 0
  fi

  # Check 2: scan pane output for done markers (requires live session).
  # Matches: __DONE__ (explicit marker) or "• DONE" (Codex native, may have ANSI).
  if tmux has-session -t "$session" 2>/dev/null; then
    if tmux capture-pane -ept "$session" -S -260 | strip_ansi | rg -q '__DONE__|•\s*DONE'; then
      return 0
    fi
  fi

  return 1
}

status_cmd() {
  local session="$1"
  validate_session "$session"
  echo "$session: $(get_status "$session")"
}

# Only useful in interactive mode — agents started with -p/--yolo ignore this.
steer() {
  local session="$1"; shift
  local msg="$*"
  require_session "$session"
  tmux send-keys -t "$session" "$msg" Enter
}

stop_session() {
  local session="$1"
  require_session "$session"
  tmux send-keys -t "$session" C-c
}

kill_session() {
  local session="$1"
  validate_session "$session"
  tmux kill-session -t "$session" 2>/dev/null || true
  rm -f "$(prompt_file_for "$session")" \
        "$(wrapper_file_for "$session")" \
        "$(status_file_for "$session")"
  echo "killed: $session (temp files cleaned)"
}

ls_sessions() {
  local output
  output="$(tmux ls 2>/dev/null)" || { echo "no tmux sessions"; return; }
  [[ -z "$output" ]] && { echo "no tmux sessions"; return; }

  local line session status
  while IFS= read -r line; do
    session="${line%%:*}"
    status="$(get_status "$session")"
    echo "$line [$status]"
  done <<< "$output"
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
case "$cmd" in
  start)     [[ $# -eq 5 ]]             || { usage; exit 1; }; start "$2" "$3" "$4" "$5" ;;
  handshake) [[ $# -eq 2 ]]             || { usage; exit 1; }; handshake ;;
  ready)     [[ $# -eq 2 ]]             || { usage; exit 1; }; ready ;;
  tail)      [[ $# -ge 2 && $# -le 3 ]] || { usage; exit 1; }; tail_out "$2" "${3:-220}" ;;
  done)      [[ $# -eq 2 ]]             || { usage; exit 1; }; done_check "$2" ;;
  status)    [[ $# -eq 2 ]]             || { usage; exit 1; }; status_cmd "$2" ;;
  steer)     [[ $# -ge 3 ]]             || { usage; exit 1; }; steer "$2" "${@:3}" ;;
  stop)      [[ $# -eq 2 ]]             || { usage; exit 1; }; stop_session "$2" ;;
  kill)      [[ $# -eq 2 ]]             || { usage; exit 1; }; kill_session "$2" ;;
  ls)        ls_sessions ;;
  *)         usage; exit 1 ;;
esac
