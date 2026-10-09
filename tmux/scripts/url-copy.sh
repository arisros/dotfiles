#!/usr/bin/env bash
# Pick a URL from a pane with fzf and copy it through OSC 52, bound to <prefix> o on headless hosts.
# Usage: url-copy.sh <pane-id> [client]   Debug: url-copy.sh --list <pane-id>
set -uo pipefail

list_urls() {
  tmux capture-pane -J -p -S -2000 -t "$1" |
    grep -oE '(https?|ftp)://[^][:space:]"<>`'\''[]+' |
    sed -E 's/[.,;:!?)]+$//' |
    tac | awk '!seen[$0]++'
}

if [[ ${1:-} == --list ]]; then
  list_urls "${2:?pane id}"
  exit
fi

pane=${1:?pane id}
client=${2:-}
urls=$(list_urls "$pane")
if [[ -z $urls ]]; then
  tmux display-message 'no urls in this pane'
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
printf '%s\n' "$urls" >"$tmp/urls"

tmux display-popup ${client:+-c "$client"} -E -w 80% -h 50% -b rounded -T ' copy url ' \
  "fzf --multi --no-sort --reverse --prompt='copy> ' --header='enter copy · tab mark several' <'$tmp/urls' >'$tmp/picked'"

[[ -s $tmp/picked ]] || exit 0
printf '%s' "$(<"$tmp/picked")" | "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../osc52-copy.sh"
tmux display-message "copied $(wc -l <"$tmp/picked" | tr -d ' ') url(s)"
