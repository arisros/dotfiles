#!/usr/bin/env bash
# Move the current window to another session, bound to <prefix> M.
# fzf lists every other session, enter moves the window there and the client
# follows it. esc cancels.
set -uo pipefail

TAB=$'\t'
win=$(tmux display -p '#{window_id}')
cur_sess=$(tmux display -p '#{session_id}')

sessions=$(tmux list-sessions -F "#{session_id}${TAB}#{session_name}${TAB}#{session_windows} windows" | awk -F"$TAB" -v cur="$cur_sess" '$1 != cur')
[[ -n $sessions ]] || { tmux display 'no other session to move this window to'; exit 0; }

dst=$(fzf --delimiter "$TAB" --with-nth 2.. --no-sort --layout reverse \
  --prompt 'session> ' --header "move $(tmux display -p '#{window_index}:#{window_name}') where?" \
  --preview-window 'right,55%,border-left,nowrap' \
  --preview 'tmux list-windows -t {1} -F "#{window_index}: #{window_name} (#{window_panes} panes)"' \
  <<<"$sessions" | cut -f1)
[[ -n $dst ]] || exit 0

# Switch first: moving the last window away destroys the source session, which
# would detach a client still attached to it.
tmux switch-client -t "$dst"
tmux move-window -s "$win" -t "$dst:"
tmux select-window -t "$win"
