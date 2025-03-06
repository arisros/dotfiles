#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

sketchy_add_item date right \
    --set date update_freq=1 \
    label="$(date +"%a")" \
    icon="$(date +"%d")" \
    icon.width=30 \
    icon.y_offset=10 \
    icon.padding_right=10 \
    icon.padding_left=10 \
    label.y_offset=-5 \
    label.width=30 \
    label.padding_left=-43 \
    label.align="center" \
    label.font="$FONT:$((FONTSIZE + 2))" \
    icon.color="$WHITE" \
    icon.font="IBM Plex Mono:Bold:$((FONTSIZE + 4))" \
    label.color="$WHITE" \
    background.height=35 \
    background.padding_left=10
--subscribe dateday mouse.clicked


