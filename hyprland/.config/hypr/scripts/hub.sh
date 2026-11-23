#!/bin/bash
# Settings hub
# usage: hub.sh [keys|wallpaper|audio|mic|display|profile]

scripts="$HOME/.config/hypr/scripts"
state="${XDG_STATE_HOME:-$HOME/.local/state}/theme/current"
laptop="eDP-1"

menu() {
  "$scripts/menu.sh" --prompt "$1" --width "${2:-40}" --lines "${3:-16}" "${@:4}"
}

signal_bar() {
  pkill -RTMIN+"$1" waybar
}

# --- pages -------------------------------------------------------------------

# Descriptions are "[Group] text" or "[Group|key label] text" (see keybinds.lua);
# sections keep the order in which they first appear
keys() {
  {
    hyprctl binds -j | jq -r '
      def name: {"Return":"Enter","Escape":"Esc","slash":"/","grave":"`","equal":"=","minus":"-","period":".",
                 "mouse:272":"Left drag","mouse:273":"Right drag",
                 "mouse_up":"Wheel up","mouse_down":"Wheel down"}[.] // .;
      [ .[] | select(.description != "") |
        (.description | capture("^\\[(?<group>[^]|]*)(\\|(?<label>[^]]*))?\\] (?<text>.*)$")
          // {group: "Other", label: null, text: .}) as $d |
        { group: $d.group, text: $d.text,
          keys: ($d.label // ([ (if .modmask % 128 >= 64 then "Super" else empty end),
                                (if .modmask % 8   >= 4  then "Ctrl"  else empty end),
                                (if .modmask % 16  >= 8  then "Alt"   else empty end),
                                (if .modmask % 2   >= 1  then "Shift" else empty end),
                                (.key | name) ] | join(" + "))) } ] |
      (reduce .[].group as $g ([]; if index([$g]) then . else . + [$g] end)) as $order |
      to_entries | sort_by(.value.group as $g | [($order | index([$g])), .key]) | .[].value |
      "\(.group)\t\(.keys)\t\(.text)"'
    printf '%s\t%s\t%s\n' \
      Gestures "3 fingers ← →" "Desktop right / left" \
      Gestures "3 fingers ↑ ↓" "Desktop below / above" \
      Gestures "4 fingers ↑" "Window to the screen above" \
      Gestures "4 fingers ↓" "Window to the screen below" \
      Gestures "4-finger pinch in / out" "Fullscreen / normal"
  } | column -t -s $'\t' | menu Keys 92 22 >/dev/null
}

wallpaper() {
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-thumbs" dirs files thumb i
  mkdir -p "$cache"
  # shellcheck disable=SC1090
  dirs=("$(source "$HOME/.config/hypr/themes/$(cat "$state").sh" && echo "$wallpapers")")
  # -uw files are the ultrawide versions of another wallpaper: not listed on their own
  mapfile -t files < <(find "${dirs[@]}" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) ! -iname '*-uw.*' 2>/dev/null | sort -u)
  [[ ${#files[@]} -gt 0 ]] || { notify-send "Wallpaper" "No images found"; return; }

  for f in "${files[@]}"; do
    thumb="$cache/$(echo -n "$f" | md5sum | cut -d' ' -f1).png"
    [[ -f "$thumb" ]] || ffmpeg -loglevel error -y -i "$f" -vf scale=256:-1 -frames:v 1 "$thumb" &
  done
  wait

  i=$(for f in "${files[@]}"; do
    printf '%s\0icon\x1f%s\n' "$(basename "${f%.*}")" "$cache/$(echo -n "$f" | md5sum | cut -d' ' -f1).png"
  done | menu Wallpaper 60 5 --icon-size 64 --index) || return
  "$scripts/theme.sh" wallpaper "${files[$i]}"
}

audio() {
  local kind=$1 default names i
  default=$(pactl "get-default-${kind%s}")
  mapfile -t names < <(pactl -f json list "$kind" | jq -r '
    .[] | select(.name | endswith(".monitor") | not)
        | select(.active_port as $p | [.ports[]? | select(.name == $p) | .availability] | first != "not available")
        | .name')
  i=$(for n in "${names[@]}"; do
    desc=$(pactl -f json list "$kind" | jq -r --arg n "$n" '.[] | select(.name == $n) | .description' | sed 's/.*(HD Audio) //')
    [[ "$n" == "$default" ]] && echo "● $desc" || echo "   $desc"
  done | menu "${kind^}" 50 8 --index) || return
  pactl "set-default-${kind%s}" "${names[$i]}"
}

profile() {
  local current choice
  current=$(powerprofilesctl get)
  choice=$(powerprofilesctl list | sed -n 's/^[* ] \([a-z-]*\):$/\1/p' |
    menu Power 30 3 --select "$current") || return
  powerprofilesctl set "$choice"
}

display() {
  local ext choice
  ext=$(hyprctl monitors all -j | jq -r --arg l "$laptop" '[.[] | select(.name != $l)][0].name // empty')
  [[ -n "$ext" ]] || { notify-send "Displays" "No external monitor"; return; }
  choice=$(printf '%s\n' "Extend (default)" "Mirror laptop" "External only" "Laptop only" | menu Displays 30 4) || return
  case "$choice" in
  Extend*) hyprctl reload ;;
  Mirror*) hyprctl eval "hl.monitor({ output = '$ext', mode = 'preferred', position = 'auto', scale = 1, mirror = '$laptop' })" ;;
  External*) hyprctl eval "hl.monitor({ output = '$laptop', disabled = true })" ;;
  Laptop*) hyprctl eval "hl.monitor({ output = '$ext', disabled = true })" ;;
  esac
}

# --- toggles -----------------------------------------------------------------

dnd_on() { makoctl mode | grep -q do-not-disturb; }
awake_on() { ! pgrep -x hypridle >/dev/null; }
night_on() { [[ $("$scripts/nightlight.sh" status) == on ]]; }
state_of() { "$1" && echo on || echo off; }

toggle_dnd() {
  makoctl mode -t do-not-disturb >/dev/null
  signal_bar 12
}

toggle_awake() {
  if awake_on; then setsid -f hypridle >/dev/null 2>&1; else pkill -x hypridle; fi
  sleep 0.2
  signal_bar 11
}

visual_profile() {
  local choice
  choice=$(printf '%s\n' normal battery performance |
    menu Profile 30 3 --select "$("$scripts/profile.sh" get)") || return
  "$scripts/profile.sh" "$choice"
}

# --- main --------------------------------------------------------------------

main() {
  local external=""
  [[ $(hyprctl monitors all -j | jq length) -gt 1 ]] && external="󰍹  Displays"$'\n'

  choice=$(printf '%s' \
    "󰌌  Keybindings
󰸉  Wallpaper
󰑓  Wallpaper rotation: $("$scripts/theme.sh" rotation status)
󰊄  Extract text (OCR)
󰈋  Color picker
󰞅  Emoji
󰖟  Web apps
󰀠  Alarms
󰃭  Calendar
󰖐  Clocks & weather
󰒓  Default apps
󰁯  Backup & restore
󰏘  Theme
󰂛  Do not disturb: $(state_of dnd_on)
󰅶  Keep awake: $(state_of awake_on)
󰖔  Night light: $(state_of night_on)
󰾅  Power profile: $(powerprofilesctl get)
󰊗  Profile: $("$scripts/profile.sh" get)
󰓃  Audio output
󰍬  Microphone
${external}󰤨  Wi-Fi
󰂯  Bluetooth
󰕾  Sound mixer
󰐥  Power menu" | menu Settings 34 23) || exit 0

  case "$choice" in
  *Keybindings) keys ;;
  *Wallpaper) wallpaper ;;
  *"Wallpaper rotation"*)
    if [[ $("$scripts/theme.sh" rotation status) == on ]]; then
      "$scripts/theme.sh" rotation off && notify-send "Wallpaper rotation" "off"
    else
      "$scripts/theme.sh" rotation on && notify-send "Wallpaper rotation" "on: a new wallpaper every hour"
    fi
    ;;
  *"Extract text (OCR)") sleep 0.2 && "$scripts/ocr.sh" text ;;
  *"Color picker") sleep 0.2 && "$scripts/colorpicker.sh" ;;
  *Emoji) "$scripts/emoji.sh" ;;
  *"Web apps") "$scripts/webapp.sh" ;;
  *Alarms) "$scripts/alarm.sh" ;;
  *Calendar) "$scripts/calendar.sh" ;;
  *"Clocks & weather") "$scripts/weather.sh" ;;
  *"Default apps") "$scripts/defaults.sh" ;;
  *"Backup & restore") "$scripts/backup.sh" ;;
  *Theme) "$scripts/theme.sh" ;;
  *"Do not disturb"*) toggle_dnd ;;
  *"Keep awake"*) toggle_awake ;;
  *"Night light"*) "$scripts/nightlight.sh" ;;
  *"Power profile"*) profile ;;
  *"Profile: "*) visual_profile ;;
  *"Audio output") audio sinks ;;
  *Microphone) audio sources ;;
  *Displays) display ;;
  *Wi-Fi) "$scripts/wifi.sh" ;;
  *Bluetooth) "$scripts/bluetooth.sh" ;;
  *"Sound mixer") pavucontrol ;;
  *"Power menu") "$scripts/powermenu.sh" ;;
  esac
}

case "${1:-}" in
keys) keys ;;
wallpaper) wallpaper ;;
audio) audio sinks ;;
mic) audio sources ;;
display) display ;;
profile) profile ;;
*) main ;;
esac
