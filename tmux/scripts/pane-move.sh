#!/usr/bin/env bash
# Move a pane in three fzf steps, bound to <prefix> P:
#   1. which pane         (the current one is on top, enter takes it)
#   2. where to           (a new window in any session, or any existing window)
#   3. which side         one key: hjkl = edge of the whole window,
#                         HJKL = beside its active pane
# esc at any step cancels. Afterwards the client follows the pane.
set -uo pipefail

TAB=$'\t'
FZF=(fzf --delimiter "$TAB" --with-nth 2.. --no-sort --layout reverse --preview-window 'right,55%,border-left,nowrap')
preview_pane='tmux capture-pane -ep -t {1} | tail -n "$FZF_PREVIEW_LINES"'

cur_pane=$(tmux display -p '#{pane_id}')
cur_sess=$(tmux display -p '#{session_id}')

list_panes() {
  tmux list-panes -a -F "#{pane_id}${TAB}#{?#{==:#{pane_id},${cur_pane}},>, } #{session_name}:#{window_index}.#{pane_index}${TAB}#{window_name}${TAB}#{pane_current_command}${TAB}#{b:pane_current_path}" |
    awk -F"$TAB" -v cur="$cur_pane" '$1 == cur { print; next } { rest = rest $0 "\n" } END { printf "%s", rest }'
}

list_targets() {
  local src_win=$1
  tmux display -p -t "$cur_sess" "new:#{session_id}${TAB}+ new window in #{session_name}"
  tmux list-sessions -F "new:#{session_id}${TAB}+ new window in #{session_name}" | awk -F"$TAB" -v cur="new:$cur_sess" '$1 != cur'
  tmux list-windows -a -F "#{window_id}${TAB}  #{session_name}:#{window_index}${TAB}#{window_name}${TAB}#{window_panes} panes#{?#{==:#{window_id},${src_win}}, (here),}"
}

sides() {
  printf '%s\n' \
    "-f -h -b${TAB}h  ◧ left, full height" \
    "-f -h${TAB}l  ◨ right, full height" \
    "-f -v -b${TAB}k  ⬒ top, full width" \
    "-f -v${TAB}j  ⬓ bottom, full width" \
    "-h -b${TAB}H    left of the active pane" \
    "-h${TAB}L    right of the active pane" \
    "-v -b${TAB}K    above the active pane" \
    "-v${TAB}J    below the active pane"
}

src=$("${FZF[@]}" --prompt 'pane> ' --header 'move which pane?' --preview "$preview_pane" < <(list_panes) | cut -f1)
[[ -n $src ]] || exit 0
src_win=$(tmux display -p -t "$src" '#{window_id}')

dst=$("${FZF[@]}" --prompt 'to> ' --header 'move it where?' \
  --preview 'case {1} in new:*) echo "fresh window";; *) tmux capture-pane -ep -t {1} | tail -n "$FZF_PREVIEW_LINES";; esac' \
  < <(list_targets "$src_win") | cut -f1)
[[ -n $dst ]] || exit 0

if [[ $dst == new:* ]]; then
  tmux break-pane -d -s "$src" -t "${dst#new:}:"
else
  flags=$("${FZF[@]}" --prompt 'side> ' --header "put it on which side of $(tmux display -p -t "$dst" '#{session_name}:#{window_index}')?" \
    --preview-window hidden --disabled --no-input \
    --bind 'h:pos(1)+accept,l:pos(2)+accept,k:pos(3)+accept,j:pos(4)+accept' \
    --bind 'H:pos(5)+accept,L:pos(6)+accept,K:pos(7)+accept,J:pos(8)+accept' \
    < <(sides) | cut -f1)
  [[ -n $flags ]] || exit 0

  target=$dst
  if [[ $dst == "$src_win" ]]; then
    target=$(tmux list-panes -t "$dst" -F '#{pane_id}' | grep -vx "$src" | head -1)
    [[ -n $target ]] || { tmux display 'that pane is already alone in its window'; exit 0; }
  fi
  # shellcheck disable=SC2086
  tmux join-pane $flags -s "$src" -t "$target"
fi

tmux switch-client -t "$(tmux display -p -t "$src" '#{session_id}')"
tmux select-window -t "$(tmux display -p -t "$src" '#{window_id}')"
tmux select-pane -t "$src"
