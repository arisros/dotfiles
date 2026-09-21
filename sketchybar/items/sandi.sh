#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

props=(
  label.y_offset=0 # undo hack
	label.padding_left=0 # undo hack
  label.padding_right=0 # undo hack
	icon.drawing=off
	background.height="$LABEL_ONLY_HEIGHT"
  icon.color="$LAVENDER"
  icon.font="$FONT:$((ICON_FONTSIZE - 4))"
  update_freq=300
  script="$PLUGIN_DIR/sandi.sh"
)

sketchy_add_item sandi right \
  --set sandi "${props[@]}" \
  --subscribe sandi mouse.clicked
