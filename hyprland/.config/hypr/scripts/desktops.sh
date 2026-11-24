#!/bin/bash
# Waybar desktop grid (2x2). Refreshed by signal 13 from workspaces.lua.
# Desktop = workspace id % 10 (see workspaces.lua).

colors="$HOME/.config/waybar/colors.css"
color() { sed -n "s/^@define-color $1 *\(#[0-9a-fA-F]*\);/\1/p" "$colors"; }
accent=$(color accent)
base=$(color base)
text=$(color text)
dim=$(color surface2)

current=$(hyprctl activeworkspace -j | jq '.id % 10')
occupied=" $(hyprctl workspaces -j | jq -r '[.[] | select(.windows > 0 and .id > 0) | .id % 10] | unique | join(" ")') "

cell() {
  if [[ "$1" == "$current" ]]; then
    printf "<span background='%s' foreground='%s'><b> %s </b></span>" "$accent" "$base" "$1"
  elif [[ "$occupied" == *" $1 "* ]]; then
    printf "<span foreground='%s'> %s </span>" "$text" "$1"
  else
    printf "<span foreground='%s'> %s </span>" "$dim" "$1"
  fi
}

printf '{"text": "<span line_height=\\"0.9\\">%s%s\\n%s%s</span>", "tooltip": "Desktop %s"}\n' \
  "$(cell 1)" "$(cell 2)" "$(cell 3)" "$(cell 4)" "$current"
