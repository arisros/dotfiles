
#!/bin/bash

source "$CONFIG_DIR/env.sh" # Loads all defined colors
source "$CONFIG_DIR/sketch_aero.sh"
source "$CONFIG_DIR/helper_sketchybar.sh"

sketchybar --add event aerospace_workspace_change
need_swap_monitor=$(is_need_swap_monitor)
count_monitors=$(get_count_monitors)
# Detect monitor count and whether we need to swap monitors
divider_every=4
divider_count=0

for monitor_ in $(aerospace list-monitors | awk '{print $1}'); do
    monitor="$monitor_"
    [[ "$need_swap_monitor" == true ]] && [[ "$monitor_" == 1 ]] && monitor="2"
    [[ "$need_swap_monitor" == true ]] && [[ "$monitor_" == 2 ]] && monitor="1"

    [[ "$count_monitors" -gt 1 || "$monitor_" == 1 ]] && add_empty_space "$monitor_" "$monitor"

    for sid in $(aerospace list-workspaces --monitor "$monitor_"); do
        add_workspace "$sid" "$monitor"

        add_windows_to_workspace "$sid" "$monitor"

        ((divider_count++))
        ((divider_count % divider_every == 0)) && add_divider "$sid" "$monitor"
    done
done

