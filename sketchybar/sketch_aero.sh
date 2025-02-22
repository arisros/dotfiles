#!/usr/bin/env bash


if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.color=0xFFF17013
else
    sketchybar --set $NAME background.color=0xFF000000
fi  
