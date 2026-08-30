#!/usr/bin/env bash
# Mirrors tmux's own prefix indicator (@minimal-tmux-indicator-str "●", red, top)
# for the browser prefix layer in macos/karabiner. Hidden until armed; toggled by
# scripts/karabiner-prefix-indicator.sh, which Karabiner calls on arm/disarm.

source "$PLUGIN_DIR/helpers/sketchy.sh"

sketchy_add_item tmux_prefix left \
    --set tmux_prefix \
    drawing=off \
    icon="●" \
    icon.font="$FONT:Bold:$((FONTSIZE + 2))" \
    icon.color="$RED" \
    icon.padding_left=10 \
    icon.padding_right=6 \
    label="PREFIX" \
    label.font="$FONT:Bold:$FONTSIZE" \
    label.color="$RED" \
    label.padding_right=10 \
    background.height="$ITEM_HEIGHT"
