#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

sketchy_add_item battery right \
  --set battery update_freq=120 \
  script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery system_woke power_source_change mouse.clicked
