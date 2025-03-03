#!bin/bash
source "$CONFIG_DIR/env.sh" # Loads all defined colors

get_count_monitors() {
    count_monitors=$(aerospace list-monitors | wc -l)
    echo $count_monitors
}

is_need_swap_monitor() {
    ((count_monitors > 1)) && need_swap_monitor=true
    count_monitors=$(get_count_monitors)
    need_swap_monitor=false
    (( count_monitors > 1 )) && need_swap_monitor=true

    echo $need_swap_monitor
}

focus_workspace() {
    local except="$1"
    local monitor_="$2"
    local monitor="$monitor_"

    local need_swap_monitor=$(is_need_swap_monitor)
    [[ "$need_swap_monitor" == true ]] && [[ "$monitor_" == 1 ]] && monitor="2"
    [[ "$need_swap_monitor" == true ]] && [[ "$monitor_" == 2 ]] && monitor="1"

    local workspaces=$(aerospace list-workspaces --monitor "$monitor")

    for sid in $workspaces; do
        if [[ "$sid" == "$except" ]]; then
            sketchybar --set "space.$sid" \
                background.color=0xFFCC6766 \
                label.color=0xFF000000
        else
            sketchybar --set "space.$sid" \
                background.color=0xFF000000 \
                label.color=0xFFFFFFFF
        fi
    done
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

    sketchybar --add item "space.$sid" left \
        --subscribe "space.$sid" aerospace_workspace_change \
        --set "space.$sid" \
        display="$monitor" \
        width=30 \
        icon.padding_right=0 \
        icon.padding_left=0 \
        label="$sid" \
        label.width=30 \
        label.color=0xFFFFFFFF \
        label.font="IBM Plex Mono:Regular:12.0" \
        label.align="center" \
        background.color=0x00000000 \
        background.height=30 \
        icon.font="sketchybar-app-font:Regular:5.0" \
        icon.color=0xFFFFFFFF \
        script="$CONFIG_DIR/sketch_aero.sh $sid $monitor | tee -a /tmp/sketchybar/sketchy_debug.log"
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

    windows=$(aerospace list-windows --workspace "$sid" --json --format '%{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name}')
    count=$(jq length <<< "$windows" 2>/dev/null || echo 0)
    [[ ! "$count" =~ ^[0-9]+$ ]] && continue


    for ((i = 0; i < count; i++)); do

        workspace=$(jq -r --argjson i "$i" '.[$i]["workspace"] // empty' <<< "$windows")
        app_name=$(jq -r --argjson i "$i" '.[$i]["app-name"] // empty' <<< "$windows")
        window_id=$(jq -r --argjson i "$i" '.[$i]["window-id"] // empty' <<< "$windows")

        [[ "$workspace" != "$sid" ]] && continue
        [[ -z "$app_name" ]] && continue

        bar=$(sketchybar --query bar | jq -r --arg window_id "$window_id" '.items[] | select(test("^app\\." + $window_id + "$"))')
        window_app_bar_id="app.$window_id"
        if [[ "$bar" == "$window_app_bar_id" ]]; then
            sketchybar --move "$bar" after "space.$sid"
            sketchybar --set "$bar" display="$monitor"
            continue
        fi
        if [[ ! -z "$window_app_bar_id" ]]; then
            add_window "$sid" "$monitor" "$app_name" "$window_id"
        fi

    done

}

add_windows_to_workspace() {
    local sid="$1"
    local monitor="$2"

    json_items=$(aerospace list-windows --workspace "$sid" --json --format '%{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name}')

    if ! jq -e '.' <<< "$json_items" >/dev/null 2>&1; then
        echo "Invalid JSON from Aerospace" >&2
        continue
    fi


    count=$(jq length <<< "$json_items" 2>/dev/null || echo 0)
    [[ ! "$count" =~ ^[0-9]+$ ]] && continue

    for ((i = 0; i < count; i++)); do
        workspace=$(jq -r --argjson i "$i" '.[$i]["workspace"] // empty' <<< "$json_items")
        app_name=$(jq -r --argjson i "$i" '.[$i]["app-name"] // empty' <<< "$json_items")
        window_id=$(jq -r --argjson i "$i" '.[$i]["window-id"] // empty' <<< "$json_items")

        [[ "$workspace" != "$sid" ]] && continue
        [[ -z "$app_name" ]] && continue

        add_window "$sid" "$monitor" "$app_name" "$window_id"
    done
}
