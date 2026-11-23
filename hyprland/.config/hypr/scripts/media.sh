#!/bin/bash
# Media player control (playerctl/MPRIS) for Waybar, the lock screen and shortcuts
# usage: media.sh status        Waybar JSON: play/pause icon, details in the tooltip (hidden without a player)
#        media.sh button prev|next   Waybar JSON for the side buttons (hidden without a player)
#        media.sh menu          fuzzel extras (volume, show window, switch player), opened under the cursor
#        media.sh toggle|next|prev
#        media.sh lock-text     now-playing line for hyprlock (empty when nothing plays)
#        media.sh lock-art      album art path for hyprlock (transparent image when none)

# Chromium/Brave's own MPRIS players duplicate plasma-browser-integration (which has volume + art)
skip='^(chromium|brave|chrome)'
run="${XDG_RUNTIME_DIR:-/tmp}"
chosen="$run/media-player"
art="${XDG_CACHE_HOME:-$HOME/.cache}/media-art"
fz=(fuzzel --dmenu --width 44)

players() { playerctl -l 2>/dev/null | grep -Ev "$skip"; }

# The player switched to in the menu, else the one playing, else the first
player() {
  local p
  p=$(cat "$chosen" 2>/dev/null)
  if [[ -n "$p" ]] && players | grep -qxF "$p"; then
    echo "$p"
    return
  fi
  p=$(playerctl -a metadata -f '{{playerName}} {{status}}' 2>/dev/null |
    awk -v skip="$skip" '$2 == "Playing" && $1 !~ skip { print $1; exit }')
  [[ -n "$p" ]] || p=$(players | head -1)
  echo "$p"
}

pc() { playerctl -p "$P" "$@" 2>/dev/null; }

refresh_bar() { pkill -RTMIN+17 waybar; }

label() { [[ "$1" == plasma-browser-integration ]] && echo Browser || echo "${1%%.*}"; }

clock() { # seconds -> m:ss or h:mm:ss
  local s=${1%.*}
  ((s >= 3600)) && printf '%d:%02d:%02d' $((s / 3600)) $((s % 3600 / 60)) $((s % 60)) ||
    printf '%d:%02d' $((s / 60)) $((s % 60))
}

esc() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

status() {
  local st title artist album pos len line icon tip
  if [[ -z "$P" ]]; then
    echo '{"text": ""}'
    return
  fi
  st=$(pc status)
  IFS=$'\x1f' read -r title artist album len < <(pc metadata -f $'{{xesam:title}}\x1f{{xesam:artist}}\x1f{{xesam:album}}\x1f{{mpris:length}}')
  pos=$(pc position)
  [[ "$st" == Playing ]] && icon=󰏤 || icon=󰐊
  tip="${title:-Unknown}"
  [[ -n "$artist" ]] && tip+=$'\n'"$artist"
  [[ -n "$album" ]] && tip+=$'\n'"Album: $album"
  line="$(label "$P") · $st"
  [[ -n "$pos" ]] && line+="  $(clock "$pos")"
  [[ "$len" =~ ^[0-9]+$ ]] && ((len > 0)) && line+=" / $(clock $((len / 1000000)))"
  tip+=$'\n'"$line"
  jq -cn --arg text "$icon" --arg tip "$(esc <<<"$tip")" --arg class "${st,,}" \
    '{text: $text, tooltip: $tip, class: $class}'
}

button() { # prev|next
  if [[ -z "$P" ]]; then
    echo '{"text": ""}'
  elif [[ "$1" == prev ]]; then
    echo '{"text": "󰒮", "tooltip": "Previous track"}'
  else
    echo '{"text": "󰒭", "tooltip": "Next track"}'
  fi
}

# fuzzel placed just under the bar, centered on the mouse pointer
near_cursor() { # width-in-chars
  local cx cy mx my mname
  read -r cx cy < <(hyprctl cursorpos -j | jq -r '"\(.x|floor) \(.y|floor)"')
  read -r mname mx my < <(hyprctl monitors -j | jq -r --argjson x "$cx" --argjson y "$cy" \
    '.[] | select($x >= .x and $x < .x + .width and $y >= .y and $y < .y + .height) | "\(.name) \(.x) \(.y)"')
  local w=$(($1 * 9 + 40))
  local left=$((cx - mx - w / 2))
  ((left < 4)) && left=4
  echo "--output=$mname --anchor=top-left --x-margin=$left --y-margin=44"
}

focus_player() {
  local pid
  pid=$(pc metadata kde:pid)
  if [[ -n "$pid" ]]; then
    hyprctl dispatch "hl.dsp.focus({ window = 'pid:$pid' })" >/dev/null
  else
    hyprctl dispatch "hl.dsp.focus({ window = 'class:(?i).*${P%%.*}.*' })" >/dev/null
  fi
}

menu() {
  local rows=() others choice
  [[ -n "$P" ]] || { notify-send -a media "No media player running"; return; }
  rows+=("󰝝  Volume +5%" "󰝞  Volume −5%" "󰖯  Show player window")
  while read -r others; do
    [[ -n "$others" && "$others" != "$P" ]] && rows+=("󰓃  Switch player: $others")
  done < <(players)
  # shellcheck disable=SC2046
  choice=$(printf '%s\n' "${rows[@]}" | fuzzel --dmenu --width 30 $(near_cursor 30) \
    --prompt "$(label "$P") ❯ " --lines ${#rows[@]}) || return
  case "$choice" in
  *"Volume +5%") "$(dirname "$0")/player-volume.sh" + ;;
  *"Volume −5%") "$(dirname "$0")/player-volume.sh" - ;;
  *"Show player window") focus_player ;;
  *"Switch player: "*) echo "${choice#*Switch player: }" >"$chosen" ;;
  esac
  sleep 0.2
  refresh_bar
}

lock_text() {
  local st title artist icon text
  [[ -n "$P" ]] || return
  st=$(pc status)
  [[ "$st" == Playing || "$st" == Paused ]] || return
  IFS=$'\x1f' read -r title artist < <(pc metadata -f $'{{xesam:title}}\x1f{{xesam:artist}}')
  [[ "$st" == Playing ]] && icon=󰏤 || icon=󰐊
  text="$title"
  [[ -n "$artist" ]] && text+="  ·  $artist"
  ((${#text} > 70)) && text="${text:0:69}…"
  echo "$icon  $text" | esc
  echo "<span size='small' alpha='60%'>Super+Alt+,  󰒮     Super+Alt+Space  󰏤     Super+Alt+.  󰒭</span>"
}

# Cached 96x96 cover; re-made only when the art URL changes
lock_art() {
  local url src
  mkdir -p "${art%/*}"
  [[ -f "$art-none.png" ]] || magick -size 1x1 xc:none "$art-none.png"
  url=$([[ -n "$P" ]] && pc metadata mpris:artUrl)
  if [[ -z "$url" ]] || ! [[ "$(pc status)" =~ ^(Playing|Paused)$ ]]; then
    echo "$art-none.png"
    return
  fi
  if [[ "$url" != "$(cat "$art.url" 2>/dev/null)" || ! -f "$art.png" ]]; then
    case "$url" in
    file://*) src=${url#file://} ;;
    http*://*) src="$art.download" && curl -fsSL --max-time 5 -o "$src" "$url" || src="" ;;
    esac
    if [[ -n "$src" ]] && magick "$src" -resize 96x96^ -gravity center -extent 96x96 "$art.png" 2>/dev/null; then
      echo "$url" >"$art.url"
    else
      echo "$art-none.png"
      return
    fi
  fi
  echo "$art.png"
}

P=$(player)
case "${1:-status}" in
status) status ;;
button) button "$2" ;;
menu) menu ;;
toggle) pc play-pause; refresh_bar ;;
next) pc next; refresh_bar ;;
prev) pc previous; refresh_bar ;;
lock-text) lock_text ;;
lock-art) lock_art ;;
*) echo "usage: $0 [status|button prev|next|menu|toggle|next|prev|lock-text|lock-art]" >&2; exit 1 ;;
esac
