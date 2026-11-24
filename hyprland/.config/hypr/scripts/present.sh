#!/bin/bash
# Presentation mode: do-not-disturb, keep awake, neutral colors (no night light tint).
# Turns on by itself while the screen is shared (modules/present.lua); restores everything after.
# usage: present.sh [toggle]       manual on/off
#        present.sh auto on|off    from the screen-share event (only undoes its own "on")
#        present.sh status         Waybar JSON (signal 19)
state="${XDG_RUNTIME_DIR:-/tmp}/present-state" # "auto dnd_was awake_was temp_was" while active

refresh() { for s in 8 11 12 19; do pkill -RTMIN+$s waybar; done; }

on() { # auto=0|1
  [[ -f "$state" ]] && return
  local dnd=0 awake=0 temp
  makoctl mode | grep -q do-not-disturb && dnd=1
  pgrep -x hypridle >/dev/null && awake=1
  temp=$(hyprctl hyprsunset temperature 2>/dev/null | grep -Eo '^[0-9]+')
  echo "$1 $dnd $awake ${temp:-6500}" >"$state"
  makoctl mode -a do-not-disturb >/dev/null
  pkill -x hypridle
  hyprctl hyprsunset temperature 6500 >/dev/null 2>&1
  refresh
}

off() {
  [[ -f "$state" ]] || return
  local auto dnd awake temp
  read -r auto dnd awake temp <"$state"
  rm -f "$state"
  ((dnd)) || makoctl mode -r do-not-disturb >/dev/null
  ((awake)) && hyprctl dispatch "hl.dsp.exec_cmd('hypridle > ~/.cache/hypridle.log 2>&1')" >/dev/null
  hyprctl hyprsunset temperature "$temp" >/dev/null 2>&1
  refresh
}

case "${1:-toggle}" in
toggle) if [[ -f "$state" ]]; then off; else on 0; fi ;;
auto)
  if [[ "$2" == on ]]; then
    on 1
  elif [[ -f "$state" ]] && [[ $(cut -d' ' -f1 "$state") == 1 ]]; then
    off # only end what the screen share started
  fi
  ;;
status)
  if [[ -f "$state" ]]; then
    echo '{"text": "󰐯 Presenting", "tooltip": "Presentation mode: do not disturb, keep awake, no night light\nClick to end", "class": "on"}'
  else
    echo '{"text": ""}'
  fi
  ;;
*) echo "usage: $0 [toggle|auto on|off|status]" >&2; exit 1 ;;
esac
