#!/bin/bash
# usage: record.sh region|screen   (run again to stop)

if pgrep -x wf-recorder >/dev/null; then
  pkill -INT -x wf-recorder
  sleep 0.5
  pkill -RTMIN+9 waybar
  notify-send "Recording" "Saved to $(xdg-user-dir VIDEOS)/Recordings"
  exit 0
fi

dir="$(xdg-user-dir VIDEOS)/Recordings"
file="$dir/Recording_$(date +%Y%m%d_%H%M%S).mp4"
mkdir -p "$dir"

if [[ "$1" == "region" ]]; then
  geom=$(slurp) || exit 0
  target=(-g "$geom")
else
  target=(-o "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')")
fi

setsid -f wf-recorder "${target[@]}" -f "$file" >/dev/null 2>&1
sleep 0.5
pkill -RTMIN+9 waybar
