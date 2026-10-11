#!/usr/bin/env bash
# Open a file at a line in a Neovim that is already running, for tools that can
# only run a command (fate-studio --editor-cmd, a browser bridge, a test runner).
#
#   nvim-open.sh <path> [line]
#
# Picks the Neovim whose working directory holds the file, then brings its tmux
# pane to the front. With no Neovim running it opens one in a new tmux window.
# NVIM_OPEN_APP names a macOS app to raise afterwards, e.g. Ghostty.
set -uo pipefail

file="${1:?usage: nvim-open.sh <path> [line]}"
line="${2:-1}"
case "$line" in '' | *[!0-9]*) line=1 ;; esac

ask() { nvim --server "$1" --remote-expr "$2" 2>/dev/null; }

run_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
best='' best_len=-1
listening="$(ps -eo args= | sed -n 's/^.*nvim.* --listen \(\/[^ ]*\).*$/\1/p')"
for sock in "$run_dir"/nvim.*.0 "$run_dir"/nvim.*/*/nvim.*.0 /tmp/nvim.*/*/nvim.*.0 $listening; do
  [ -S "$sock" ] || continue
  cwd="$(ask "$sock" 'getcwd()')" || continue
  [ -n "$cwd" ] || continue
  case "$file" in
    "$cwd"/*) len=${#cwd} ;;
    *) len=0 ;;
  esac
  if [ "$len" -gt "$best_len" ]; then
    best="$sock" best_len="$len"
  fi
done

if [ -z "$best" ]; then
  if tmux has-session 2>/dev/null; then
    tmux new-window -c "$(dirname "$file")" nvim "+$line" "$file"
  else
    echo "no running nvim, and no tmux session to open one in" >&2
    exit 1
  fi
else
  quoted="${file//\'/\'\'}"
  ask "$best" "execute('edit +$line ' . fnameescape('$quoted'))" >/dev/null || {
    echo "nvim at $best did not open $file" >&2
    exit 1
  }
  # shellcheck disable=SC2016 # expanded by nvim, not the shell
  pane="$(ask "$best" '$TMUX_PANE')"
  if [ -n "$pane" ]; then
    tmux switch-client -t "$pane" 2>/dev/null
    tmux select-window -t "$pane" 2>/dev/null
    tmux select-pane -t "$pane" 2>/dev/null
  fi
fi

if [ -n "${NVIM_OPEN_APP:-}" ] && command -v open >/dev/null 2>&1; then
  open -a "$NVIM_OPEN_APP"
fi
exit 0
