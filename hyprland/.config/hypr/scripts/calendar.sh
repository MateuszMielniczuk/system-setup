#!/bin/bash
# Calendar: fuzzel front-end for calcurse; data (and calcurse's own config) in $SYSTEM_DATA/calendar
# usage: calendar.sh [menu]    upcoming 30 days, add, delete, open calcurse
#        calendar.sh add       prompt for a new event/appointment
#        calendar.sh open      full calcurse in a terminal
#        calendar.sh today     notify today's and tomorrow's items (login + daily at 08:00)
#        calendar.sh start     at login: reminder daemon, daily timer, today's summary
#        calendar.sh remind    called by the calcurse daemon before an appointment

source "$(dirname "$0")/system-data.sh"
dir="$SYSTEM_DATA/calendar"
self="$HOME/.config/hypr/scripts/calendar.sh"
fz=(fuzzel --dmenu --width 56)
mkdir -p "$dir"

cal() { calcurse -D "$dir" "$@"; }

# Reminders for every appointment, 10 minutes ahead, also when calcurse isn't open
configure() {
  local conf="$dir/conf" key value
  touch "$conf"
  while IFS='=' read -r key value; do
    if grep -q "^$key=" "$conf"; then
      sed -i "s|^$key=.*|$key=$value|" "$conf"
    else
      echo "$key=$value" >>"$conf"
    fi
  done <<EOF
daemon.enable=yes
notification.notifyall=all
notification.warning=600
notification.command=$self remind
EOF
}

# "epoch<TAB>hash<TAB>time-or-dash<TAB>text" for the next N days
upcoming() { # days
  cal -Q --from "$(date +%m/%d/%Y)" --days "$1" \
    --format-event '%(hash)\t-\t%m\n' --format-recur-event '%(hash)\t-\t%m\n' \
    --format-apt '%(hash)\t%(start:%H:%M)\t%m\n' --format-recur-apt '%(hash)\t%(start:%H:%M)\t%m\n' |
    while IFS= read -r line; do
      if [[ "$line" =~ ^([0-9]{2}/[0-9]{2}/[0-9]{2}):$ ]]; then
        day=$(date -d "${BASH_REMATCH[1]}" +%s)
      elif [[ -n "$line" ]]; then
        printf '%s\t%s\n' "$day" "$line"
      fi
    done
}

# Date input: 25.12, 25.12.2027, tomorrow, fri, next fri, 2026-12-25 -> YYYYMMDD
parse_date() {
  local d m y
  if [[ "$1" =~ ^([0-9]{1,2})\.([0-9]{1,2})\.?([0-9]{4})?$ ]]; then
    d=${BASH_REMATCH[1]} m=${BASH_REMATCH[2]} y=${BASH_REMATCH[3]:-$(date +%Y)}
    date -d "$y-$m-$d" +%Y%m%d 2>/dev/null
  elif [[ -z "$1" ]]; then
    date +%Y%m%d
  else
    date -d "$1" +%Y%m%d 2>/dev/null
  fi
}

ics_escape() { sed 's/\\/\\\\/g; s/;/\\;/g; s/,/\\,/g' <<<"$1"; }

add() {
  local input day time text repeat start end rrule="" ics
  input=$("${fz[@]}" --prompt "Date ❯ " --lines 0 --placeholder "25.12 · tomorrow · fri · empty = today") || return
  day=$(parse_date "$input") || { notify-send -a calendar -u critical "Unknown date" "$input"; return 1; }
  time=$("${fz[@]}" --prompt "Time ❯ " --lines 0 --placeholder "14:00 · 14:00-15:30 · empty = all day") || return
  text=$("${fz[@]}" --prompt "What ❯ " --lines 0 --placeholder "e.g. Anna's birthday") || return
  [[ -n "$text" ]] || return
  repeat=$(printf 'No repeat\nYearly\nMonthly\nWeekly\nDaily\n' | "${fz[@]}" --prompt "Repeat ❯ " --lines 5) || return
  [[ "$repeat" != "No repeat" ]] && rrule="RRULE:FREQ=${repeat^^}"

  if [[ -z "$time" ]]; then
    start="DTSTART;VALUE=DATE:$day"
    end=""
  elif [[ "$time" =~ ^([0-9]{1,2}):([0-9]{2})(-([0-9]{1,2}):([0-9]{2}))?$ ]]; then
    local h1=${BASH_REMATCH[1]} m1=${BASH_REMATCH[2]} h2=${BASH_REMATCH[4]} m2=${BASH_REMATCH[5]}
    start=$(date -d "$day $h1:$m1" +%Y%m%dT%H%M00 2>/dev/null) || { notify-send -a calendar -u critical "Unknown time" "$time"; return 1; }
    if [[ -n "$h2" ]]; then
      end=$(date -d "$day $h2:$m2" +%Y%m%dT%H%M00 2>/dev/null) || { notify-send -a calendar -u critical "Unknown time" "$time"; return 1; }
    else
      end=$(date -d "$day $h1:$m1 1 hour" +%Y%m%dT%H%M00)
    fi
    start="DTSTART:$start" end="DTEND:$end"
  else
    notify-send -a calendar -u critical "Unknown time" "$time"
    return 1
  fi

  ics=$(mktemp --suffix .ics)
  printf '%s\r\n' BEGIN:VCALENDAR VERSION:2.0 BEGIN:VEVENT "$start" $end $rrule \
    "SUMMARY:$(ics_escape "$text")" END:VEVENT END:VCALENDAR | sed '/^\r$/d' >"$ics"
  if cal -i "$ics" >/dev/null 2>&1; then
    notify-send -a calendar -i office-calendar "Added to calendar" \
      "$(date -d "$day" '+%a %d %b')${time:+ $time}: $text${rrule:+ ($repeat)}"
  else
    notify-send -a calendar -u critical "Not added" "$text"
  fi
  rm -f "$ics"
}

open() {
  exec kitty --class calendar -e calcurse -D "$dir"
}

menu() {
  local rows=() hashes=() day hash time text idx label
  while IFS=$'\t' read -r day hash time text; do
    label="$(date -d "@$day" '+%a %d %b')  "
    [[ "$time" == - ]] && label+="󰃭      " || label+="$time  "
    rows+=("$label$text")
    hashes+=("$hash")
  done < <(upcoming 30)
  idx=$(printf '%s\n' "󰐕  Add" "󰸗  Open calendar (calcurse)" "${rows[@]}" |
    "${fz[@]}" --prompt "Calendar ❯ " --lines 14 --index) || return
  case "$idx" in
  0) add ;;
  1) open ;;
  *)
    label=${rows[idx - 2]}
    [[ $(printf '󰆴  Delete (all repeats)\n' | "${fz[@]}" --prompt "$label ❯ " --lines 1) ]] || return
    cal -P --filter-hash "${hashes[idx - 2]}" && notify-send -a calendar "Deleted" "$label"
    ;;
  esac
}

today() {
  local items="" now tomorrow day _ time text
  now=$(date -d "today 00:00" +%s)
  tomorrow=$(date -d "tomorrow 00:00" +%s)
  while IFS=$'\t' read -r day _ time text; do
    [[ "$time" == - ]] && time="" || time="$time "
    if ((day == now)); then
      items+="Today: $time$text"$'\n'
    elif ((day == tomorrow)); then
      items+="Tomorrow: $time$text"$'\n'
    fi
  done < <(upcoming 2)
  [[ -n "$items" ]] && notify-send -a calendar -i office-calendar -t 15000 "Calendar" "${items%$'\n'}"
}

remind() {
  local next
  next=$(cal -n 2>/dev/null | sed -n '2p' | sed 's/^ *//')
  [[ -n "$next" ]] && notify-send -a calendar -u critical -i office-calendar "Upcoming" "$next"
}

start() {
  configure
  cal --daemon
  # Hyprland-only daily summary; already exists if Hyprland was restarted
  systemd-run --user --quiet --unit=calendar-today --on-calendar='*-*-* 08:00:00' \
    "$self" today 2>/dev/null
  today
}

case "${1:-menu}" in
menu) menu ;;
add) add ;;
open) open ;;
today) today ;;
start) start ;;
remind) remind ;;
*) echo "usage: $0 [menu|add|open|today|start|remind]" >&2; exit 1 ;;
esac
