#!/bin/bash
# Where a popup of WIDTH px opens: just under the bar, centered on the pointer.
# Prints "MONITOR LEFT" (x offset in px on that monitor)
# usage: read -r mon left < <(popup-pos.sh WIDTH)
width=$1
read -r cx cy < <(hyprctl cursorpos -j | jq -r '"\(.x|floor) \(.y|floor)"')
read -r mon mx < <(hyprctl monitors -j | jq -r --argjson x "$cx" --argjson y "$cy" \
  '.[] | select($x >= .x and $x < .x + .width and $y >= .y and $y < .y + .height) | "\(.name) \(.x)"')
left=$((cx - mx - width / 2))
((left < 8)) && left=8
echo "$mon $left"
