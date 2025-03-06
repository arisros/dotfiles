#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

time_hour=$(date +"%H")
time_minute=$(date +"%M")

props=(
    icon="$time_hour"
    label="$time_minute"
)

props_second=(
    icon=""
    label="$(date +"%S")"
)

sketchybar --set "time" "${props[@]}"
sketchybar --set "second" "${props_second[@]}"
