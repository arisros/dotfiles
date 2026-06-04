#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

sketchybar --add event update_outdated

props=(
	label.y_offset=0 # undo hack
	label.padding_left=0 # undo hack
  label.padding_right=0 # undo hack
	icon.drawing=off
	background.height="$LABEL_ONLY_HEIGHT"
	icon="$ICON_LEGO"
	update_freq="$((60 * 60))" # once per hour
	script="$PLUGIN_DIR/outdated.sh"
)
sketchy_add_item outdated right \
	--set outdated "${props[@]}" \
	--subscribe outdated update_outdated mouse.clicked
