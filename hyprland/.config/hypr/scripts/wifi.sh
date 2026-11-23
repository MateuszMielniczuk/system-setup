#!/bin/bash
# Wi-Fi menu (rofi + nmcli): connect, disconnect/forget, toggle radio, rescan
# usage: wifi.sh [rescan]

menu() { # prompt lines [menu.sh args...]
  "$(dirname "$0")/menu.sh" --prompt "$1" --width 44 --lines "$2" "${@:3}"
}

note() { notify-send -a wifi -i network-wireless "$@"; }

signal_icon() {
  if (($1 >= 75)); then echo 󰤨; elif (($1 >= 50)); then echo 󰤥; elif (($1 >= 25)); then echo 󰤢; else echo 󰤟; fi
}

# Saved profile for an SSID (profile names don't always match the SSID)
profile_for() {
  local name
  while IFS=: read -r name type; do
    [[ "$type" == 802-11-wireless ]] || continue
    [[ "$(nmcli -g 802-11-wireless.ssid con show "$name" 2>/dev/null)" == "$1" ]] && echo "$name" && return
  done < <(nmcli -t -f NAME,TYPE con show)
}

connect() { # ssid security
  local ssid=$1 profile pass out rc
  profile=$(profile_for "$ssid")
  if [[ -n "$profile" ]]; then
    out=$(nmcli con up id "$profile" 2>&1)
    rc=$?
  elif [[ -n "$2" ]]; then
    pass=$(menu "Password for $ssid" 0 --password) || return
    out=$(nmcli dev wifi connect "$ssid" password "$pass" 2>&1)
    rc=$?
    # A failed attempt leaves a profile with the wrong password behind
    ((rc != 0)) && nmcli con delete id "$ssid" >/dev/null 2>&1
  else
    out=$(nmcli dev wifi connect "$ssid" 2>&1)
    rc=$?
  fi
  if ((rc == 0)); then
    note "Connected" "$ssid"
  else
    note -u critical "Failed to connect to $ssid" "${out#Error: }"
  fi
}

connected_menu() { # ssid
  local choice profile
  choice=$(printf '󰖪  Disconnect\n󰆴  Forget\n' | menu "$1" 2) || return
  profile=$(profile_for "$1")
  case "$choice" in
  *Disconnect) nmcli con down id "$profile" >/dev/null && note "Disconnected" "$1" ;;
  *Forget) nmcli con delete id "$profile" >/dev/null && note "Forgot network" "$1" ;;
  esac
}

if [[ "$1" == rescan ]]; then
  nmcli dev wifi rescan 2>/dev/null
  sleep 2
fi

if [[ "$(nmcli radio wifi)" != enabled ]]; then
  choice=$(printf '󰤨  Turn Wi-Fi on\n󰈀  Advanced (nm-connection-editor)\n' | menu Wi-Fi 2) || exit 0
  case "$choice" in
  *"Turn Wi-Fi on") nmcli radio wifi on && note "Wi-Fi on" ;;
  *Advanced*) nm-connection-editor ;;
  esac
  exit 0
fi

# One row per SSID: connected first, then by signal; hidden networks skipped
rows=() ssids=() secs=() active=""
declare -A seen
while IFS=$'\t' read -r inuse signal sec ssid; do
  [[ -z "$ssid" || -n "${seen[$ssid]}" ]] && continue
  seen[$ssid]=1
  lock=" "
  [[ -n "$sec" && "$sec" != "--" ]] && lock=󰌾
  row="$(signal_icon "$signal") $lock $ssid"
  [[ "$inuse" == "*" ]] && row+="  ✓" && active=$ssid
  rows+=("$row") ssids+=("$ssid") secs+=("${sec/--/}")
done < <(nmcli -t --escape no -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan no |
  awk -F: '{ s = $4; for (i = 5; i <= NF; i++) s = s ":" $i; print $1 "\t" $2 "\t" $3 "\t" s }' |
  sort -t$'\t' -k1,1r -k2,2nr)

head=("󰖪  Turn Wi-Fi off" "󰑐  Rescan")
tail=("󰈀  Advanced (nm-connection-editor)")
n=$((${#head[@]} + ${#rows[@]} + ${#tail[@]}))
((n > 14)) && n=14

idx=$(printf '%s\n' "${head[@]}" "${rows[@]}" "${tail[@]}" | menu Wi-Fi "$n" --index) || exit 0

case "$idx" in
0) nmcli radio wifi off && note "Wi-Fi off" ;;
1) exec "$0" rescan ;;
*)
  i=$((idx - ${#head[@]}))
  if ((i >= ${#rows[@]})); then
    nm-connection-editor
  elif [[ "${ssids[i]}" == "$active" ]]; then
    connected_menu "$active"
  else
    connect "${ssids[i]}" "${secs[i]}"
  fi
  ;;
esac
