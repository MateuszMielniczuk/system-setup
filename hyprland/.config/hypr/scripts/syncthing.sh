#!/bin/bash
# Waybar Syncthing status from the local REST API (API key read from this machine's config)
# usage: syncthing.sh          Waybar JSON
#        syncthing.sh open     open the web UI
conf="${XDG_STATE_HOME:-$HOME/.local/state}/syncthing/config.xml"
addr=$(sed -n 's|.*<address>\(127[^<]*\)</address>.*|\1|p' "$conf" | head -1)
key=$(sed -n 's|.*<apikey>\([^<]*\)</apikey>.*|\1|p' "$conf")

if [[ "$1" == open ]]; then
  xdg-open "http://$addr"
  exit 0
fi

# Key passed on stdin (-H @-) so it doesn't show in the process list
api() { curl -fsS --max-time 3 -H @- "${@/#/http://$addr/rest/}" <<<"X-API-Key: $key"; }

out() { jq -cn --arg text "$1" --arg tip "$2" --arg class "$3" '{text: $text, tooltip: $tip, class: $class}'; }

folders=$(api config/folders 2>/dev/null) || {
  out "󰓨 !" "Syncthing is not running" error
  exit 0
}
ids=$(jq -r '.[].id' <<<"$folders")
# One request for every folder's status, plus devices and connections
statuses=$(api $(printf 'db/status?folder=%s ' $ids) | jq -s .)
devices=$(api config/devices)
conns=$(api system/connections)
self=$(api system/status | jq -r .myID)

jq -r --argjson f "$folders" --argjson s "$statuses" --argjson d "$devices" --argjson c "$conns" \
  --arg self "$self" -n '
  ([$s[].needBytes] | add) as $need | ([$s[].globalBytes] | add) as $total |
  ([$s[] | select(.state == "error" or .errors > 0 or .pullErrors > 0)] | length) as $err |
  ([$d[] | select(.deviceID != $self) | .deviceID] ) as $peers |
  ([$peers[] | select($c.connections[.].connected)] | length) as $up |
  ([range(0; $f | length) | "\($f[.].label // $f[.].id): \(
      if ($s[.].errors + $s[.].pullErrors) > 0 or $s[.].state == "error" then "errors"
      elif $s[.].needBytes > 0 then "syncing \(100 - ($s[.].needBytes * 100 / ([$s[.].globalBytes, 1] | max)) | floor)%"
      elif $s[.].state == "idle" then "up to date" else $s[.].state end)"] | join("\n")) as $lines |
  ([$d[] | select(.deviceID != $self) | "\(.name): \(if $c.connections[.deviceID].connected then "connected" else "offline" end)"]
    | join("\n")) as $devs |
  if $err > 0 then ["󰓨 !", "error"]
  elif $need > 0 then ["󰓦 \(100 - ($need * 100 / ([$total, 1] | max)) | floor)%", "syncing"]
  elif $up == 0 then ["󰓨", "offline"]
  else ["󰓦", "idle"] end |
  [.[0], "\($lines)\n\n\($devs)\nClick: open Syncthing", .[1]] | @tsv' |
  while IFS=$'\t' read -r text tip class; do out "$text" "$(printf '%b' "$tip")" "$class"; done
