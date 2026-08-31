#!/usr/bin/env bash
# fzf-powered window switcher for tmux, bound to <prefix> w.
#
# One row per window, across every session:
#   session:index   window name (or claude session name)   folder   panes inside
# A window holding a claude pane is labelled with that claude session's name -
# claude publishes it through the terminal title, which tmux exposes as
# #{pane_title}. The last column lists what runs inside, so there is nothing to
# expand to see into a window.
#
# The preview has two modes, toggled with ctrl-o:
#   layout - the window redrawn at preview size: every pane as a box in its real
#            position and proportion, filled with the tail of that pane
#   focus  - just the interesting pane (the claude one, else the active one),
#            full width, with colours
#
# Keys:  enter switch   ctrl-o layout/focus   ctrl-x kill window   ctrl-r reload
# Debug: --list                     print the rows
#        --preview <pane-id> <win>  print a preview
#        --toggle-mode              flip the preview mode
set -uo pipefail

self=${BASH_SOURCE[0]}
TAB=$'\t'
mode_file="${TMPDIR:-/tmp}/tmux-window-switcher.mode.$(id -u)"

# claude renames its process to its version ("2.1.251"), which is how a claude
# pane is told apart from any other pane without asking claude itself.
is_claude() { [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ || $1 == claude* ]]; }
awk_is_claude='function is_claude(cmd) { return (cmd ~ /^[0-9]+\.[0-9]+\.[0-9]+$/ || cmd ~ /^claude/) }'

# Pad/truncate to a column width. bash counts characters (not bytes) in a UTF-8
# locale, which awk on macOS does not - hence the formatting lives here.
pad() {
  local s=$1 w=$2 n=${#1}
  if ((n > w)); then printf '%s…' "${s:0:w-1}"; else printf '%s%*s' "$s" "$((w - n))" ''; fi
}

# ---------------------------------------------------------------- the row list

# One row per window: target, pane id the label came from, label, claude?,
# folder, what is running inside, marker.
collect_windows() {
  local current
  current=$(tmux display-message -p '#{session_name}:#{window_index}' 2>/dev/null)

  tmux list-panes -a -F \
    "#{session_name}:#{window_index}${TAB}#{window_name}${TAB}#{?window_zoomed_flag,Z,}${TAB}#{pane_active}${TAB}#{pane_current_command}${TAB}#{pane_title}${TAB}#{?#{==:#{pane_current_path},#{HOME}},~,#{b:pane_current_path}}${TAB}#{pane_id}" |
  awk -F"${TAB}" -v OFS="${TAB}" -v current="${current}" "${awk_is_claude}"'
    {
      target = $1; name = $2; zoom = $3
      active = $4; cmd = $5; title = $6; path = $7; pane = $8

      if (!(target in seen)) { seen[target] = 1; order[++n] = target
                               w_name[target] = name; w_zoom[target] = zoom }

      # what is inside, in pane order - saves expanding anything to find out
      inside[target] = inside[target] (inside[target] == "" ? "" : "·") \
                       (is_claude(cmd) ? "claude" : cmd)

      if (active == "1") { w_path[target] = path; w_pane[target] = pane }
      # any claude pane names the window; the active pane wins over the rest.
      # the preview then follows *that* pane, not just whatever pane is active.
      if (is_claude(cmd) && (w_claude[target] == "" || active == "1")) {
        w_claude[target] = title; w_pane[target] = pane
      }
    }

    END {
      for (i = 1; i <= n; i++) {
        t = order[i]
        claude = (w_claude[t] != "")
        meta = inside[t] (w_zoom[t] != "" ? " Z" : "")
        print t, w_pane[t], (claude ? w_claude[t] : w_name[t]), (claude ? "1" : "0"), \
              w_path[t], meta, (t == current ? ">" : " ")
      }
    }'
}

list_windows() {
  local target pane label claude path meta mark color
  while IFS="${TAB}" read -r target pane label claude path meta mark; do
    color=$([ "$claude" = 1 ] && printf '\033[35m' || printf '\033[0m')
    printf '%s\t%s\t\033[32m%s\033[0m \033[33m%s\033[0m %s%s\033[0m \033[90m%s %s\033[0m\n' \
      "$target" "$pane" "$mark" "$(pad "$target" 12)" "$color" "$(pad "$label" 40)" \
      "$(pad "$path" 20)" "$(pad "$meta" 24)"
  done < <(collect_windows)
}

# ------------------------------------------------------------------- preview

# The visible screen of a pane: trailing blank lines dropped, last `lines` kept.
# The tail is where the live output is; the top has usually scrolled off.
pane_tail() {
  local pane=$1 lines=$2 raw=${3:-}
  tmux capture-pane -p ${raw:+-e} -t "$pane" 2>/dev/null |
    sed -E $'s/\033]8;[^\a\033]*(\a|\033\\\\)//g' |
    awk -v lines="$lines" '
      { buf[NR] = $0 }
      END {
        last = NR
        while (last > 0 && buf[last] ~ /^[[:space:]]*$/) last--
        start = last - lines + 1
        if (start < 1) start = 1
        for (i = start; i <= last; i++) print buf[i]
      }'
}

# A character canvas the panes get painted onto. Everything is plain text while
# painting - colours are added at the very end, so the column arithmetic above
# never has to reason about escape sequences.
canvas=(); canvas_w=0; canvas_h=0

canvas_init() {
  local y blank
  canvas_w=$1; canvas_h=$2; canvas=()
  blank=$(printf '%*s' "$canvas_w" '')
  for ((y = 0; y < canvas_h; y++)); do canvas[y]=$blank; done
}

canvas_put() { # row col text
  local y=$1 x=$2 t=$3 n row
  ((y < 0 || y >= canvas_h || x < 0 || x >= canvas_w)) && return
  ((x + ${#t} > canvas_w)) && t=${t:0:canvas_w - x}
  n=${#t}; ((n == 0)) && return
  row=${canvas[y]}
  canvas[y]="${row:0:x}${t}${row:$((x + n))}"
}

canvas_box() { # row col height width label focused
  local y0=$1 x0=$2 h=$3 w=$4 label=$5 focused=$6 y bar tl tr bl br v
  if [ "$focused" = 1 ]; then bar='═' tl='╔' tr='╗' bl='╚' br='╝' v='║'
  else                        bar='─' tl='┌' tr='┐' bl='└' br='┘' v='│'; fi

  local line=''
  for ((y = 0; y < w - 2; y++)); do line+=$bar; done
  canvas_put "$y0" "$x0" "${tl}${line}${tr}"
  canvas_put "$((y0 + h - 1))" "$x0" "${bl}${line}${br}"
  for ((y = y0 + 1; y < y0 + h - 1; y++)); do
    canvas_put "$y" "$x0" "$v"
    canvas_put "$y" "$((x0 + w - 1))" "$v"
  done
  ((w > 8)) && [ -n "$label" ] && canvas_put "$y0" "$((x0 + 2))" " ${label:0:$((w - 6))} "
}

# The window redrawn at preview size: pane boxes in their real proportions.
layout_preview() {
  local target=$1 focus=$2
  local W=${FZF_PREVIEW_COLUMNS:-80} H=${FZF_PREVIEW_LINES:-40}
  local ww wh pane idx active left top pw ph cmd title
  local x0 y0 x1 y1 bw bh label flag i line
  local -a body

  read -r ww wh < <(tmux display-message -p -t "$target" '#{window_width} #{window_height}' 2>/dev/null)
  [ -n "${ww:-}" ] && [ -n "${wh:-}" ] && ((ww > 0 && wh > 0)) || return 1
  canvas_init "$W" "$H"

  while IFS="${TAB}" read -r pane idx active left top pw ph cmd title; do
    x0=$((left * W / ww));          y0=$((top * H / wh))
    x1=$(((left + pw) * W / ww));   y1=$(((top + ph) * H / wh))
    ((x1 > W)) && x1=$W
    ((y1 > H)) && y1=$H
    bw=$((x1 - x0)); bh=$((y1 - y0))
    ((bw < 3)) && bw=3
    ((bh < 3)) && bh=3
    ((x0 + bw > W)) && x0=$((W - bw))
    ((y0 + bh > H)) && y0=$((H - bh))
    ((x0 < 0)) && x0=0
    ((y0 < 0)) && y0=0

    flag=' '; [ "$active" = 1 ] && flag='*'
    if is_claude "$cmd"; then label="${idx}${flag} ${title#✳ }"; else label="${idx}${flag} ${cmd}"; fi

    # bottom-aligned, like a real terminal: the newest output sits at the
    # bottom edge of the box, empty space above it
    body=()
    while IFS= read -r line; do body+=("${line:0:$((bw - 2))}"); done \
      < <(pane_tail "$pane" "$((bh - 2))")
    for ((i = 0; i < ${#body[@]}; i++)); do
      canvas_put $((y0 + bh - 1 - ${#body[@]} + i)) $((x0 + 1)) "${body[i]}"
    done

    canvas_box "$y0" "$x0" "$bh" "$bw" "$label" "$([ "$pane" = "$focus" ] && echo 1 || echo 0)"
  done < <(tmux list-panes -t "$target" -F \
    "#{pane_id}${TAB}#{pane_index}${TAB}#{pane_active}${TAB}#{pane_left}${TAB}#{pane_top}${TAB}#{pane_width}${TAB}#{pane_height}${TAB}#{pane_current_command}${TAB}#{pane_title}" 2>/dev/null)

  printf '%s\n' "${canvas[@]}" |
    sed -e 's/[[:space:]]*$//' \
        -E -e $'s/[═║╔╗╚╝]+/\033[35m&\033[0m/g' -e $'s/[─│┌┐└┘]+/\033[90m&\033[0m/g'
}

# The panes of one window, one per line - the "what is in here" list that
# choose-tree only gives you after expanding the node.
list_panes() {
  local target=$1 focus=$2
  local pane idx active cmd title path label color mark flag
  while IFS="${TAB}" read -r pane idx active cmd title path; do
    if is_claude "$cmd"; then label=$title; color=$'\033[35m'; else label=$cmd; color=$'\033[0m'; fi
    mark=' '; [ "$pane" = "$focus" ] && mark='▸'
    flag=' '; [ "$active" = 1 ] && flag='*'
    printf '\033[32m%s\033[0m \033[33m%s%s\033[0m %s%s\033[0m \033[90m%s\033[0m\n' \
      "$mark" "$idx" "$flag" "$color" "$(pad "$label" 34)" "$path"
  done < <(tmux list-panes -t "$target" -F \
    "#{pane_id}${TAB}#{pane_index}${TAB}#{pane_active}${TAB}#{pane_current_command}${TAB}#{pane_title}${TAB}#{?#{==:#{pane_current_path},#{HOME}},~,#{b:pane_current_path}}" 2>/dev/null)
}

# One pane, full preview width, with the pane list as a header.
focus_preview() {
  local pane=$1 target=$2 lines=${FZF_PREVIEW_LINES:-40} header
  header=$(list_panes "$target" "$pane")
  if [ -n "$header" ]; then
    printf '%s\n' "$header"
    printf '\033[90m%*s\033[0m\n' "${FZF_PREVIEW_COLUMNS:-60}" '' | tr ' ' '-'
    lines=$((lines - $(printf '%s\n' "$header" | wc -l) - 1))
  fi
  ((lines < 3)) && lines=3
  pane_tail "$pane" "$lines" raw
}

preview() {
  local pane=$1 target=$2 mode panes
  mode=$(cat "$mode_file" 2>/dev/null) || mode=layout
  panes=$(tmux display-message -p -t "$target" '#{window_panes}' 2>/dev/null)

  # a single-pane window has no layout worth drawing
  if [ "$mode" = focus ] || [ "${panes:-1}" -le 1 ] || ! layout_preview "$target" "$pane"; then
    focus_preview "$pane" "$target"
  fi
}

# ---------------------------------------------------------------------- main

case "${1:-}" in
  --list)        list_windows; exit 0 ;;
  --preview)     preview "${2:-}" "${3:-}"; exit 0 ;;
  --toggle-mode) [ "$(cat "$mode_file" 2>/dev/null)" = focus ] && echo layout >"$mode_file" || echo focus >"$mode_file"; exit 0 ;;
esac

command -v fzf >/dev/null 2>&1 || {
  tmux display-message -d 2000 "fzf not found - falling back to choose-tree"
  tmux choose-tree -Zw
  exit 0
}

selection=$(
  list_windows | fzf \
    --ansi \
    --delimiter="${TAB}" \
    --with-nth=3.. \
    --no-sort \
    --reverse \
    --info=inline \
    --pointer='>' \
    --prompt='  window > ' \
    --header=$'enter switch  ·  ctrl-o layout/focus  ·  ctrl-x kill  ·  ctrl-r reload\n' \
    --preview="${self} --preview {2} {1}" \
    --preview-window='right,60%,border-left,nowrap' \
    --bind="ctrl-o:execute-silent(${self} --toggle-mode)+refresh-preview" \
    --bind="ctrl-r:reload(${self} --list)" \
    --bind="ctrl-x:execute-silent(tmux kill-window -t {1})+reload(${self} --list)"
) || exit 0

[ -n "${selection}" ] || exit 0

IFS="${TAB}" read -r target pane _rest <<<"${selection}"
tmux switch-client -t "${target%%:*}"
tmux select-window -t "${target}"
[ -n "${pane}" ] && tmux select-pane -t "${pane}"
