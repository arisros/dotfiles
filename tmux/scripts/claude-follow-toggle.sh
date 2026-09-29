#!/usr/bin/env bash
# Toggle the claude-follow hook (claude/hooks/claude-follow.sh).
#   pane   <pane_id>: this Claude pane (or the Claude pane a follower belongs to)
#   global          : every pane

close_follower() {
  local id
  id=$(tmux show -pqv -t "$1" @claude_follow_pane)
  [ -n "$id" ] && tmux kill-pane -t "$id" 2>/dev/null
  tmux set -pu -t "$1" @claude_follow_pane
}

case $1 in
  pane)
    target=$(tmux show -pqv -t "$2" @claude_follow_of)
    target=${target:-$2}
    if [ "$(tmux show -pqv -t "$target" @claude_follow)" = "off" ]; then
      tmux set -pu -t "$target" @claude_follow
      tmux display 'claude follow: on (this pane)'
    else
      tmux set -p -t "$target" @claude_follow off
      close_follower "$target"
      tmux display 'claude follow: off (this pane)'
    fi
    ;;
  global)
    if [ "$(tmux show -gqv @claude_follow)" = "off" ]; then
      tmux set -gu @claude_follow
      tmux display 'claude follow: on'
    else
      tmux set -g @claude_follow off
      tmux list-panes -a -F '#{pane_id}' | while read -r p; do
        [ -n "$(tmux show -pqv -t "$p" @claude_follow_pane)" ] && close_follower "$p"
      done
      tmux display 'claude follow: off (all panes)'
    fi
    ;;
esac
