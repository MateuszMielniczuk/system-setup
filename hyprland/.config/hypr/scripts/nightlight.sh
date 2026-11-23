#!/bin/bash
# Night light: hyprsunset runs all the time and follows hyprsunset.conf (20:00-7:00).
# usage: nightlight.sh          toggle now (lasts until the next scheduled switch)
#        nightlight.sh status   prints on/off

temp() { hyprctl hyprsunset temperature 2>/dev/null | grep -Eo '^[0-9]+'; }
is_on() { t=$(temp) && [[ -n "$t" ]] && ((t < 6000)); }

if [[ "$1" == status ]]; then
  is_on && echo on || echo off
  exit 0
fi

if ! pgrep -x hyprsunset >/dev/null; then
  setsid -f hyprsunset >/dev/null 2>&1
  sleep 0.5
fi
if is_on; then
  hyprctl hyprsunset temperature 6500 >/dev/null # neutral (identity would keep reporting 4000)
else
  hyprctl hyprsunset temperature 4000 >/dev/null
fi
pkill -RTMIN+8 waybar
