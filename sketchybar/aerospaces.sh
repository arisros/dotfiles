#!/bin/bash


source "$CONFIG_DIR/env.sh" # Loads all defined colors
source "$CONFIG_DIR/sketch_aero.sh"

sketchybar --add event aerospace_workspace_change

# need swap monitor if needed
count_monitors=$(aerospace list-monitors | wc -l)
index_monitor=0
# if count_monitors larger than 1
if [[ "$count_monitors" -gt 1 ]]; then
    need_swap_monitor=true
else
    need_swap_monitor=false
fi

divider_every=4
divider_count=0

for monitor_ in $(aerospace list-monitors | awk '{print $1}'); do
    monitor="$monitor_"
    if [[ "$need_swap_monitor" == true ]]; then
        [[ "$monitor_" == 1 ]] && monitor="2"
        [[ "$monitor_" == 2 ]] && monitor="1"
    fi

    # add space when monitors are more than 1 AND index_monitor is not 0 OR first monitor
    if [[ "$count_monitors" -gt 1 && "$index_monitor" -ne 0 ]] || [[ "$index_monitor" -eq 0 ]]; then
        sketchybar --add item "empty_space.$sid" left \
            --set "empty_space.$sid" \
            display="$monitor" \
            width=20
    fi
    index_monitor=$((index_monitor + 1))

    for sid in $(aerospace list-workspaces --monitor "$monitor_"); do
        sketchybar --add item "space.$sid" left \
            --subscribe space.$sid aerospace_workspace_change \
            --set "space.$sid" \
            display="$monitor" \
            width=30 \
            icon.padding_right=0 \
            icon.padding_left=0 \
            label=$sid \
            label.width=30 \
            label.color=0xFFFFFFFF \
            label.font="IBM Plex Mono:Regular:12.0" \
            label.align="center" \
            background.color=0x00000000 \
            background.height=30 \
            icon.font="sketchybar-app-font:Regular:5.0" \
            icon.color=0xFFFFFFFF \
            script="$CONFIG_DIR/sketch_aero.sh $sid"

        json_items=$(aerospace list-windows --workspace "$sid" --json --format %{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name})

        # Get Aerospace Windows JSON
        if ! echo "$json_items" | jq -e '.' >/dev/null 2>&1; then
            echo "Invalid JSON from Aerospace" >&2
            continue
        fi

        count=$(jq length <<< "$json_items" 2>/dev/null || echo 0)
        [[ ! "$count" =~ ^[0-9]+$ ]] && continue

        for ((i = 0; i < count; i++)); do
            workspace=$(jq -r --argjson i "$i" '.[$i]["workspace"] // empty' <<< "$json_items")
            app_name=$(jq -r --argjson i "$i" '.[$i]["app-name"] // empty' <<< "$json_items")
            window_id=$(jq -r --argjson i "$i" '.[$i]["window-id"] // empty' <<< "$json_items")
            monitor_id=$(jq -r --argjson i "$i" '.[$i]["monitor-id"] // empty' <<< "$json_items")
            # echo "Workspace: $workspace"
            # echo "SID: $sid"
            # echo "App Name: $app_name"
            [[ "$workspace" != "$sid" ]] && continue
            [[ -z "$app_name" ]] && continue
            icon="$($CONFIG_DIR/icons_apps.sh "$app_name")"
            # Add to SketchyBar with window ID to prevent overwriting
            sketchybar --add item "app.$sid.$window_id" left \
                --set "app.$sid.$window_id" \
                display="$monitor" \
                width=30 \
                icon.padding_right=0 \
                icon.padding_left=0 \
                label.padding_left=0 \
                label.padding_right=0 \
                background.color=0xFF5c5c5c  \
                background.height=30 \
                icon="$icon" \
                icon.width=30 \
                icon.font="sketchybar-app-font:Regular:14.0"
        done

        divider_count=$((divider_count + 1))
        if [[ $((divider_count % divider_every)) -eq 0 ]]; then
            echo "Adding Divider"
            sketchybar --add item "divider.$sid" left  \
                --set "divider.$sid" \
                width=20 \
                background.padding_left=10 \
                background.height=1 \
                background.padding_right=-30 \
                background.color=0xFFFFFFFF \
                background.y_offset=0 \
                background.corner_radius=0 \
                icon.padding_right=0 \
                icon.padding_left=0 \
                label.padding_left=0 \
                label.padding_right=0 \
                display="$monitor"
        fi
    done
done

# # Iterate over all monitors
# for monitor in $(aerospace list-monitors | awk '{print $1}'); do
#     # Iterate over all workspaces for the current monitor
#     for sid in $(aerospace list-workspaces --monitor "$monitor"); do
#         sketchybar --add item space.$sid left \
    #             --set space.$sid \
    #             label="$sid" \
    #             display="$monitor" \
    #             background.color=0x00000000 \
    #             icon.padding_left=5 \
    #             icon.padding_right=5 \
    #             label.padding_left=10 \
    #             label.padding_right=10 \
    #             label.font="SF Pro:Bold:14.0" \
    #             label.color=0xFFFFFFFF \
    #             icon.color=0xFFFFFFFF \
    #             update_freq=1 \
    #             script="sketchybar --set space.$sid label=\$(aerospace active-workspace --monitor $monitor)" \
    #             --subscribe space.$sid aerospace_workspace_change display_change system_woke
#     done
# done
#
