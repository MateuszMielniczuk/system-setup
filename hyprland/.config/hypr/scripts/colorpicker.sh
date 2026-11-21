#!/bin/bash
# Pick a color anywhere on screen; copies the hex code and shows it with a swatch

color=$(hyprpicker -b -f hex 2>/dev/null)
[[ "$color" =~ ^#[0-9a-fA-F]{6}$ ]] || exit 0

printf '%s' "$color" | wl-copy

swatch="${XDG_RUNTIME_DIR:-/tmp}/colorpicker-swatch.png"
magick -size 64x64 "xc:$color" "$swatch" 2>/dev/null
notify-send -a colorpicker -i "$swatch" "Color copied" "$color"
