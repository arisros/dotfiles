#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

sketchy_add_item second right \
    --set second update_freq=1 \
    icon="a" \
    label="$(date +"%S")" \
    icon.width=30 \
    icon.y_offset=2 \
    icon.padding_right=10 \
    icon.padding_left=10 \
    label.y_offset=-0 \
    label.width=30 \
    label.padding_left=-40 \
    label.align="center" \
    icon.font="$FONT:$((FONTSIZE + 4))" \
    icon.color="$WHITE" \
    label.font="$FONT:$((FONTSIZE + 4))" \
    label.color="$WHITE" \
    background.height=35 \
    background.padding_left=-2 \
    update_freq=1 \
    script="$PLUGIN_DIR/clock.sh" \
    --subscribe time mouse.clicked


sketchy_add_item time right \
    --set time update_freq=1 \
    icon="$(date +"%H")" \
    label="$(date +"%M")" \
    icon.width=30 \
    icon.y_offset=12 \
    icon.padding_right=10 \
    icon.padding_left=10 \
    label.y_offset=-10 \
    label.width=30 \
    label.padding_left=-40 \
    label.align="center" \
    icon.font="IBM Plex Mono:Bold:$((FONTSIZE + 4))" \
    icon.color="$WHITE" \
    label.font="IBM Plex Mono:Bold:$((FONTSIZE + 4))" \
    label.color="$WHITE" \
    background.height=35 \
    background.padding_left=10 \
    update_freq=1 \
    script="$PLUGIN_DIR/clock.sh" \
    --subscribe time mouse.clicked


# props_date=(
#     icon="dte"
#     background.color="$LAVENDER"
#     background.height=30
#     # icon.font="$FONT:$((FONTSIZE - 2))"
#     # icon.color="$WHITE"
#     # icon.align=center
#     # icon.padding_left=0
#     # icon.padding_right=0
#     # background.padding_left=0
#     # background.padding_right=0
#     padding_left=30
#     background.padding_left=30
#     y_offset=10
#     width=10
#     icon.y_offset=-10
#     icon.width=30
#     label.width=30
#     icon.padding_right=0
#     icon.color="$WHITE"
#     label.padding_left=50
#     label="$(date +"%a")" # label.font="$FONT:$((FONTSIZE - 2))"
#     # label.color="$WHITE"
#     # label.align=center
#     update_freq=1
# )
#
# sketchy_add_item date_deck right --set date_deck "${props_date[@]}" \
    #     --subscribe date_deck mouse.clicked
#
# props=(
#     label.color="$WHITE"
#     icon.padding_left=0
#     icon.padding_right=0
#     icon.font="$FONT:$((FONTSIZE - 2))"
#     icon.color="$WHITE"
#     label.font="$FONT:$((FONTSIZE - 2))"
#     icon.align=center
#     label.align=center
#     icon.padding_left=0
#     icon.padding_right=0
#
#     label="just tes"
#     update_freq=1
#     script="$PLUGIN_DIR/clock.sh"
# )
# sketchy_add_item time right --set time "${props[@]}" \
    #     --subscribe time mouse.clicked
#
