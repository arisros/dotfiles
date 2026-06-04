#!/usr/bin/env bash


log() {
  echo "$1" >> "$CACHE_DIR/$LOG_FILE"
}

# check for whole word match in array
item_in_array() {
  local item="$1"
  shift
  if printf '%s\n' "$@" | rg -q "^$item$"; then
    return 0
  else
    return 1
  fi
}

remove_first_item() {
  local item_to_delete="$1"
  shift
  local list=("$@")
  local new_list=()
  local removed=false

  for item in "${list[@]}"; do
    if [[ "$item" == "$item_to_delete" && "$removed" == false ]]; then
      removed=true
      continue
    fi
    new_list+=("$item")
  done

  echo "${new_list[@]}"
}


unmatched_items() {
  # delimit by space or newline
  local IFS=$' \n'
  source=($1)
  target=($2)

  for key in "${source[@]}"; do
    for i in "${target[@]}"; do
      if [[ "$i" =~ ^window.*\.$key\.* ]]; then
        target=($(remove_first_item "$i" "${target[@]}"))
        break
      fi
    done
  done

  # Filter out empty strings and .default entries
  for i in "${target[@]}"; do
    if [[ -n "$i" && ! "$i" =~ \.default$ ]]; then
      result+=("$i")
    fi
  done

  echo "${result[@]}"
}
