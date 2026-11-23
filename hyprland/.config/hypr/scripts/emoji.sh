#!/bin/bash
# Emoji picker: types the chosen emoji into the focused window and copies it.
# emoji.txt was generated from Python's Unicode database (single-codepoint emoji).

data="$(dirname "$0")/emoji.txt"
choice=$("$(dirname "$0")/menu.sh" --prompt "Emoji" --width 45 --lines 12 <"$data") || exit 0
emoji="${choice%% *}"

printf '%s' "$emoji" | wl-copy
sleep 0.15 # let the menu give keyboard focus back to the window
wtype "$emoji"
