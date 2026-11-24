#!bin/bash
source "$CONFIG_DIR/env.sh" # Loads all defined colors

get_count_monitors() {
    count_monitors=$(aerospace list-monitors | wc -l)
    echo $count_monitors
}

# Maps an AeroSpace monitor ID to the correct sketchybar display number
# by looking up monitor names: Mi 27 NFGL → display 2, Built-in → display 1, DELL → display 3
get_display_for_monitor() {
    local aerospace_id="$1"
    local monitors_json
    monitors_json=$(aerospace list-monitors --json 2>/dev/null)

    # Single-screen mode: sketchybar only has display 1, so the name-based
    # mapping below (which puts Built-in on display 2) would hide every item
    # on a non-existent display. Always use display 1 when there's one monitor.
    local monitor_count
    monitor_count=$(jq 'length' <<< "$monitors_json" 2>/dev/null)
    if [[ "$monitor_count" == "1" ]]; then
        echo "1"
        return
    fi

    local monitor_name
    monitor_name=$(echo "$monitors_json" | jq -r --argjson id "$aerospace_id" \
        '.[] | select(."monitor-id" == $id) | ."monitor-name"')

    if echo "$monitor_name" | grep -qi "Mi"; then
        echo "1"
    elif echo "$monitor_name" | grep -qi "Built-in\|Built in\|Retina"; then
        echo "2"
    else
        # Third monitor (e.g. DELL) — use display 3
        echo "3"
    fi
}

focus_workspace() {
    local focused="$1"
    local args=()

    for sid in $(aerospace list-workspaces --monitor focused); do
        if [[ "$sid" == "$focused" ]]; then
            args+=(--set "space.$sid" background.color=0xFFCC6766 label.color=0xFF000000)
        else
            args+=(--set "space.$sid" background.color=0xFF000000 label.color=0xFFFFFFFF)
        fi
    done
    [[ ${#args[@]} -gt 0 ]] && sketchybar "${args[@]}"
}

add_empty_space() {
    local sid="$1"
    local monitor="$2"

    sketchybar --add item "empty_space.$sid" left \
        --set "empty_space.$sid" \
        display="$monitor" \
        width=20
}

add_workspace() {
    local sid="$1"
    local monitor="$2"
    # sid to uppercase label
    local label=$(tr '[:lower:]' '[:upper:]' <<< "$sid")

    sketchybar --add item "space.$sid" left \
        --set "space.$sid" \
        display="$monitor" \
        width=30 \
        icon.padding_right=0 \
        icon.padding_left=0 \
        label="$label" \
        label.width=30 \
        label.color=0xFFFFFFFF \
        label.font="IBM Plex Mono:Regular:12.0" \
        label.align="center" \
        background.color=0x00000000 \
        background.height=30 \
        icon.font="sketchybar-app-font:Regular:5.0" \
        icon.color=0xFFFFFFFF
}

add_workspace_watcher() {
    sketchybar --add item aerospace.watcher left \
        --set aerospace.watcher drawing=off updates=on script="$CONFIG_DIR/sketch_aero.sh" \
        --subscribe aerospace.watcher aerospace_workspace_change
}

remove_window() {
    local sid="$1"
    local window_id="$2"

    sketchybar --remove "app.$window_id"
}

add_window() {
    local sid="$1"
    local monitor="$2"
    local app_name="$3"
    local window_id="$4"

    icon="$($CONFIG_DIR/icons_apps.sh "$app_name")"

    sketchybar --add item "app.$window_id" left \
        --move "app.$window_id" after "space.$sid" \
        --set "app.$window_id" \
        display="$monitor" \
        width=30 \
        icon.padding_right=0 \
        icon.padding_left=0 \
        label.padding_left=0 \
        label.padding_right=0 \
        background.color=0xFF5c5c5c \
        background.height=30 \
        icon="$icon" \
        icon.width=30 \
        icon.font="sketchybar-app-font:Regular:14.0"

}

add_divider() {
    local sid="$1"
    local monitor="$2"

    sketchybar --add item "divider.$sid" left \
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
}

find_windows_in_workspace() {
    local sid="$1"
    local monitor="$2"

    local all_win bar_items args=()
    all_win=$(aerospace list-windows --all --json --format '%{workspace}%{window-id}%{app-name}') || return
    bar_items=" $(sketchybar --query bar | jq -r '[.items[] | select(startswith("app."))] | join(" ")') "

    local workspace window_id app_name
    while IFS=$'\t' read -r workspace window_id app_name; do
        [[ "$workspace" != "$sid" || -z "$app_name" ]] && continue
        if [[ "$bar_items" == *" app.$window_id "* ]]; then
            args+=(--set "app.$window_id" display="$monitor" --move "app.$window_id" after "space.$sid")
        else
            add_window "$sid" "$monitor" "$app_name" "$window_id"
        fi
    done < <(jq -r '.[] | [.workspace, (."window-id" | tostring), ."app-name"] | @tsv' <<< "$all_win")

    local live
    live=" $(jq -r '[.[]."window-id"] | join(" ")' <<< "$all_win") "
    for item in $bar_items; do
        [[ "$live" == *" ${item#app.} "* ]] || args+=(--remove "$item")
    done

    [[ ${#args[@]} -gt 0 ]] && sketchybar "${args[@]}"
}

add_windows_to_workspace() {
    local sid="$1"
    local monitor="$2"

    json_items=$(aerospace list-windows --workspace "$sid" --json --format '%{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name}')

    if ! jq -e '.' <<< "$json_items" >/dev/null 2>&1; then
        echo "Invalid JSON from Aerospace" >&2
        return
    fi


    count=$(jq length <<< "$json_items" 2>/dev/null || echo 0)
    [[ ! "$count" =~ ^[0-9]+$ ]] && return

    for ((i = 0; i < count; i++)); do
        workspace=$(jq -r --argjson i "$i" '.[$i]["workspace"] // empty' <<< "$json_items")
        app_name=$(jq -r --argjson i "$i" '.[$i]["app-name"] // empty' <<< "$json_items")
        window_id=$(jq -r --argjson i "$i" '.[$i]["window-id"] // empty' <<< "$json_items")

        [[ "$workspace" != "$sid" ]] && continue
        [[ -z "$app_name" ]] && continue

        add_window "$sid" "$monitor" "$app_name" "$window_id"
    done
}
