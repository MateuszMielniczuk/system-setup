#!/usr/bin/env bash
set -euo pipefail

settings="$HOME/.config/zed/settings.json"

if grep -q '"format_on_save": "on"' "$settings"; then
  sed -i 's/"format_on_save": "on"/"format_on_save": "off"/' "$settings"
  state="off"
else
  sed -i 's/"format_on_save": "off"/"format_on_save": "on"/' "$settings"
  state="on"
fi

notify-send "Zed" "format_on_save: $state" 2>/dev/null || true
