#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

time_hour=$(date +"%H")
time_minute_second=$(date +"%M:%S")

props=(
    icon="$time_hour"
    label="$time_minute_second"
)

sketchybar --set "time" "${props[@]}"
