#!/usr/bin/env bash
# One pane that follows you to the windows you opted in, pinned full height on
# the left. tmux panes belong to a single window, so the pane is moved with
# join-pane every time the current window changes.
#
#   <prefix> A   mark / unmark the current pane as the sticky pane
#   <prefix> S   picker: tab toggles a window or a whole session, esc closes
#
# A window follows the pane when its @sticky_win is set, or its session's
# @sticky_sess is set (that also covers windows created later).
#
# Subcommands: mark | apply <window-id> | pick | list | toggle <sess> <win>
set -uo pipefail

self=${BASH_SOURCE[0]}
TAB=$'\t'

sticky_pane() {
  local p
  p=$(tmux show -gqv @sticky_pane)
  [[ -n $p ]] || return 1
  [[ $(tmux display -p -t "$p" '#{pane_id}' 2>/dev/null) == "$p" ]] && echo "$p"
}

mark() {
  local cur p
  cur=$(tmux display -p '#{pane_id}')
  p=$(sticky_pane)
  if [[ $p == "$cur" ]]; then
    tmux set -gu @sticky_pane
    tmux display 'sticky pane off'
  else
    tmux set -g @sticky_pane "$cur"
    tmux set -w @sticky_win 1
    tmux display "sticky pane: $cur"
  fi
}

apply() {
  local win=$1 p on pwin width
  p=$(sticky_pane) || { tmux set -gu @sticky_pane; return; }
  on=$(tmux display -p -t "$win" '#{||:#{@sticky_win},#{@sticky_sess}}')
  [[ $on == 1 ]] || return
  pwin=$(tmux display -p -t "$p" '#{window_id}')
  [[ $pwin == "$win" ]] && return
  width=$(tmux show -gqv @sticky_width)
  tmux join-pane -d -f -h -b -l "${width:-22%}" -s "$p" -t "$win"
}

list() {
  local s
  for s in $(tmux list-sessions -F '#{session_id}'); do
    tmux display -p -t "$s" "#{session_id}${TAB}-${TAB}#{?@sticky_sess,●,○} #{session_name}  (whole session)"
    tmux list-windows -t "$s" -F "#{session_id}${TAB}#{window_id}${TAB}  #{?@sticky_win,●,#{?@sticky_sess,◐,○}} #{session_name}:#{window_index}  #{window_name}"
  done
}

toggle() {
  local sess=$1 win=$2
  if [[ $win == - ]]; then
    if [[ $(tmux show -qv -t "$sess" @sticky_sess) == 1 ]]; then
      tmux set -u -t "$sess" @sticky_sess
    else
      tmux set -t "$sess" @sticky_sess 1
    fi
  else
    if [[ $(tmux show -wqv -t "$win" @sticky_win) == 1 ]]; then
      tmux set -wu -t "$win" @sticky_win
    else
      tmux set -w -t "$win" @sticky_win 1
    fi
  fi
}

pick() {
  local header
  if [[ -z $(sticky_pane) ]]; then
    header='no sticky pane yet, mark one with <prefix> A'
  else
    header="📌 $(tmux display -p -t "$(sticky_pane)" '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}')
tab/enter toggle  esc close   ● on  ◐ via session  ○ off"
  fi
  list |
    fzf --delimiter "$TAB" --with-nth 3 --no-sort --layout reverse \
        --header "$header" --prompt 'sticky> ' \
        --bind "tab:execute-silent('$self' toggle {1} {2})+reload('$self' list)" \
        --bind "enter:execute-silent('$self' toggle {1} {2})+reload('$self' list)" \
        >/dev/null
  apply "$(tmux display -p '#{window_id}')"
}

case ${1:-} in
  mark) mark ;;
  apply) apply "$2" ;;
  pick) pick ;;
  list) list ;;
  toggle) toggle "$2" "$3" ;;
  *) echo "usage: $self mark|apply <window-id>|pick|list|toggle <sess> <win>" >&2; exit 1 ;;
esac
