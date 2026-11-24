#!/bin/bash
# Alarms and timers as transient systemd user timers (survive session restarts, not reboots).
# usage: alarm.sh [menu]           menu page: new alarm, pending alarms (pick to cancel)
#        alarm.sh new              prompt for a new alarm
#        alarm.sh WHEN [LABEL]     WHEN: 25m, 1h30m, 90s, 45 (minutes), 07:30
#        alarm.sh status           Waybar JSON (signal 15)
#        alarm.sh ring LABEL SET   called by the timer

sound=/usr/share/sounds/ocean/stereo/alarm-clock-elapsed.oga
[[ -f "$sound" ]] || sound=/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
fz=("$(dirname "$0")/menu.sh" --width 44)

refresh() { pkill -RTMIN+15 waybar; }

left() { # seconds -> "1h 05m" / "12m" / "40s"
  local s=$1
  if ((s >= 3600)); then printf '%dh %02dm' $((s / 3600)) $((s % 3600 / 60))
  elif ((s >= 60)); then printf '%dm' $(((s + 59) / 60))
  else printf '%ds' "$s"; fi
}

# Pending alarms: "epoch<TAB>unit<TAB>label", soonest first
pending() {
  local unit
  systemctl --user list-units --type=timer --state=active --plain --no-legend 'alarm-*' |
    awk '{ print $1 }' | while read -r unit; do
      printf '%s\t%s\t%s\n' "$(cut -d- -f2 <<<"$unit")" "$unit" \
        "$(systemctl --user show -p Description --value "$unit")"
    done | sort -n
}

schedule() { # epoch label
  local unit="alarm-$1-$RANDOM"
  # A clock time (not a countdown) so time spent suspended counts; rings on wake if missed
  systemd-run --user --quiet --collect --unit="$unit" --description="$2" \
    --on-calendar="$(date -d "@$1" '+%F %T')" --timer-property=AccuracySec=1s \
    "$HOME/.config/hypr/scripts/alarm.sh" ring "$2" "$(date +%s)" || return 1
  refresh
}

set_alarm() { # when [label...]
  local when=$1 label="${*:2}" now target h m s
  now=$(date +%s)
  if [[ "$when" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
    target=$(date -d "$when" +%s 2>/dev/null) || return 1
    ((target <= now)) && target=$(date -d "tomorrow $when" +%s)
  elif [[ "$when" =~ ^[0-9]+$ ]]; then
    target=$((now + when * 60))
  elif [[ -n "$when" && "$when" =~ ^(([0-9]+)h)?(([0-9]+)m)?(([0-9]+)s)?$ ]]; then
    h=${BASH_REMATCH[2]:-0} m=${BASH_REMATCH[4]:-0} s=${BASH_REMATCH[6]:-0}
    target=$((now + h * 3600 + m * 60 + s))
    ((target > now)) || return 1
  else
    return 1
  fi
  schedule "$target" "${label:-Alarm}" &&
    notify-send -a alarm -i alarm-symbolic "Alarm set for $(date -d "@$target" +%H:%M)" \
      "${label:-Alarm} (in $(left $((target - now))))"
}

new() {
  local input
  input=$("${fz[@]}" --prompt "Alarm" --lines 0 --placeholder "25m tea · 1h30m · 07:30 standup") || return
  # shellcheck disable=SC2086
  set_alarm $input || notify-send -a alarm -u critical "Alarm not set" "Try: 25m tea, 1h30m, 07:30 standup"
}

ring() { # label set-epoch
  local ago action
  ago=$(left $(($(date +%s) - $2)))
  refresh
  (
    end=$((SECONDS + 60))
    while ((SECONDS < end)); do pw-play "$sound" 2>/dev/null || sleep 2; done
  ) &
  local player=$!
  action=$(notify-send --wait -a alarm -u critical -i alarm-symbolic \
    -A snooze="Snooze 5 min" -A dismiss="Dismiss" "󰀠 $1" "Set $ago ago")
  pkill -P "$player"
  kill "$player" 2>/dev/null
  [[ "$action" == snooze ]] && schedule $(($(date +%s) + 300)) "$1"
  return 0
}

menu() {
  local now rows=() units=() epoch unit label idx
  now=$(date +%s)
  while IFS=$'\t' read -r epoch unit label; do
    [[ -z "$unit" ]] && continue
    rows+=("󰀠  $(date -d "@$epoch" +%H:%M)  $label  (in $(left $((epoch - now))))")
    units+=("$unit")
  done < <(pending)
  idx=$(printf '%s\n' "󰐕  New alarm" "${rows[@]}" |
    "${fz[@]}" --prompt "Alarms" --lines $((${#rows[@]} + 1)) --index) || return
  if ((idx == 0)); then
    new
  else
    systemctl --user stop "${units[idx - 1]}" && refresh &&
      notify-send -a alarm "Alarm cancelled" "${rows[idx - 1]#󰀠  }"
  fi
}

status() {
  local now list next n tip
  now=$(date +%s)
  list=$(pending)
  if [[ -z "$list" ]]; then
    echo '{"text": ""}'
    return
  fi
  n=$(wc -l <<<"$list")
  next=$(head -1 <<<"$list" | cut -f1)
  tip=$(while IFS=$'\t' read -r epoch _ label; do
    printf '%s  %s (in %s)\n' "$(date -d "@$epoch" +%H:%M)" "$label" "$(left $((epoch - now)))"
  done <<<"$list" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
  jq -cn --arg text "󰀠 $(date -d "@$next" +%H:%M)$( ((n > 1)) && echo " +$((n - 1))")" \
    --arg tip "$tip" '{text: $text, tooltip: $tip}'
}

case "${1:-menu}" in
menu) menu ;;
new) new ;;
status) status ;;
ring) ring "$2" "$3" ;;
*) set_alarm "$@" || { echo "usage: $0 [menu|new|status] | WHEN [LABEL]" >&2; exit 1; } ;;
esac
