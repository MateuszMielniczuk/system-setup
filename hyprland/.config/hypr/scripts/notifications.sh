#!/bin/bash
# Notification history (mako): Waybar bell and a rofi panel
# usage: notifications.sh          panel (Super+Shift+U / bell click)
#        notifications.sh status   Waybar JSON: bell, lighter when there are new ones (signal 12)
#        notifications.sh dnd      toggle do-not-disturb
seen="${XDG_RUNTIME_DIR:-/tmp}/notifications-seen"
menu() { "$(dirname "$0")/menu.sh" "$@"; }

history() { makoctl history -j 2>/dev/null || echo '[]'; }
dnd_on() { makoctl mode | grep -q do-not-disturb; }

status() {
  local new
  new=$(history | jq --argjson s "$(cat "$seen" 2>/dev/null || echo 0)" '[.[] | select(.id > $s)] | length')
  if dnd_on; then
    jq -cn --arg n "$new" '{text: "󰂛", tooltip: "Do not disturb (\($n) new)\nClick: history · Right click: DND off", class: "dnd"}'
  elif ((new > 0)); then
    jq -cn --arg n "$new" '{text: "󰂚", tooltip: "\($n) new notifications\nClick: history · Right click: do not disturb", class: "new"}'
  else
    jq -cn '{text: "󰂚", tooltip: "No new notifications\nClick: history · Right click: do not disturb", class: "none"}'
  fi
}

# Focus the window of the app that sent it (desktop entry or app name as class)
open_app() { # name
  local addr
  addr=$(hyprctl clients -j | jq -r --arg n "${1,,}" '[.[] | select((.class | ascii_downcase | contains($n)) or (.initialClass | ascii_downcase | contains($n)))][0].address // empty')
  [[ -n "$addr" ]] && hyprctl dispatch "hl.dsp.focus({ window = 'address:$addr' })" >/dev/null
}

details() { # json-of-one, is-latest
  local summary body app choice opts=()
  summary=$(jq -r .summary <<<"$1") body=$(jq -r .body <<<"$1")
  app=$(jq -r '.desktop_entry // .app_name' <<<"$1")
  opts=("󰖯  Open $app" "󰆏  Copy text")
  [[ "$2" == yes ]] && opts+=("󰑐  Show again")
  choice=$(printf '%s\n' "${opts[@]}" | menu --prompt "$app" --width 60 --lines ${#opts[@]} \
    --message "<b>$(jq -r '.summary | gsub("&";"&amp;") | gsub("<";"&lt;")' <<<"$1")</b>
$(jq -r '.body | gsub("&";"&amp;") | gsub("<";"&lt;")' <<<"$1")") || return
  case "$choice" in
  *Open*) open_app "$app" ;;
  *Copy*) printf '%s\n%s' "$summary" "$body" | wl-copy ;;
  *"Show again"*) makoctl restore ;;
  esac
}

panel() {
  local h n rows idx
  h=$(history)
  # Mark everything as seen; the bell goes back to empty
  jq '[.[].id] | max // 0' <<<"$h" >"$seen"
  pkill -RTMIN+12 waybar
  n=$(jq length <<<"$h")
  idx=$({
    printf '󰆴  Clear history\n'
    jq -j '.[] | "\(.app_name) · \(.summary | gsub("\n"; " "))\u0000icon\u001f\(.app_icon // "dialog-information")\n"' <<<"$h"
  } | menu --prompt Notifications --width 70 --lines $((n < 12 ? n + 1 : 12)) --index --icon-size 24) || return
  if ((idx == 0)); then
    pkill -x mako
    hyprctl dispatch "hl.dsp.exec_cmd('mako')" >/dev/null
    echo 0 >"$seen"
  else
    details "$(jq ".[$((idx - 1))]" <<<"$h")" "$( ((idx == 1)) && echo yes || echo no)"
  fi
}

case "${1:-panel}" in
panel) panel ;;
status) status ;;
dnd) makoctl mode -t do-not-disturb >/dev/null; pkill -RTMIN+12 waybar ;;
*) echo "usage: $0 [panel|status|dnd]" >&2; exit 1 ;;
esac
