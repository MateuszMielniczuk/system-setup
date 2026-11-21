#!/bin/bash

choice=$(printf '%s\n' \
  "󰌾  Lock" \
  "󰍃  Logout" \
  "󰤄  Suspend" \
  "󰋊  Hibernate" \
  "󰜉  Reboot" \
  "󰐥  Shutdown" |
  fuzzel --dmenu --prompt "Power ❯ " --lines 6 --width 20)

case "$choice" in
*Lock) pidof hyprlock || hyprlock ;;
*Logout) command -v hyprshutdown >/dev/null && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()' ;;
*Suspend) systemctl suspend-then-hibernate ;;
*Hibernate) systemctl hibernate ;;
*Reboot) systemctl reboot ;;
*Shutdown) systemctl poweroff ;;
esac
