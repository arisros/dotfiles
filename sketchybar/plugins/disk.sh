#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

props=(
  label="$(df -H ~ | grep -E '^(/dev/).' | awk '{ printf ("%s\n", $5) }')"
  label.color=$SAPPHIRE
)
sketchybar -m --set "$NAME" "${props[@]}"

if [ "$SENDER" = "mouse.clicked" ]; then
  open -a "DaisyDisk"
fi
