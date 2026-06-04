#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

props=(
  label.y_offset=0 # undo hack
	label.padding_left=0 # undo hack
  label.padding_right=0 # undo hack
	icon.drawing=off
	background.height="$LABEL_ONLY_HEIGHT"
  icon="$ICON_DISK"
  icon.color="$SAPPHIRE"
  icon.font="$FONT:$((ICON_FONTSIZE - 4))"
  update_freq=5
  script="$PLUGIN_DIR/disk.sh"
)

sketchy_add_item disk right \
  --set disk "${props[@]}" \
  --subscribe disk mouse.clicked
