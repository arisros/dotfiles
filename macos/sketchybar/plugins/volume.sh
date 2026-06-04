#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  volume=$INFO

  case "$volume" in
  [6-9][0-9] | 100)
    icon="$ICON_VOLUME_3"
    ;;
  [3-5][0-9])
    icon="$ICON_VOLUME_2"
    ;;
  [1-9] | [1-2][0-9])
    icon="$ICON_VOLUME_1"
    ;;
  *) icon="$ICON_VOLUME_0" ;;
  esac

  props=(
    icon="$icon"
    icon.color="$LAVENDER"
    label="$volume%"
    label.color="$LAVENDER"
    icon.align="left"
    icon.padding_left=8
    background.height="$ITEM_HEIGHT"
  )
  sketchybar --set "$NAME" "${props[@]}"
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  open x-apple.systempreferences:com.apple.Sound-Settings.extension
fi
