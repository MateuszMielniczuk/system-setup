#!/bin/bash
# Audio popup: default output/input and per-app volume. rofi script mode, so it stays open.
# Enter: make default (devices) / mute (apps).  Left/Right: volume -/+ 5%.  Esc: close.
# usage: audio.sh          open the popup
#        audio.sh rofi     script mode (called by rofi)

bar() { # percent -> ▰▰▰▱▱▱▱▱▱▱
  local n=$((($1 + 5) / 10)) out="" i
  ((n > 10)) && n=10
  for ((i = 0; i < 10; i++)); do ((i < n)) && out+=▰ || out+=▱; done
  echo "$out"
}

# Devices that exist now (unplugged HDMI ports are hidden): "name<TAB>label<TAB>volume<TAB>muted"
devices() { # sinks|sources
  pactl -f json list "$1" | jq -r '.[]
    | select(.properties["device.class"] != "monitor")
    | .active_port as $a | select(([.ports[] | select(.name == $a)][0].availability // "") != "not available")
    | [.name, (.properties["node.nick"] // .description), (.volume | to_entries[0].value.value_percent | rtrimstr("%")), .mute] | @tsv' 2>/dev/null
}

render() {
  local sink src name label vol mute mark icon line
  sink=$(pactl get-default-sink) src=$(pactl get-default-source)
  read -r vol mute < <(pactl -f json list sinks | jq -r --arg s "$sink" '.[] | select(.name == $s) | "\(.volume | to_entries[0].value.value_percent | rtrimstr("%")) \(.mute)"')
  line="$(pactl -f json list sinks | jq -r --arg s "$sink" '.[] | select(.name == $s) | .properties["node.nick"] // .description')"
  if [[ "$mute" == true ]]; then line+="  ·  muted"; else line+="  ·  $vol%  $(bar "$vol")"; fi
  printf '\0message\x1f%s\n' "<b>$line</b>"$' '"<span size='small' alpha='60%'>←/→ volume  ·  Enter select / mute  ·  Esc close</span>"
  printf '\0keep-selection\x1ftrue\n\0no-custom\x1ftrue\n\0markup-rows\x1ftrue\n\0use-hot-keys\x1ftrue\n' # hot keys: Left/Right

  printf '%s\0nonselectable\x1ftrue\n' "<span size='small' alpha='60%'>OUTPUT</span>"
  while IFS=$'\t' read -r name label vol mute; do
    [[ "$name" == "$sink" ]] && mark="✓" || mark=" "
    [[ "$name" == bluez* ]] && icon=󰋋 || { [[ "$label" == HDMI* ]] && icon=󰡁 || icon=󰓃; }
    printf '%s  %s  %-26s %s\0info\x1fsink:%s\n' "$mark" "$icon" "$label" "$([[ $mute == true ]] && echo muted || echo "$vol%")" "$name"
  done < <(devices sinks)

  printf '%s\0nonselectable\x1ftrue\n' "<span size='small' alpha='60%'>INPUT</span>"
  while IFS=$'\t' read -r name label vol mute; do
    [[ "$name" == "$src" ]] && mark="✓" || mark=" "
    printf '%s  󰍬  %-26s %s\0info\x1fsource:%s\n' "$mark" "$label" "$([[ $mute == true ]] && echo muted || echo "$vol%")" "$name"
  done < <(devices sources)

  local apps
  apps=$(pactl -f json list sink-inputs | jq -r '.[] | [.index, (.properties["application.name"] // .properties["application.process.binary"] // "App"),
    (.volume | to_entries[0].value.value_percent | rtrimstr("%")), .mute] | @tsv')
  if [[ -n "$apps" ]]; then
    printf '%s\0nonselectable\x1ftrue\n' "<span size='small' alpha='60%'>APPS</span>"
    while IFS=$'\t' read -r name label vol mute; do
      printf '   󰎆  %-26s %s\0info\x1fapp:%s\n' "$label" "$([[ $mute == true ]] && echo muted || echo "$vol%")" "$name"
    done <<<"$apps"
  fi
  printf '󰒓  Advanced mixer (pavucontrol)\0info\x1fmixer\n'
}

act() { # retv info
  local kind=${2%%:*} id=${2#*:} step
  case "$1" in
  10) step=-5% ;; # Left
  11) step=+5% ;; # Right
  esac
  case "$kind" in
  sink)
    if [[ -n "$step" ]]; then
      pactl set-sink-volume "$id" "$step"
      [[ "$id" == "$(pactl get-default-sink)" ]] && "$(dirname "$0")/volume-sound.sh"
    else
      pactl set-default-sink "$id"
      # Move what's playing to the new output
      pactl -f json list sink-inputs | jq -r '.[].index' | xargs -r -I{} pactl move-sink-input {} "$id"
    fi
    ;;
  source)
    if [[ -n "$step" ]]; then pactl set-source-volume "$id" "$step"; else pactl set-default-source "$id"; fi
    ;;
  app)
    if [[ -n "$step" ]]; then pactl set-sink-input-volume "$id" "$step"; else pactl set-sink-input-mute "$id" toggle; fi
    ;;
  mixer)
    setsid -f pavucontrol >/dev/null 2>&1
    exit 0 # no entries: rofi closes
    ;;
  esac
}

if [[ "$1" == rofi ]]; then
  [[ "${ROFI_RETV:-0}" =~ ^(1|10|11)$ ]] && act "$ROFI_RETV" "$ROFI_INFO"
  render
  exit 0
fi

read -r mon left < <("$(dirname "$0")/popup-pos.sh" 480)
rofi -show audio -modi "audio:$0 rofi" -theme ~/.config/rofi/audio.rasi -m "$mon" \
  -kb-move-char-back "Control+b" -kb-move-char-forward "Control+f" -kb-custom-1 Left -kb-custom-2 Right \
  -selected-row 1 \
  -theme-str "inputbar { enabled: false; } window { location: north west; anchor: north west; x-offset: ${left}px; y-offset: 44px; }"
