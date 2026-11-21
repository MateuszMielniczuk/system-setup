#!/bin/bash
# usage: screenshot.sh region|window|screen [edit]

source "$(dirname "$0")/region.sh"

dir="$(xdg-user-dir PICTURES)/Screenshots"
file="$dir/Screenshot_$(date +%Y%m%d_%H%M%S).png"
mkdir -p "$dir"

tmp=$(mktemp --suffix=.png)
trap 'rm -f "$tmp"' EXIT

case "$1" in
region) capture_region "$tmp" || exit 0 ;;
window) grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$tmp" || exit 1 ;;
screen) grim -o "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')" "$tmp" || exit 1 ;;
*) echo "usage: $0 region|window|screen [edit]" >&2; exit 1 ;;
esac

if [[ "$2" == "edit" ]]; then
  # GDK_BACKEND=x11: GTK's Wayland EGL fails here ("No EGL configuration available")
  GDK_BACKEND=x11 satty --filename "$tmp" --output-filename "$file" --copy-command wl-copy --early-exit
  exit 0
fi

cp "$tmp" "$file" || exit 1
wl-copy <"$file"
notify-send -i "$file" "Screenshot" "Saved and copied: $(basename "$file")"
