#!/usr/bin/env bash
# Capture a screen region, upload it to a remote host, and put the remote path
# on the clipboard, so it can be pasted into a terminal that is ssh'd there.
#
#   shot-remote.sh [host]   host: argument, else ~/.config/shot-remote/host, else "homelab"
#
# Karabiner runs shell_command with a minimal PATH and no terminal, so results are reported as notifications.
PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
set -uo pipefail

REMOTE_DIR="shots"
KEEP_DAYS=7

notify() { osascript -e "display notification \"$1\" with title \"shot-remote\"" >/dev/null 2>&1 || true; }

host="${1:-}"
[ -n "$host" ] || host="$(cat "$HOME/.config/shot-remote/host" 2>/dev/null || true)"
[ -n "$host" ] || host="homelab"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
name="shot-$(date +%Y%m%d-%H%M%S).png"

screencapture -i "$tmp/$name" 2>/dev/null
# Esc during selection leaves no file.
[ -s "$tmp/$name" ] || exit 0

remote="$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" "
  mkdir -p \"\$HOME/$REMOTE_DIR\" &&
  cat > \"\$HOME/$REMOTE_DIR/$name\" &&
  find \"\$HOME/$REMOTE_DIR\" -name 'shot-*.png' -mtime +$KEEP_DAYS -delete &&
  printf '%s' \"\$HOME/$REMOTE_DIR/$name\"
" < "$tmp/$name" 2>"$tmp/err")"

if [ -z "$remote" ]; then
    notify "upload to $host failed: $(head -c 120 "$tmp/err" | tr -d '"\\')"
    exit 1
fi

printf '%s' "$remote" | pbcopy
notify "copied $remote"
