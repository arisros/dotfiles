#!/bin/sh
# OSC 52 clipboard bridge for headless/SSH tmux.
# Reads text on stdin and pushes it to the *local* terminal's clipboard
# (Ghostty/Kitty/iTerm2 all support OSC 52), so yanking on this homelab
# lands in the Mac clipboard. No X server or xclip required.

b64=$(base64 | tr -d '\r\n')

# Write straight to each attached client's tty: that pty is the SSH channel to
# the outer terminal, so the sequence must NOT be wrapped in tmux passthrough.
tmux list-clients -F '#{client_tty}' 2>/dev/null | while read -r tty; do
    [ -w "$tty" ] && printf '\033]52;c;%s\007' "$b64" > "$tty"
done
