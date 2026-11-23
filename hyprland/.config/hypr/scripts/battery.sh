#!/bin/bash
# Battery panel (Waybar battery click): status, health, charge limit and power profile.
# usage: battery.sh              open the panel
#        battery.sh limit        toggle the charge limit 80% <-> full (admin password via polkit)
bat=/sys/class/power_supply/BAT0

read_bat() { cat "$bat/$1" 2>/dev/null; }

toggle_limit() {
  if (($(read_bat charge_control_end_threshold) < 100)); then
    # Full: raise the end first so start never exceeds it
    pkexec sh -c "echo 100 > $bat/charge_control_end_threshold && echo 0 > $bat/charge_control_start_threshold" &&
      notify-send -a battery -i battery-full "Charge limit off" "Charging to 100%"
  else
    # 80%: charging stops at 80 and restarts below 75, so it doesn't top up all day
    pkexec sh -c "echo 80 > $bat/charge_control_end_threshold && echo 75 > $bat/charge_control_start_threshold" &&
      notify-send -a battery -i battery-good "Charge limit on" "Charging stops at 80%"
  fi
}

panel() {
  local cap status now full design power cycles end time msg profile choice
  cap=$(read_bat capacity) status=$(read_bat status) now=$(read_bat energy_now) full=$(read_bat energy_full)
  design=$(read_bat energy_full_design) power=$(read_bat power_now) cycles=$(read_bat cycle_count)
  end=$(read_bat charge_control_end_threshold)
  time=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk -F': *' '/time to (empty|full)/ { print $2; exit }')
  profile=$(powerprofilesctl get)

  msg="<b>$cap%</b>  ·  $status${time:+  ·  ${time/,/.} ${status/Discharging/left}}"
  msg="${msg/ Charging/ to full}"
  msg+=$'\n'"$(awk -v p="$power" -v f="$full" -v d="$design" -v c="$cycles" 'BEGIN {
    printf "Power draw %.1f W  ·  Health %d%% (%.1f of %.1f Wh)\n%d charge cycles", p / 1e6, f / d * 100 + 0.5, f / 1e6, d / 1e6, c }')"

  local limit_row
  if ((end < 100)); then
    limit_row="󰂃  Charge limit: on (stops at $end%)"
  else
    limit_row="󰁹  Charge limit: off (charges to 100%)"
  fi
  choice=$(printf '%s\n' "$limit_row" "󰾅  Power profile: $profile" |
    "$(dirname "$0")/menu.sh" --prompt Battery --width 60 --lines 2 --message "$msg") || return
  case "$choice" in
  *"Charge limit"*) toggle_limit && panel ;;
  *"Power profile"*)
    case "$profile" in
    power-saver) powerprofilesctl set balanced ;;
    balanced) powerprofilesctl set performance ;;
    *) powerprofilesctl set power-saver ;;
    esac
    panel
    ;;
  esac
}

case "${1:-panel}" in
panel) panel ;;
limit) toggle_limit ;;
*) echo "usage: $0 [panel|limit]" >&2; exit 1 ;;
esac
