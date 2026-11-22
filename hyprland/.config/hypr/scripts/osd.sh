#!/bin/bash
# On-screen popup for volume, mic and brightness keys (styled by [app-name=osd] in mako)
# usage: osd.sh volume up|down|mute | mic mute | brightness up|down
# Brightness follows the focused monitor: laptop backlight, external monitors via DDC/CI.

laptop=eDP-1
run="${XDG_RUNTIME_DIR:-/tmp}"

# External monitor: "<connector> <i2c bus> <model>" from ddcutil detect, cached (detect is slow)
ddc_info() {
  local map="$run/ddc-monitors"
  grep -q "^$1 " "$map" 2>/dev/null ||
    ddcutil detect --brief 2>/dev/null | awk '
      /I2C bus:/       { bus = $NF; sub("/dev/i2c-", "", bus) }
      /DRM connector:/ { conn = $NF; sub(/^card[0-9]+-/, "", conn) }
      /Monitor:/       { n = split($0, m, ":"); print conn, bus, m[n-1] }' >"$map"
  awk -v c="$1" '$1 == c { $1 = ""; sub(/^ /, ""); print }' "$map"
}

# Remember the level (refreshed from the monitor after 60 s) so each key press is instant;
# one background writer sends only the latest value, since each DDC write takes ~0.2 s
ddc_step() { # bus, +5/-5 -> prints new level
  local bus=$1 level="$run/ddc-$1.level" target="$run/ddc-$1.target" cur new
  # Key repeat runs several copies at once: update the level one at a time
  exec 8>"$run/ddc-$1.state"
  flock 8
  if [[ -f "$level" ]] && (($(date +%s) - $(stat -c %Y "$level") < 60)); then
    cur=$(<"$level")
  else
    cur=$(ddcutil --bus "$bus" getvcp 10 --brief 2>/dev/null | awk '{ print $4 }')
  fi
  [[ "$cur" =~ ^[0-9]+$ ]] || return 1
  new=$((cur + $2))
  ((new > 100)) && new=100
  ((new < 0)) && new=0
  echo "$new" >"$level"
  echo "$new" >"$target"
  flock -u 8
  # Single writer: keeps sending the latest target; re-checks before exiting so a
  # value written while it was finishing isn't lost
  (
    flock -n 9 || exit 0
    sent=""
    while :; do
      v=$(<"$target")
      if [[ "$v" == "$sent" ]]; then
        sleep 0.15
        v=$(<"$target")
        [[ "$v" == "$sent" ]] && break
      fi
      ddcutil --bus "$bus" --noverify setvcp 10 "$v" >/dev/null 2>&1
      sent=$v
    done
  ) 9>"$run/ddc-$1.lock" &
  echo "$new"
}

monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

case "$1 $2" in
"volume up") wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
"volume down") wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
"volume mute") wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
"mic mute") wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
"brightness up" | "brightness down")
  if [[ "$monitor" == "$laptop" || -z "$monitor" ]]; then
    [[ "$2" == up ]] && brightnessctl -q -e4 -n2 set 5%+ || brightnessctl -q -e4 -n2 set 5%-
  fi
  ;;
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
  icon="$icons/actions/22/brightness-high.svg"
  if [[ "$monitor" == "$laptop" || -z "$monitor" ]]; then
    pct=$(brightnessctl -m | cut -d, -f4 | tr -d %)
    show "$icon" "Brightness" "Laptop: $pct%" "$pct"
  else
    read -r bus model < <(ddc_info "$monitor")
    step=5
    [[ "$2" == down ]] && step=-5
    if [[ -n "$bus" ]] && pct=$(ddc_step "$bus" "$step"); then
      show "$icon" "Brightness" "${model:-$monitor}: $pct%" "$pct"
    else
      show "$icon" "Brightness" "$monitor: DDC/CI not available"
    fi
  fi
  ;;
esac
