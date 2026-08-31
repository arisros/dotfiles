#!/usr/bin/env bash
# Scroll a full-screen app (claude, nvim, less, ...) from the keyboard.
#
# Such an app draws on the alternate screen, so tmux has no scrollback for it
# and copy-mode is stuck on the current frame. The app does its own scrolling
# though, when the terminal reports a wheel event - so that is exactly what we
# send it. Used by the `scroll` key table in tmux.conf.
#
# Usage: pane-scroll.sh <up|down|top|bottom> [count] [target-pane]
set -uo pipefail

action=${1:-up}
count=${2:-3}
target=${3:-}

read -r pane w h < <(tmux display-message ${target:+-t "$target"} -p '#{pane_id} #{pane_width} #{pane_height}')
[ -n "${pane:-}" ] || exit 0

# a wheel event carries coordinates; the middle of the pane is always inside it
col=$((w / 2)); ((col < 1)) && col=1
row=$((h / 2)); ((row < 1)) && row=1

wheel() { # button repeat  (64 = up, 65 = down, SGR mouse encoding)
  local seq i
  seq=$(printf '\033[<%d;%d;%dM' "$1" "$col" "$row")
  for ((i = 0; i < $2; i++)); do tmux send-keys -t "$pane" -l "$seq"; done
}

page() { # key repeat
  local i
  for ((i = 0; i < $2; i++)); do tmux send-keys -t "$pane" "$1"; done
}

case "$action" in
  up)     wheel 64 "$count" ;;
  down)   wheel 65 "$count" ;;
  top)    page PageUp 40 ;;     # far enough to hit the top of any transcript
  bottom) page PageDown 40 ;;   # back to the live view
  *)      exit 1 ;;
esac
