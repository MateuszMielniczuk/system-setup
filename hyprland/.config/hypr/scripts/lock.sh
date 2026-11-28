#!/bin/bash
# Lock the screen unless it is already locked. The marker is set by hypridle's
# on_lock_cmd/on_unlock_cmd (real compositor lock state): a hyprlock that lost its
# lock can hang without a lock surface, so a running process alone proves nothing.
marker="$XDG_RUNTIME_DIR/hypr-locked"
[ -e "$marker" ] && pidof hyprlock >/dev/null && exit 0
pkill -x hyprlock
exec hyprlock
