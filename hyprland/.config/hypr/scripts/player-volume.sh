#!/bin/bash
# usage: player-volume.sh +|-   change the media player's volume by 5%
# Chromium/Brave's own MPRIS players ignore volume; their tabs are reachable
# through plasma-browser-integration, so those are skipped.

skip='^(chromium|brave|chrome)'

pick() {
  local p
  p=$(playerctl -a metadata -f '{{playerName}} {{status}}' 2>/dev/null |
    awk -v skip="$skip" '$2 == "Playing" && $1 !~ skip { print $1; exit }')
  [[ -n "$p" ]] || p=$(playerctl -l 2>/dev/null | grep -Ev "$skip" | head -1)
  echo "$p"
}

player=$(pick)
[[ -n "$player" ]] || exit 0

playerctl -p "$player" volume "0.05$1"
level=$(playerctl -p "$player" volume | awk '{ printf "%d", $1 * 100 + 0.5 }')
notify-send -t 1500 -h "int:value:$level" -h string:x-canonical-private-synchronous:player-volume \
  "Player volume" "$player: $level%"
