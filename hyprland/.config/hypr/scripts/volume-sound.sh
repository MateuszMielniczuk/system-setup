#!/bin/bash
# Short "tick" at the new output volume, so you hear how loud it is (like Plasma).
# Holding the key replaces the previous tick instead of overlapping.
snd=/usr/share/sounds/ocean/stereo/audio-volume-change.oga
[[ -f "$snd" ]] || snd=/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga
wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && exit 0
pkill -f "pw-play $snd" 2>/dev/null
setsid -f pw-play "$snd" >/dev/null 2>&1
