#!/usr/bin/env bash
source "$CONFIG_DIR/helper_sketchybar.sh"

workspace="$1"
monitor="$2"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    focus_workspace $workspace $monitor
    find_windows_in_workspace $workspace $monitor
fi
