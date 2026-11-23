#!/bin/bash
# Media player control (playerctl/MPRIS) for Waybar, the lock screen and shortcuts
# usage: media.sh status        Waybar JSON: play/pause icon, details in the tooltip (hidden without a player)
#        media.sh menu          controls popup (cover, title, buttons) under the pointer
#        media.sh toggle|next|prev
#        media.sh lock-text     now-playing line for hyprlock (empty when nothing plays)
#        media.sh lock-art      album art path for hyprlock (transparent image when none)

# Chromium/Brave's own MPRIS players duplicate plasma-browser-integration (which has volume + art)
skip='^(chromium|brave|chrome)'
chosen="${XDG_RUNTIME_DIR:-/tmp}/media-player"
art="${XDG_CACHE_HOME:-$HOME/.cache}/media-art"

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

esc() { # Pango markup escape
  local t=${1//&/&amp;}
  t=${t//</&lt;}
  printf '%s' "${t//>/&gt;}"
}

play_icon() { [[ "$1" == Playing ]] && echo 󰏤 || echo 󰐊; }

# Current track in one playerctl call: sets st title artist album and line
# ("Browser · Playing  2:17 / 1:26:12")
now_playing() {
  local pos len
  IFS=$'\x1f' read -r st title artist album len pos < <(pc metadata -f \
    $'{{status}}\x1f{{xesam:title}}\x1f{{xesam:artist}}\x1f{{xesam:album}}\x1f{{mpris:length}}\x1f{{position}}')
  line="$(label "$P") · $st"
  [[ "$pos" =~ ^[0-9]+$ ]] && line+="  $(clock $((pos / 1000000)))"
  [[ "$len" =~ ^[0-9]+$ ]] && ((len > 0)) && line+=" / $(clock $((len / 1000000)))"
}

status() {
  local st title artist album line tip
  if [[ -z "$P" ]]; then
    echo '{"text": ""}'
    return
  fi
  now_playing
  tip="${title:-Unknown}"
  [[ -n "$artist" ]] && tip+=$'\n'"$artist"
  [[ -n "$album" ]] && tip+=$'\n'"Album: $album"
  tip+=$'\n'"$line"
  jq -cn --arg text "$(play_icon "$st")" --arg tip "$(esc "$tip")" --arg class "${st,,}" \
    '{text: $text, tooltip: $tip, class: $class}'
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

# Controls popup: rofi script mode, so the window stays open while buttons are clicked;
# rofi re-runs "media.sh rofi" after each click to act and redraw. Esc / click outside closes.
menu() {
  local st title artist album line cover style="" width=620 cx cy mon mx
  [[ -n "$P" ]] || { notify-send -a media "No media player running"; return; }
  now_playing
  cover=$(art_file 300)
  if [[ -n "$cover" ]]; then
    style="imagebox { background-image: url(\"$cover\", height); }"
  else
    width=470
    style="imagebox { enabled: false; } window { width: ${width}px; }"
  fi
  # Just under the bar, centered on the pointer (620 px wide with a cover, as in media.rasi)
  read -r cx cy < <(hyprctl cursorpos -j | jq -r '"\(.x|floor) \(.y|floor)"')
  read -r mon mx < <(hyprctl monitors -j | jq -r --argjson x "$cx" --argjson y "$cy" \
    '.[] | select($x >= .x and $x < .x + .width and $y >= .y and $y < .y + .height) | "\(.name) \(.x)"')
  # The redraws reuse this instead of looking up the cover again
  MEDIA_TITLE_MAX=$([[ -n "$cover" ]] && echo 38 || echo 50) \
    rofi -show media -modi "media:$0 rofi" -theme ~/.config/rofi/media.rasi -m "$mon" -selected-row 1 \
    -theme-str "inputbar { enabled: false; } $style window { location: north west; anchor: north west; x-offset: $((cx - mx - width / 2))px; y-offset: 44px; }"
  refresh_bar
}

# rofi script mode: ROFI_RETV=0 first draw, 1 an entry was picked (ROFI_INFO = action)
rofi_mode() {
  local st title artist album line max=${MEDIA_TITLE_MAX:-50} others nl=$'\u2028'
  if [[ "${ROFI_RETV:-0}" == 1 ]]; then
    case "$ROFI_INFO" in
    prev) pc previous && sleep 0.25 ;; # let the player update before redrawing
    toggle) pc play-pause && sleep 0.25 ;;
    next) pc next && sleep 0.25 ;;
    voldown) "$(dirname "$0")/player-volume.sh" - ;;
    volup) "$(dirname "$0")/player-volume.sh" + ;;
    window) focus_player && exit 0 ;; # no entries printed: rofi closes
    player:*) echo "${ROFI_INFO#player:}" >"$chosen" && P=$(player) ;;
    esac
    refresh_bar
  fi
  now_playing
  ((${#title} > max)) && title="${title:0:max-1}…"

  # One output line per entry, so the message's line breaks are U+2028 (Pango line separator)
  printf '\0message\x1f%s\n' "<b>$(esc "${title:-Unknown}")</b>${artist:+$nl$(esc "$artist")}$nl<span size='small' alpha='60%'>$(esc "$line")</span>"
  printf '\0keep-selection\x1ftrue\n\0no-custom\x1ftrue\n'
  printf '%s\0info\x1f%s\n' "󰒮" prev "$(play_icon "$st")" toggle "󰒭" next \
    "󰝞" voldown "󰝝" volup "󰖯" window
  while read -r others; do
    [[ -n "$others" && "$others" != "$P" ]] && printf '%s\0info\x1f%s\n' "󰓃" "player:$others"
  done < <(players)
  return 0
}

lock_text() {
  local st title artist album line text
  [[ -n "$P" ]] || return
  now_playing
  [[ "$st" == Playing || "$st" == Paused ]] || return
  text="$title"
  [[ -n "$artist" ]] && text+="  ·  $artist"
  ((${#text} > 70)) && text="${text:0:69}…"
  echo "$(play_icon "$st")  $(esc "$text")"
  echo "<span size='small' alpha='60%'>Super+Alt+,  󰒮     Super+Alt+Space  󰏤     Super+Alt+.  󰒭</span>"
}

# Cover of the current track at SIZE px (cached, re-made when the art URL changes);
# prints nothing when there is no cover. Needs now_playing first ($st).
art_file() { # size
  local size=$1 url src out="$art-$1.png"
  [[ "$st" == Playing || "$st" == Paused ]] || return
  url=$(pc metadata mpris:artUrl)
  [[ -n "$url" ]] || return
  if [[ "$url" != "$(cat "$out.url" 2>/dev/null)" || ! -f "$out" ]]; then
    case "$url" in
    file://*) src=${url#file://} ;;
    http*://*) src="$art.download" && { curl -fsSL --max-time 5 -o "$src" "$url" || src=""; } ;;
    esac
    mkdir -p "${art%/*}"
    [[ -n "$src" ]] && magick "$src" -resize "${size}x${size}^" -gravity center -extent "${size}x${size}" "$out" 2>/dev/null || return
    echo "$url" >"$out.url"
  fi
  echo "$out"
}

lock_art() {
  local st title artist album line f
  [[ -f "$art-none.png" ]] || { mkdir -p "${art%/*}" && magick -size 1x1 xc:none "$art-none.png"; }
  [[ -n "$P" ]] && now_playing && f=$(art_file 96)
  echo "${f:-$art-none.png}"
}

P=$(player)
case "${1:-status}" in
status) status ;;
rofi) rofi_mode ;;
menu) menu ;;
toggle) pc play-pause; refresh_bar ;;
next) pc next; refresh_bar ;;
prev) pc previous; refresh_bar ;;
lock-text) lock_text ;;
lock-art) lock_art ;;
*) echo "usage: $0 [status|menu|toggle|next|prev|lock-text|lock-art]" >&2; exit 1 ;;
esac
