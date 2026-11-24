#!/bin/bash
# Notes panel (Super+N): nvim in the synced notes folder, shown on special:notes
source "$(dirname "$0")/system-data.sh"
dir="$SYSTEM_DATA/notes"
mkdir -p "$dir"
cd "$dir" && exec kitty --class notes -e nvim notes.md
