#!/usr/bin/env bash
# PostToolUse / SessionEnd hook: mirror the files Claude edits into an nvim
# pane split beside the Claude pane. One follower per Claude tmux pane.
# Disable globally with `tmux set -g @claude_follow off`, per pane with
# `tmux set -p @claude_follow off`.

input=$(cat)
[ -n "$TMUX_PANE" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v nvim >/dev/null 2>&1 || exit 0

claude_pane=$TMUX_PANE
state_dir="${TMPDIR:-/tmp}/claude-follow"
sock="$state_dir/${claude_pane#%}.sock"
mkdir -p "$state_dir"

follower_pane() {
  local id
  id=$(tmux show -pqv -t "$claude_pane" @claude_follow_pane)
  [ -n "$id" ] && tmux display -p -t "$id" '#{pane_id}' 2>/dev/null
}

event=$(jq -r '.hook_event_name // empty' <<<"$input")

if [ "$event" = "SessionEnd" ]; then
  [ "$(jq -r '.reason // empty' <<<"$input")" = "clear" ] && exit 0
  id=$(follower_pane) && tmux kill-pane -t "$id"
  rm -f "$sock"
  exit 0
fi

[ "$(tmux show -pqv -t "$claude_pane" @claude_follow)" = "off" ] && exit 0
[ "$(tmux show -gqv @claude_follow)" = "off" ] && exit 0

case $(jq -r '.tool_name // empty' <<<"$input") in
  Edit | Write | MultiEdit) file=$(jq -r '.tool_input.file_path // empty' <<<"$input") ;;
  NotebookEdit) file=$(jq -r '.tool_input.notebook_path // empty' <<<"$input") ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

needle=$(jq -r '(.tool_input.new_string // .tool_input.edits[0].new_string // "") | split("\n") | map(select(test("\\S"))) | first // ""' <<<"$input")
line=1
if [ -n "$needle" ]; then
  found=$(grep -nF -m1 -- "$needle" "$file" | cut -d: -f1)
  [ -n "$found" ] && line=$found
fi

# Parallel subagent edits race to create the pane; mkdir is the lock.
lock="$state_dir/${claude_pane#%}.lock"
for _ in $(seq 50); do mkdir "$lock" 2>/dev/null && break; sleep 0.1; done
trap 'rmdir "$lock" 2>/dev/null' EXIT

if ! follower_pane >/dev/null || [ ! -S "$sock" ]; then
  rm -f "$sock"
  cwd=$(jq -r '.cwd // empty' <<<"$input")
  id=$(tmux split-window -h -d -l 50% -t "$claude_pane" -c "${cwd:-$PWD}" -P -F '#{pane_id}' \
    nvim --listen "$sock" -c 'set autoread cursorline' -c 'autocmd FocusGained * checktime') || exit 0
  tmux set -p -t "$claude_pane" @claude_follow_pane "$id"
  tmux set -p -t "$id" @claude_follow_of "$claude_pane"
  for _ in $(seq 30); do [ -S "$sock" ] && break; sleep 0.1; done
fi

esc=${file//\'/\'\'}
nvim --server "$sock" --remote-expr \
  "execute('silent! checktime | silent! drop +$line '..fnameescape('$esc')..' | normal! zz')" >/dev/null 2>&1
exit 0
