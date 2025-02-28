#!/usr/bin/env bash


if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME \
        background.color=0xFFCC6766 \
        label.color=0xFF000000
else
    sketchybar --set $NAME \
        background.color=0xFF000000 \
        label.color=0xFFFFFFFF
fi
