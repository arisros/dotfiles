#!/usr/bin/env bash
# Switch the MacBook's own keyboard off and on. The trackpad and every external
# keyboard keep working.
#
# Karabiner holds the switch: karabiner/builtin-keyboard.json swallows anything
# coming from the built-in keyboard while the variable builtin_keyboard_disabled
# is 1, and karabiner_cli is the only thing that writes it. The variable lives in
# the running Karabiner process, never on disk, so quitting Karabiner, logging
# out or rebooting always gives the keyboard back. That is the way out when the
# machine has no other keyboard to type "on" with.
set -euo pipefail

VAR="builtin_keyboard_disabled"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/builtin-keyboard"

log()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$*" >&2; }
err()  { printf "\033[1;31m==>\033[0m %s\n" "$*" >&2; }

[ "$(uname -s)" = "Darwin" ] || { err "macOS only (Karabiner-Elements)"; exit 1; }

cli() {
    if command -v karabiner_cli >/dev/null 2>&1; then
        karabiner_cli "$@"
    else
        "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" "$@"
    fi
}

# Identity of the process that holds the variable. Written next to the state and
# compared on read: if Karabiner has restarted since, the variable is back to 0
# and the keyboard is alive again, whatever the state file says.
grabber_id() {
    ps -Ao pid,lstart,command |
        grep 'Karabiner-Core-Service' |
        grep -v grep |
        awk '{print $1, $2, $3, $4, $5, $6}' |
        sort |
        tr '\n' ';'
}

is_off() {
    [ -f "$STATE" ] || return 1
    [ "$(cat "$STATE")" = "$(grabber_id)" ]
}

external_keyboard() {
    cli --list-connected-devices 2>/dev/null |
        jq -r '
            [ .[]
              | select(.device_identifiers.is_keyboard == true)
              | select(.is_built_in_keyboard != true)
              | select(.device_identifiers.is_virtual_device != true)
              | .product ]
            | join(", ")
        ' 2>/dev/null
}

require_karabiner() {
    [ -n "$(grabber_id)" ] || { err "Karabiner-Elements is not running"; exit 1; }
}

set_var() {
    cli --set-variables "{\"$VAR\":$1}" >/dev/null
}

off() {
    require_karabiner
    set_var 1
    mkdir -p "$(dirname "$STATE")"
    grabber_id > "$STATE"

    local ext
    ext="$(external_keyboard)"
    if [ -n "$ext" ]; then
        log "built-in keyboard off (still typing on: $ext)"
    else
        warn "built-in keyboard off, and no external keyboard is connected"
        warn "to get it back without typing: Karabiner menu bar icon > Quit"
    fi
}

on() {
    require_karabiner
    set_var 0
    rm -f "$STATE"
    log "built-in keyboard on"
}

status() {
    if is_off; then
        log "built-in keyboard off"
    else
        log "built-in keyboard on"
    fi
}

case "${1:-status}" in
    off|disable)  off ;;
    on|enable)    on ;;
    toggle)       if is_off; then on; else off; fi ;;
    status|"")    status ;;
    -h|--help|help)
        printf 'usage: %s [off|on|toggle|status]\n' "$(basename "$0")"
        ;;
    *)
        err "unknown command: $1"
        printf 'usage: %s [off|on|toggle|status]\n' "$(basename "$0")" >&2
        exit 1
        ;;
esac
