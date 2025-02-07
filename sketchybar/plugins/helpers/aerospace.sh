#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"
source "$CONFIG_DIR/plugins/helpers/util.sh"

get_space_color() {
  local sid="$1"
  local space_color="$EVEN_SPACE"
  if [ $((sid % 2)) -eq 0 ]; then
    space_color="$ODD_SPACE"
  fi
  echo "$space_color"
}

aerospace_workspaces() {
  echo "$(aerospace list-workspaces --all)"
}

aerospace_focused_workspace() {
  echo "$(aerospace list-workspaces --focused)"
}

# returns window_ids ex: 46356
aerospace_window_ids_in_workspace() {
  local sid="$1"
  local json=$(aerospace list-windows --workspace "$sid" --json --format %{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name})
  local filtered=$(echo "$json" | jq -r '.[] | ."window-id"' | jq -s -r 'join(" ")')
  echo "$filtered"
}

# returns appname ex: Cursor from window_id ex: 46356
aerospace_appname_from_window_id() {
  local window_id="$1"
  local json=$(aerospace list-windows --all --json --format '%{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name}')
  local filtered=$(echo "$json" | jq -r --arg window_id "$window_id" '.[] | select(."window-id" == ($window_id | tonumber)) | ."app-name"')
  echo "$filtered"
}

aerospace_highlight_window_id() {
  # ex: 46356
  local window_id="$1"
  local prev_window_id

  if [ -f "$CACHE_DIR/highlighted" ]; then
    read -r prev_window_id <"$CACHE_DIR/highlighted"
  fi

  if [ -n "$prev_window_id" ] && [ "$prev_window_id" != "$window_id" ]; then
    prev_item=$(sketchy_get_item_by_window_id "$prev_window_id")
    if [ -n "$prev_item" ]; then
      local prev_space=$(sketchy_get_space_by_item "$prev_item")
      local space_color=$(get_space_color "$prev_space")
      sketchybar --set "$prev_item" \
        icon.color="$OFF" \
        background.border_width=0 \
        background.color="$space_color"
    fi
  fi

  # item ex: window.3.66286.WezTerm
  item=$(sketchy_get_item_by_window_id "$window_id")
  if [ -n "$item" ]; then
    local space=$(sketchy_get_space_by_item "$item")
    local space_color=$(get_space_color "$space")
    sketchybar --set "$item" \
      icon.color="$ON" \
      background.border_width="$BORDER_WIDTH" \
      background.border_color="$ACTIVE" \
      background.color="$space_color"
  fi

  echo "$window_id" >"$CACHE_DIR/highlighted"
}

aerospace_workspace_focus(){
  # for default item, use spaceid as window_id
  local sid="$1"
  local item=$(sketchy_get_item_by_window_id "$sid")
  if [ -n "$item" ]; then
    # TODO: gotcha if finder is open
    # focus on finder so that yabai_window_focused will fire next change
    osascript -e 'tell application "Finder" to activate'
    aerospace_highlight_window_id "$sid"
  fi
}

remove_unmatched_items() {
  local sid="$1"
  aerospace_window_ids=$(aerospace_window_ids_in_workspace "$sid")
  sketchy_apps=$(sketchy_get_window_items_in_spaceid "$sid")
  apps_to_remove=$(unmatched_items "$aerospace_window_ids" "$sketchy_apps")
  if [[ -n "$apps_to_remove" ]]; then
    sketchy_remove_item "$apps_to_remove"
    maybe_add_default_item_to_spaceid "$sid"
  fi
}

aerospace_highlight_focused_window() {
  local window_id=$(yabai_get_focused_window_id)
  if [ -n "$window_id" ]; then
    aerospace_highlight_window_id "$window_id"
  fi
  local sid=$(aerospace_focused_workspace)
  aerospace_workspace_focus "$sid"
}

aerospace_workspace_change() {
  # default window uses sid as window_id
  local sid="$1"
  local prev_sid="$2"

  remove_unmatched_items "$prev_sid"
  aerospace_add_apps_in_spaceid "$sid"

  maybe_remove_default_item_from_spaceid "$sid"
  aerospace_highlight_focused_window
}

maybe_add_default_item_to_spaceid() {
  local sid="$1"
  if [ -z "$(sketchy_get_window_items_in_spaceid "$sid")" ]; then
    local item="window.$sid.$sid.default"
    local space_color=$(get_space_color "$sid")
    local props=(
      background.corner_radius=0
      background.height="$ITEM_HEIGHT"
      background.color="$space_color"
      label.drawing=off
      icon.font="$ICON_FONT:$ICON_FONTSIZE"
    )
    sketchy_add_item "$item" left \
      --move "$item" before "divider.$sid" \
      --set "$item" "${props[@]}" icon="·" \
      click_script="aerospace workspace $sid"
    
    aerospace_highlight_window_id "$sid"
  fi
}

maybe_remove_default_item_from_spaceid() {
  local sid="$1"
  local items=$(sketchy_get_window_items_in_spaceid "$sid")
  local item_count=$(echo "$items" | wc -w | tr -d ' ')
  if [[ "$items" == *"window.$sid.$sid.default"* ]] && [[ "$item_count" -gt 1 ]]; then
    sketchy_remove_item "window.$sid.$sid.default"
  fi
}


aerospace_remove_window_id() {
  # ex: 46356
  local window_id="$1"
  local sid=$(aerospace_focused_workspace)
  # item ex:window.3.66286.WezTerm
  item=$(sketchy_get_item_by_window_id "$window_id")
  sketchy_remove_item "$item"

  # add default if no apps in workspace
  maybe_add_default_item_to_spaceid "$sid"
}


aerospace_new_window_id() {
  # ex: 46356
  local window_id="$1"
  local sid=$(aerospace_focused_workspace)

  # ex: Cursor
  appname=$(aerospace_appname_from_window_id "$window_id")

  icon="$($CONFIG_DIR/icons_apps.sh "$appname")"
  item="window.$sid.$window_id.$appname"
  space_color=$(get_space_color "$sid")
  props=(
    background.corner_radius=0
    background.height="$ITEM_HEIGHT"
    label.drawing=off
    icon.font="$ICON_FONT:$ICON_FONTSIZE"
  )
  sketchy_add_item "$item" left \
    --move "$item" before "divider.$sid" \
    --set "$item" "${props[@]}" \
    icon="$icon" icon.color="$OFF" \
    click_script="aerospace focus --window-id $window_id"

   # remove default if it exists
  maybe_remove_default_item_from_spaceid "$sid"

  aerospace_highlight_window_id "$window_id"
}

aerospace_add_apps_in_spaceid() {
  local sid="$1"

  local space_color=$(get_space_color "$sid")

  props=(
    y_offset=1
    background.corner_radius=0
    background.height="$ITEM_HEIGHT"
    background.color="$space_color"
    label.drawing=off
    icon.font="$ICON_FONT:$ICON_FONTSIZE"
  )

  aerospace_window_ids=$(aerospace_window_ids_in_workspace "$sid")

  if [ -n "${aerospace_window_ids}" ]; then
    # Read space-separated window_ids into an array and iterate
    read -ra window_id_array <<< "$aerospace_window_ids"
    for window_id in "${window_id_array[@]}"; do
      appname=$(aerospace_appname_from_window_id "$window_id")
      icon="$($CONFIG_DIR/icons_apps.sh "$appname")"

      # only add if doesn't already exist
      item="window.$sid.$window_id.$appname"
      sketchy_add_item "$item" left \
        --move "$item" before "divider.$sid" \
        --set "$item" "${props[@]}" \
        icon="$icon" icon.color="$OFF" \
        click_script="aerospace focus --window-id $window_id"
    done
  else
    maybe_add_default_item_to_spaceid "$sid"
  fi
}

