#!/bin/bash

if pgrep -x hyprsunset >/dev/null; then
  pkill -x hyprsunset
else
  setsid -f hyprsunset -t 4000 >/dev/null 2>&1
fi
sleep 0.2
pkill -RTMIN+8 waybar
