#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

STATE_SCRIPT="${SANDI_STATE_SCRIPT:-$HOME/dotfiles/__scripts__/sandi-state.sh}"

state="unknown"
if [ -x "$STATE_SCRIPT" ]; then
  state="$("$STATE_SCRIPT" 2>/dev/null || printf 'unknown')"
fi

# shellcheck disable=SC2086
set -- $state

case "$1" in
  synced)   label="ok"        ; color=$GREEN    ;;
  ahead)    label="^$2"       ; color=$YELLOW   ;;
  behind)   label="v$2"       ; color=$SKY      ;;
  diverged) label="$2^$3v"    ; color=$PEACH    ;;
  dirty)    label="*$2"       ; color=$MAROON   ;;
  offline)  label="off"       ; color=$OVERLAY1 ;;
  noremote) label="local"     ; color=$OVERLAY1 ;;
  nogit)    label="nogit"     ; color=$RED      ;;
  nostore)  label="none"      ; color=$OVERLAY1 ;;
  *)        label="?"         ; color=$RED      ;;
esac

props=(
    label="S:$label"
    label.color=$color
)
sketchybar -m --set "$NAME" "${props[@]}"

# A click re-runs this script through the mouse.clicked subscription, and the
# fetch above is what refreshes the state, so there is nothing to do here.
