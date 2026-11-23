#!/bin/bash
# Bluetooth menu (rofi + bluetoothctl): connect/disconnect/forget, scan and pair, power
# usage: bluetooth.sh
menu() { "$(dirname "$0")/menu.sh" --prompt "$1" --width 48 --lines "$2" "${@:3}"; }
note() { notify-send -a bluetooth -i bluetooth "$@"; }

icon_for() { # bluetoothctl Icon value
  case "$1" in
  audio-headset | audio-headphones) echo 󰋋 ;;
  audio-card | audio-speakers) echo 󰓃 ;;
  input-mouse) echo 󰍽 ;;
  input-keyboard) echo 󰌌 ;;
  input-gaming) echo 󰊗 ;;
  phone) echo 󰄜 ;;
  computer) echo 󰍹 ;;
  *) echo 󰂯 ;;
  esac
}

# "mac<TAB>row" for each device, connected first
rows() { # Paired|"" (all known)
  bluetoothctl devices $1 | while read -r _ mac name; do
    local info icon conn bat
    info=$(bluetoothctl info "$mac")
    icon=$(icon_for "$(awk -F': ' '/Icon:/ { print $2; exit }' <<<"$info")")
    conn=$(grep -q 'Connected: yes' <<<"$info" && echo connected || echo paired)
    bat=$(sed -n 's/.*Battery Percentage: .*(\([0-9]*\)).*/\1/p' <<<"$info" | head -1)
    printf '%s\t%s\t%s  %-24s %s\n' "$([[ $conn == connected ]] && echo 0 || echo 1)" "$mac" "$icon" "$name" "$conn${bat:+ · $bat%}"
  done | sort | cut -f2-
}

connect() { # mac name
  if bluetoothctl connect "$1" >/dev/null 2>&1; then note "Connected" "$2"; else note -u critical "Couldn't connect" "$2"; fi
}

device_menu() { # mac name
  local choice
  choice=$(printf '󰂲  Disconnect\n󰆴  Forget\n' | menu "$2" 2) || return
  case "$choice" in
  *Disconnect) bluetoothctl disconnect "$1" >/dev/null && note "Disconnected" "$2" ;;
  *Forget) bluetoothctl remove "$1" >/dev/null && note "Forgot device" "$2" ;;
  esac
}

scan() {
  local before list macs=() names=() idx mac name
  note -t 8000 "Scanning…" "Put the device in pairing mode"
  before=$(bluetoothctl devices Paired | awk '{ print $2 }')
  bluetoothctl --timeout 8 scan on >/dev/null 2>&1
  while read -r _ mac name; do
    grep -qxF "$mac" <<<"$before" && continue
    [[ "$name" == "${mac//:/-}" ]] && continue # unnamed devices
    macs+=("$mac") names+=("$name")
  done < <(bluetoothctl devices)
  if ((${#macs[@]} == 0)); then
    note "No new devices found"
    return
  fi
  idx=$(printf '󰂰  %s\n' "${names[@]}" | menu "Pair" "${#names[@]}" --index) || return
  mac=${macs[idx]} name=${names[idx]}
  if bluetoothctl pair "$mac" >/dev/null 2>&1 && bluetoothctl trust "$mac" >/dev/null 2>&1; then
    connect "$mac" "$name"
  else
    note -u critical "Pairing failed" "$name"
  fi
}

if bluetoothctl show | grep -q 'Powered: no'; then
  choice=$(printf '󰂯  Turn Bluetooth on\n󰒓  Bluetooth settings (Plasma)\n' | menu Bluetooth 2) || exit 0
  case "$choice" in
  *"Turn Bluetooth on") bluetoothctl power on >/dev/null && note "Bluetooth on" ;;
  *settings*) kcmshell6 kcm_bluetooth ;;
  esac
  exit 0
fi

mapfile -t devices < <(rows Paired)
head=("󰂲  Turn Bluetooth off" "󰂰  Scan for new devices")
n=$((${#devices[@]} + 3))
((n > 14)) && n=14
idx=$(printf '%s\n' "${head[@]}" "${devices[@]#*$'\t'}" "󰒓  Bluetooth settings (Plasma)" | menu Bluetooth "$n" --index) || exit 0
case "$idx" in
0) bluetoothctl power off >/dev/null && note "Bluetooth off" ;;
1) scan ;;
*)
  i=$((idx - 2))
  if ((i >= ${#devices[@]})); then
    kcmshell6 kcm_bluetooth
  else
    mac=${devices[i]%%$'\t'*}
    row=${devices[i]#*$'\t'}
    name=$(bluetoothctl info "$mac" | awk -F': ' '/Name:/ { print $2; exit }')
    if [[ "$row" == *connected* ]]; then device_menu "$mac" "$name"; else connect "$mac" "$name"; fi
  fi
  ;;
esac
