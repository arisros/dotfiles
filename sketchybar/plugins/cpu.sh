#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

cpuload="$(top -l 2 | grep -E "^CPU" | tail -1 | awk '{ print int($3 + $5 + 0.5)"%" }')"

props=(
  label.y_offset=0 # undo hack
	label.padding_left=0 # undo hack
  label.padding_right=0 # undo hack
	icon.drawing=off
	background.height="$LABEL_ONLY_HEIGHT"
  icon="$ICON_CPU"
  icon.color="$SAPPHIRE"
  icon.font="$FONT:$((ICON_FONTSIZE - 2))"
  label="$cpuload"
  label.color="$SAPPHIRE"
)

if [ -n "$cpuload" ]; then
  sketchybar -m --set "$NAME" "${props[@]}"
fi
  
if [ "$SENDER" = "mouse.clicked" ]; then
  open -a "Activity Monitor"
fi
