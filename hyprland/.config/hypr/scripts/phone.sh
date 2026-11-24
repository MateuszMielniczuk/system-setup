#!/bin/bash
# KDE Connect: Waybar status (battery of the reachable phone) and a rofi panel
# usage: phone.sh status   Waybar JSON, hidden when no device is reachable (signal 18)
#        phone.sh          panel: ring, send file/clipboard, browse files, settings
dev=/modules/kdeconnect/devices

prop() { qdbus6 org.kde.kdeconnect "$dev/$1$2" "$3" 2>/dev/null; } # id subpath property

# Reachable paired devices: "id name", phones first
reachable() {
  kdeconnect-cli -a --id-name-only 2>/dev/null | while read -r id name; do
    printf '%s %s %s\n' "$([[ $(prop "$id" "" org.kde.kdeconnect.device.type) == phone ]] && echo 0 || echo 1)" "$id" "$name"
  done | sort | cut -d' ' -f2-
}

# "82% · charging" (empty without the battery plugin)
battery() {
  local charge
  charge=$(prop "$1" /battery org.kde.kdeconnect.device.battery.charge) || return
  [[ "$charge" =~ ^[0-9]+$ ]] || return
  echo -n "$charge%"
  [[ $(prop "$1" /battery org.kde.kdeconnect.device.battery.isCharging) == true ]] && echo -n " · charging"
  echo
}

status() {
  local id name bat
  read -r id name < <(reachable | head -1)
  if [[ -z "$id" ]]; then
    echo '{"text": ""}'
    return
  fi
  bat=$(battery "$id")
  jq -cn --arg text "󰄜${bat:+ ${bat%% ·*}}" --arg tip "$name${bat:+ · $bat}"$'\n'"Click: phone panel" \
    '{text: $text, tooltip: $tip}'
}

panel() {
  local devices id name bat choice file menu="$(dirname "$0")/menu.sh"
  mapfile -t devices < <(reachable)
  if ((${#devices[@]} == 0)); then
    notify-send -a phone -i kdeconnect "No phone connected" "Open KDE Connect on the phone, same Wi-Fi"
    return
  fi
  read -r id name <<<"${devices[0]}"
  if ((${#devices[@]} > 1)); then
    choice=$(printf '%s\n' "${devices[@]#* }" | "$menu" --prompt Device --width 40 --lines ${#devices[@]} --index) || return
    read -r id name <<<"${devices[choice]}"
  fi
  bat=$(battery "$id")
  choice=$(printf '%s\n' "󰀦  Ring (find it)" "󰈔  Send file…" "󰅍  Send clipboard text" \
    "󰉋  Browse files" "󰒓  KDE Connect settings" |
    "$menu" --prompt "$name" --width 44 --lines 5 --message "$name${bat:+ · $bat}") || return
  case "$choice" in
  *Ring*) kdeconnect-cli -d "$id" --ring ;;
  *"Send file"*)
    file=$(kdialog --getopenfilename "$HOME" 2>/dev/null) || return
    kdeconnect-cli -d "$id" --share "$file" && notify-send -a phone -i kdeconnect "Sent to $name" "${file##*/}"
    ;;
  *clipboard*)
    kdeconnect-cli -d "$id" --share-text "$(wl-paste --no-newline 2>/dev/null)" &&
      notify-send -a phone -i kdeconnect "Clipboard sent to $name"
    ;;
  *"Browse files"*) qdbus6 org.kde.kdeconnect "$dev/$id/sftp" org.kde.kdeconnect.device.sftp.startBrowsing >/dev/null ;;
  *settings*) kdeconnect-app ;;
  esac
}

case "${1:-panel}" in
status) status ;;
panel) panel ;;
*) echo "usage: $0 [status|panel]" >&2; exit 1 ;;
esac
