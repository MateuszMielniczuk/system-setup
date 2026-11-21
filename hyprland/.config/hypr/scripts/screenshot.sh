#!/bin/bash
# usage: screenshot.sh region|window|screen [edit]

dir="$(xdg-user-dir PICTURES)/Screenshots"
file="$dir/Screenshot_$(date +%Y%m%d_%H%M%S).png"
mkdir -p "$dir"

case "$1" in
region) target=(-g "$(slurp)") || exit 0 ;;
window) target=(-g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')") ;;
screen) target=(-o "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')") ;;
*) echo "usage: $0 region|window|screen [edit]" >&2; exit 1 ;;
esac

if [[ "$2" == "edit" ]]; then
  # GDK_BACKEND=x11: GTK's Wayland EGL fails here ("No EGL configuration available")
  grim "${target[@]}" - | GDK_BACKEND=x11 satty --filename - --output-filename "$file" --copy-command wl-copy --early-exit
  exit 0
fi

grim "${target[@]}" "$file" || exit 1
wl-copy <"$file"
notify-send -i "$file" "Screenshot" "Saved and copied: $(basename "$file")"
