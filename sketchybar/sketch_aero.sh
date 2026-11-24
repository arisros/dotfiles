#!/usr/bin/env bash
source "$CONFIG_DIR/helper_sketchybar.sh"

[[ -n "$FOCUSED_WORKSPACE" ]] || exit 0

monitor=$(get_display_for_monitor "$(aerospace list-workspaces --focused --format '%{monitor-id}')")
focus_workspace "$FOCUSED_WORKSPACE"
find_windows_in_workspace "$FOCUSED_WORKSPACE" "$monitor"
