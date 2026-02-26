#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  tmux-agent.sh start <codex|claude> <session> <workdir> <prompt-file>
  tmux-agent.sh handshake <session>
  tmux-agent.sh ready <session>
  tmux-agent.sh tail <session> [lines]
  tmux-agent.sh done <session>
  tmux-agent.sh steer <session> <message>
  tmux-agent.sh stop <session>
  tmux-agent.sh kill <session>
  tmux-agent.sh ls
EOF
}

cmd=${1:-}
[[ -z "$cmd" ]] && usage && exit 1

start() {
  local agent="$1" session="$2" workdir="$3" prompt_file="$4"
  [[ -f "$prompt_file" ]] || { echo "prompt file not found: $prompt_file" >&2; exit 1; }
  [[ -d "$workdir" ]] || { echo "workdir not found: $workdir" >&2; exit 1; }

  local workdir_abs prompt shell_cmd
  workdir_abs="$(cd "$workdir" && pwd -P)"
  prompt="$(cat "$prompt_file")

When finished, print exactly: __DONE__"

  # Write prompt to temp file to avoid shell escaping issues (backticks etc.)
  local prompt_tmp
  prompt_tmp="$(mktemp /tmp/tmux-agent-prompt-XXXXXX.txt)"
  printf '%s' "$prompt" > "$prompt_tmp"

  local wrapper
  wrapper="$(mktemp /tmp/tmux-agent-run-XXXXXX.sh)"
  case "$agent" in
    codex)
      local trust_cfg
      trust_cfg="projects.\"$workdir_abs\".trust_level=\"trusted\""
      cat > "$wrapper" <<RUNEOF
#!/usr/bin/env bash
PROMPT=\$(cat "$prompt_tmp")
codex -c '$trust_cfg' --yolo "\$PROMPT"
rm -f "$prompt_tmp" "$wrapper"
echo "Agent exited. Session kept alive for inspection. Ctrl-C to close."
sleep 86400
RUNEOF
      ;;
    claude)
      cat > "$wrapper" <<RUNEOF
#!/usr/bin/env bash
PROMPT=\$(cat "$prompt_tmp")
claude --dangerously-skip-permissions -p "\$PROMPT"
rm -f "$prompt_tmp" "$wrapper"
echo "Agent exited. Session kept alive for inspection. Ctrl-C to close."
sleep 86400
RUNEOF
      ;;
    *)
      echo "unknown agent: $agent (use codex|claude)" >&2
      rm -f "$prompt_tmp" "$wrapper"
      exit 1
      ;;
  esac
  chmod +x "$wrapper"

  tmux kill-session -t "$session" 2>/dev/null || true
  tmux new-session -d -s "$session" -c "$workdir" "bash -l $wrapper"
  echo "started: $session"
}

handshake() {
  local session="$1"
  tmux send-keys -t "$session" Enter
  sleep 2
  tmux send-keys -t "$session" Enter
  sleep 2
}

ready() {
  local session="$1"
  tmux capture-pane -ept "$session" -S -120 | tee /dev/stderr | rg -q '❯|for shortcuts|esc to interrupt'
}

tail_out() {
  local session="$1" lines="${2:-220}"
  tmux capture-pane -ept "$session" -S "-$lines"
}

done_check() {
  local session="$1"
  tmux capture-pane -ept "$session" -S -260 | sed 's/\x1b\[[0-9;]*m//g' | rg -q '__DONE__|^•\s*DONE$'
}

steer() {
  local session="$1"; shift
  local msg="$*"
  tmux send-keys -t "$session" "$msg" Enter
}

case "$cmd" in
  start) [[ $# -eq 5 ]] || { usage; exit 1; }; start "$2" "$3" "$4" "$5" ;;
  handshake) [[ $# -eq 2 ]] || { usage; exit 1; }; handshake "$2" ;;
  ready) [[ $# -eq 2 ]] || { usage; exit 1; }; ready "$2" ;;
  tail) [[ $# -ge 2 && $# -le 3 ]] || { usage; exit 1; }; tail_out "$2" "${3:-220}" ;;
  done) [[ $# -eq 2 ]] || { usage; exit 1; }; done_check "$2" ;;
  steer) [[ $# -ge 3 ]] || { usage; exit 1; }; steer "$2" "${@:3}" ;;
  stop) [[ $# -eq 2 ]] || { usage; exit 1; }; tmux send-keys -t "$2" C-c ;;
  kill) [[ $# -eq 2 ]] || { usage; exit 1; }; tmux kill-session -t "$2" ;;
  ls) tmux ls ;;
  *) usage; exit 1 ;;
esac
