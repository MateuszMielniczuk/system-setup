#!/bin/bash
# Text for hyprlock labels
# usage: lockstatus.sh battery|caps

case "$1" in
battery)
  bat=/sys/class/power_supply/BAT0
  [[ -r "$bat/capacity" ]] || exit 0
  pct=$(<"$bat/capacity")
  status=$(<"$bat/status")
  icons=(󰁺 󰁼 󰁾 󰂀 󰁹)
  icon=${icons[$((pct * 5 / 101))]}
  case "$status" in
  Charging) echo "󰂄 $pct%  ·  charging" ;;
  Full | "Not charging") echo "󰚥 $pct%  ·  plugged in" ;;
  *)
    energy=$(<"$bat/energy_now") power=$(<"$bat/power_now")
    if ((power > 0)); then
      mins=$((energy * 60 / power))
      echo "$icon $pct%  ·  $((mins / 60))h $((mins % 60))m left"
    else
      echo "$icon $pct%"
    fi
    ;;
  esac
  ;;
caps)
  hyprctl devices -j 2>/dev/null | jq -e '.keyboards[] | select(.main) | .capsLock' >/dev/null &&
    echo "󰪛  Caps Lock is on"
  ;;
esac
