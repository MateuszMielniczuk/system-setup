#!/bin/bash
# On-screen popup for volume, mic and brightness keys (styled by [app-name=osd] in mako)
# usage: osd.sh volume up|down|mute | mic mute | brightness up|down

case "$1 $2" in
"volume up") wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
"volume down") wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
"volume mute") wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
"mic mute") wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
"brightness up") brightnessctl -q -e4 -n2 set 5%+ ;;
"brightness down") brightnessctl -q -e4 -n2 set 5%- ;;
*)
  echo "usage: $0 volume up|down|mute | mic mute | brightness up|down" >&2
  exit 1
  ;;
esac

# Breeze icons matching the theme's dark/light variant
theme="${XDG_STATE_HOME:-$HOME/.local/state}/theme/current"
variant=$(sed -n 's/^variant=//p' "$HOME/.config/hypr/themes/$(cat "$theme" 2>/dev/null).sh" 2>/dev/null)
icons=/usr/share/icons/breeze-dark
[[ "$variant" == light ]] && icons=/usr/share/icons/breeze

show() { # icon title body [percent]
  notify-send -a osd -t 1500 -i "$1" -h string:x-canonical-private-synchronous:osd \
    ${4:+-h "int:value:$4"} "$2" "$3"
}

case "$1" in
volume)
  read -r _ level muted < <(wpctl get-volume @DEFAULT_AUDIO_SINK@)
  pct=$(awk -v v="$level" 'BEGIN { printf "%d", v * 100 + 0.5 }')
  if [[ -n "$muted" ]]; then
    show "$icons/status/22/audio-volume-muted.svg" "Volume" "Muted" 0
  else
    icon=high
    ((pct < 67)) && icon=medium
    ((pct < 34)) && icon=low
    show "$icons/status/22/audio-volume-$icon.svg" "Volume" "$pct%" "$pct"
  fi
  ;;
mic)
  if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
    show "$icons/status/22/microphone-sensitivity-muted.svg" "Microphone" "Muted"
  else
    show "$icons/status/22/microphone-sensitivity-high.svg" "Microphone" "On"
  fi
  ;;
brightness)
  pct=$(brightnessctl -m | cut -d, -f4 | tr -d %)
  show "$icons/actions/22/brightness-high.svg" "Brightness" "$pct%" "$pct"
  ;;
esac
