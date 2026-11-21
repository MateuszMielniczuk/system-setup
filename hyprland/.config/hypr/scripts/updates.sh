#!/bin/bash
# Waybar update counter, signal 14 refreshes it
# usage: updates.sh          print Waybar JSON (hidden when up to date or offline)
#        updates.sh upgrade  run a full upgrade in a terminal (cachy-update or yay), then refresh

# CachyOS: cachy-update (lists repo/AUR/Flatpak, upgrade adds news and post-update checks);
# elsewhere: checkupdates + yay
has_cachy() { command -v cachy-update >/dev/null; }

list_updates() {
  if has_cachy; then
    cachy-update -l 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk '$3 == "->" { print $1, $2, "→", $4 }'
  else
    # checkupdates syncs a temporary db copy: no root, no partial-upgrade risk
    { checkupdates; yay -Qua; } 2>/dev/null | sed 's/ -> / → /'
  fi
}

compute() {
  local all n class tip
  all=$(list_updates | sed '/^[[:space:]]*$/d')
  n=$(grep -c . <<<"$all")
  if ((n == 0)); then
    echo '{"text": ""}'
    return
  fi
  class=normal
  ((n >= 50)) && class=many
  tip=$(head -20 <<<"$all")
  ((n > 20)) && tip+=$'\n'"…and $((n - 20)) more"
  tip=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' <<<"$tip")
  jq -cn --arg text "󰏗 $n" --arg tip "$tip" --arg class "$class" \
    '{text: $text, tooltip: $tip, class: $class}'
}

case "${1:-check}" in
upgrade)
  has_cachy && cmd=cachy-update || cmd=yay
  kitty --class updates -e bash -c "$cmd; echo; read -rp 'Done. Press Enter to close...'"
  pkill -RTMIN+14 waybar
  ;;
check)
  # Each bar (one per monitor) runs this at the same time, and parallel checkupdates
  # runs fail on its db lock: take turns and reuse a result younger than 15 s
  cache="${XDG_RUNTIME_DIR:-/tmp}/waybar-updates.json"
  exec 9>"$cache.lock"
  flock 9
  if [[ -f "$cache" ]] && (($(date +%s) - $(stat -c %Y "$cache") < 15)); then
    cat "$cache"
  else
    compute | tee "$cache"
  fi
  ;;
esac
