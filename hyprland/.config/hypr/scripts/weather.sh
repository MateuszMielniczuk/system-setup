#!/bin/bash
# World clock + weather (Open-Meteo, no API key). Cities in $SYSTEM_DATA/cities, home first:
#   name|region|timezone|latitude|longitude
# usage: weather.sh [menu]     add/remove/reorder cities, home forecast
#        weather.sh status     Waybar JSON (signal 16); weather cached for 30 min
#        weather.sh refresh    drop the cache and update Waybar

source "$(dirname "$0")/system-data.sh"
cities="$SYSTEM_DATA/cities"
cache="${XDG_RUNTIME_DIR:-/tmp}/weather.json"
fz=("$(dirname "$0")/menu.sh" --width 56)

refresh_bar() { pkill -RTMIN+16 waybar; }

# printf pads by bytes; pad by characters so names like Gdańsk or ★ line up
pad() { printf '%s%*s' "$1" $(($2 - ${#1})) ''; }

[[ -s "$cities" ]] || {
  mkdir -p "$SYSTEM_DATA"
  printf '%s\n' "Reykjavik|Capital Region, Iceland|Atlantic/Reykjavik|64.13548|-21.89541" \
    "Gdansk|Pomerania, Poland|Europe/Warsaw|54.35227|18.64912" >"$cities"
}

icon() { # wmo-code is-day
  case "$1" in
  0) (($2)) && echo 󰖙 || echo 󰖔 ;;
  1 | 2) (($2)) && echo 󰖕 || echo 󰼱 ;;
  3) echo 󰖐 ;;
  45 | 48) echo 󰖑 ;;
  51 | 53 | 55 | 56 | 57) echo 󰖗 ;;
  61 | 63 | 65 | 66 | 67 | 80 | 81 | 82) echo 󰖖 ;;
  71 | 73 | 75 | 77 | 85 | 86) echo 󰖘 ;;
  95 | 96 | 99) echo 󰖓 ;;
  *) echo 󰖐 ;;
  esac
}

# One request for all cities; result is always a JSON array in city order
fetch() {
  local lats lons
  lats=$(cut -d'|' -f4 "$cities" | paste -sd,)
  lons=$(cut -d'|' -f5 "$cities" | paste -sd,)
  curl -fsS --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=$lats&longitude=$lons\
&current=temperature_2m,weather_code,is_day,wind_speed_10m\
&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_probability_max\
&timezone=auto&forecast_days=3&wind_speed_unit=ms" 2>/dev/null |
    jq -c 'if type == "array" then . else [.] end'
}

# Fresh weather from cache (both bars share it), refetched after 30 min or a city change
weather() {
  exec 9>"$cache.lock"
  flock 9
  if [[ ! -s "$cache" || "$cities" -nt "$cache" ]] ||
    (($(date +%s) - $(stat -c %Y "$cache") > 1800)); then
    local new
    new=$(fetch)
    if [[ -n "$new" ]] && (($(jq length <<<"$new") == $(grep -c . "$cities"))); then
      echo "$new" >"$cache"
    fi
  fi
  flock -u 9
  [[ -s "$cache" ]] && cat "$cache"
}

status() {
  local data rows="" i=0 name tz t today local_day icon_ cur lo hi code day wind line
  data=$(weather)
  if [[ -z "$data" ]] || (($(jq length <<<"$data") != $(grep -c . "$cities"))); then
    echo '{"text": ""}'
    return
  fi
  today=$(date +%F)
  while IFS='|' read -r name _ tz _ _; do
    read -r cur code day wind lo hi < <(jq -r --argjson i "$i" '.[$i] |
      [(.current.temperature_2m | round), .current.weather_code, .current.is_day,
       (.current.wind_speed_10m | round), (.daily.temperature_2m_min[0] | round),
       (.daily.temperature_2m_max[0] | round)] | @tsv' <<<"$data")
    icon_=$(icon "$code" "$day")
    t=$(TZ="$tz" date +%H:%M)
    local_day=$(TZ="$tz" date +%F)
    [[ "$local_day" != "$today" ]] && t+=" ($(TZ="$tz" date +%a))"
    ((i == 0)) && name+=" ★"
    line="$(pad "$name" 15)$(pad "$t" 13)$(printf '%s %3s°   %3s° / %s°' "$icon_" "$cur" "$lo" "$hi")"
    ((i == 0)) && line+="   wind $wind m/s" && read -r home_icon home_temp <<<"$icon_ $cur"
    rows+="$line"$'\n'
    ((i++))
  done <"$cities"
  rows=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' <<<"${rows%$'\n'}")
  jq -cn --arg text "$home_icon $home_temp°" --arg tip "<tt>$rows</tt>" '{text: $text, tooltip: $tip}'
}

forecast() {
  local data name lines
  data=$(weather) || return
  name=$(head -1 "$cities" | cut -d'|' -f1)
  lines=$(jq -r '.[0].daily | [.time, .weather_code, (.temperature_2m_min | map(round)),
    (.temperature_2m_max | map(round)), .precipitation_probability_max] | transpose[] | @tsv' <<<"$data" |
    while IFS=$'\t' read -r d code lo hi rain; do
      printf '%s  %s  %s° / %s°  rain %s%%\n' "$(date -d "$d" '+%a %d')" "$(icon "$code" 1)" "$lo" "$hi" "$rain"
    done)
  notify-send -a weather -i weather-overcast -t 15000 "$name: 3 days" "$lines"
}

add_city() {
  local query results idx
  query=$("${fz[@]}" --prompt "City" --lines 0 --placeholder "e.g. Tokyo") || return
  [[ -n "$query" ]] || return
  results=$(curl -fsS --max-time 10 -G "https://geocoding-api.open-meteo.com/v1/search" \
    --data-urlencode "name=$query" -d count=8 -d language=en -d format=json 2>/dev/null |
    jq -r '.results[]? | [.name, ([.admin1, .country] | map(select(. != null)) | join(", ")),
      .timezone, .latitude, .longitude] | join("|")')
  if [[ -z "$results" ]]; then
    notify-send -a weather -u critical "City not found" "$query"
    return 1
  fi
  idx=$(awk -F'|' '{ print $1 ", " $2 }' <<<"$results" |
    "${fz[@]}" --prompt "$query" --lines 8 --index) || return
  sed -n "$((idx + 1))p" <<<"$results" >>"$cities"
  refresh_bar
}

city_menu() { # line-number name
  local choice tmp
  choice=$(printf '󰋜  Make home\n󰁝  Move up\n󰆴  Remove\n' | "${fz[@]}" --prompt "$2" --lines 3) || return
  tmp=$(mktemp)
  case "$choice" in
  *"Make home") { sed -n "${1}p" "$cities"; sed "${1}d" "$cities"; } >"$tmp" ;;
  *"Move up")
    if (($1 > 1)); then
      awk -v n="$1" 'NR == n - 1 { held = $0; next } { print } NR == n { print held }' "$cities" >"$tmp"
    else
      cp "$cities" "$tmp"
    fi
    ;;
  *Remove)
    if (($(grep -c . "$cities") <= 1)); then
      notify-send -a weather "Keep at least one city"
      cp "$cities" "$tmp"
    else
      sed "${1}d" "$cities" >"$tmp"
    fi
    ;;
  esac
  cat "$tmp" >"$cities"
  rm -f "$tmp"
  refresh_bar
}

menu() {
  local rows=() n=0 name region tz idx
  while IFS='|' read -r name region tz _ _; do
    ((n++))
    rows+=("$( ((n == 1)) && echo ★ || echo ' ')  $(TZ="$tz" date +%H:%M)  $name, $region")
  done <"$cities"
  idx=$(printf '%s\n' "󰐕  Add city" "${rows[@]}" "󰖐  3-day forecast (home)" |
    "${fz[@]}" --prompt "Clocks & weather" --lines $((${#rows[@]} + 2)) --index) || return
  if ((idx == 0)); then
    add_city
  elif ((idx == ${#rows[@]} + 1)); then
    forecast
  else
    city_menu "$idx" "$(sed -n "${idx}p" "$cities" | cut -d'|' -f1)"
  fi
}

case "${1:-menu}" in
menu) menu ;;
status) status ;;
refresh) rm -f "$cache"; refresh_bar ;;
*) echo "usage: $0 [menu|status|refresh]" >&2; exit 1 ;;
esac
