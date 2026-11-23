#!/bin/bash
# Shared menu for all scripts: rofi -dmenu as a plain list. Reads entries on stdin,
# prints the choice (or its index with --index).
# options: --prompt TEXT  --width CHARS  --lines N  --index  --password  --placeholder TEXT
#          --select TEXT  --icon-size PX  --message TEXT

args=(-dmenu -i)
theme="mode-switcher { enabled: false; } listview { columns: 1; fixed-height: false; }"
width=40 prompt=""

while (($#)); do
  case "$1" in
  --prompt) prompt=$2 && shift ;;
  --width) width=$2 && shift ;;
  --lines) [[ "$2" == 0 ]] && theme+=" listview { enabled: false; }" || args+=(-l "$2"); shift ;;
  --index) args+=(-format i) ;;
  --password) args+=(-password) ;;
  --placeholder) theme+=" entry { placeholder: \"${2//\"/\\\"}\"; }" && shift ;;
  --select) args+=(-select "$2") && shift ;;
  --icon-size) theme+=" element-icon { size: ${2}px; }" && shift ;;
  --message) args+=(-mesg "$2") && shift ;;
  esac
  shift
done

if [[ -n "$prompt" ]]; then
  args+=(-p "$prompt")
else
  theme+=" prompt { enabled: false; } textbox-prompt-colon { enabled: false; }"
fi
# Width in characters of the font; +6 covers the window padding
theme+=" window { width: $((width + 6))ch; }"

exec rofi "${args[@]}" -theme-str "$theme"
