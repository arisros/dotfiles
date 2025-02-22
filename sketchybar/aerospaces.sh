#!/bin/bash

# Iterate over all monitors
for monitor in $(aerospace list-monitors | awk '{print $1}'); do
  # Iterate over all workspaces for the current monitor
  for sid in $(aerospace list-workspaces --monitor "$monitor"); do
    sketchybar --add item space.$sid left \
      --set space.$sid \
      label="$sid" \
      display="$monitor" \
      background.color=0x00000000 \
      icon.padding_left=5 \
      icon.padding_right=5 \
      label.padding_left=10 \
      label.padding_right=10 \
      label.font="SF Pro:Bold:14.0" \
      label.color=0xFFFFFFFF \
      icon.color=0xFFFFFFFF \
      update_freq=1 \
      script="sketchybar --set space.$sid label=\$(aerospace active-workspace --monitor $monitor)" \
      --subscribe space.$sid aerospace_workspace_change display_change system_woke
  done
done

