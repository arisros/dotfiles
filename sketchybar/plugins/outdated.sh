#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

# reprocess on mouse click
props=(
  label="?"
  icon.color="$BLUE"
)
sketchybar --set "$NAME" "${props[@]}"

sum=0

count=$(mise list | grep -o '\boutdated\b' | wc -l | tr -d '[:space:]')
sleep 3
sum=$((sum + count))

count=$(brew outdated | wc -l | tr -d ' ')
sleep 1
sum=$((sum + count))

case "$sum" in
0)
	color="$GREEN"
	sum="$ICON_CHECKMARK"
	;;
[1-2])
	color="$YELLOW"
	;;
[3-4])
	color="$PEACH"
	;;
*)
	color="$RED"
	;;
esac

props=(
	label="$sum"
	icon.color="$color"
  label.color="$color"
)
sketchybar --set "$NAME" "${props[@]}"
