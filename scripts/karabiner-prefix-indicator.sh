#!/usr/bin/env bash
# On-screen state for the Karabiner browser prefix layer (macos/karabiner).
#
# Karabiner calls this from `shell_command` on every arm and disarm, so it must
# be fast and must never fail: a non-zero exit or a hang here would sit in the
# path of a keystroke. Every call is best-effort.
#
#   prefix  Home was pressed, waiting for the next key
#   copy    caret-browsing copy-mode is active
#   off     back to idle
#
# Karabiner runs shell_command through /bin/sh with a minimal PATH, so Homebrew
# has to be put back on it before sketchybar or borders can be found.
PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
export PATH

ARMED="0xfff38ba8"   # $RED, macos/sketchybar/colors.sh
IDLE="0xffCC6766"    # active_color, macos/borders/bordersrc

show() {
    sketchybar --set tmux_prefix drawing=on label="$1" >/dev/null 2>&1 || true
    borders active_color="$ARMED" >/dev/null 2>&1 || true
}

case "${1:-off}" in
    prefix) show "PREFIX" ;;
    copy)   show "COPY" ;;
    *)
        sketchybar --set tmux_prefix drawing=off >/dev/null 2>&1 || true
        borders active_color="$IDLE" >/dev/null 2>&1 || true
        ;;
esac
exit 0
