#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

props=(
  background.height="$ITEM_HEIGHT_WITH_LABEL"
  label.color="$MAUVE"
  icon.font="$FONT:$((FONTSIZE - 2))"
  label.font="$FONT:$((FONTSIZE - 4))"
  update_freq=1
  script="$PLUGIN_DIR/clock.sh"
)
sketchy_add_item time right --set time "${props[@]}" \
  --subscribe time mouse.clicked

