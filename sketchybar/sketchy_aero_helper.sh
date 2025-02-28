# workspace is $sid
# space app.$sid.$window_id
# divider divider.$sid

get_windows_in_workspace() {
    windows=$(aerospace list-windows --workspace "$sid" --json --format %{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name})
}

add_space_to_worspace() {}

space_in_workspace() {}

remove_space_from_workspace() {}

