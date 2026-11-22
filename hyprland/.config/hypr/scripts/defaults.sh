#!/bin/bash
# Default apps per category (fuzzel). Writes ~/.config/mimeapps.list via xdg-mime,
# which Plasma reads too, so both sessions use the same defaults.
# usage: defaults.sh [menu]

fz=(fuzzel --dmenu --width 52)
dirs=("${XDG_DATA_HOME:-$HOME/.local/share}/applications" /usr/local/share/applications /usr/share/applications)

# label#icon#type that shows the current app#regex for the app's own types to set#extra types
categories=(
  'Web browser#󰖟#x-scheme-handler/https#^(text/html|application/xhtml\+xml)$#x-scheme-handler/http x-scheme-handler/https text/html'
  'File manager#󰉋#inode/directory#^inode/directory$#inode/directory'
  'PDF#󰈙#application/pdf#^application/pdf$#application/pdf'
  'Images#󰋩#image/png#^image/#image/png image/jpeg'
  'Video#󰕧#video/mp4#^(video/|application/x-matroska$)#video/mp4'
  'Music#󰝚#audio/mpeg#^audio/#audio/mpeg'
  'Text#󰈮#text/plain#^text/(plain|markdown|x-log)$#text/plain'
  'Archives#󰛫#application/zip#^application/(zip|x-tar|x-7z-compressed|vnd.rar|x-rar|gzip|x-xz|zstd|x-compressed-tar|x-bzip2)#application/zip'
  'Email#󰇮#x-scheme-handler/mailto#^x-scheme-handler/mailto$#x-scheme-handler/mailto'
)

# Name= from the [Desktop Entry] section (actions have their own Name=)
entry_name() { awk '/^\[/ { main = ($0 == "[Desktop Entry]") } main && /^Name=/ { print substr($0, 6); exit }' "$1"; }

desktop_file() { # id -> path
  local d
  for d in "${dirs[@]}"; do
    [[ -f "$d/$1" ]] && echo "$d/$1" && return
  done
}

app_name() { # id -> Name
  local f
  f=$(desktop_file "$1")
  local short=${1%.desktop}
  short=${short##*.}
  [[ -n "$f" ]] && echo "$(entry_name "$f") ($short)" || echo "${1:-none}"
}

# Installed apps declaring a MIME type: "id<TAB>name"
apps_for() {
  local d f
  for d in "${dirs[@]}"; do
    [[ -d "$d" ]] || continue
    grep -l -E "^MimeType=(.*;)?$1;" "$d"/*.desktop 2>/dev/null
  done | while read -r f; do
    grep -q '^Hidden=true' "$f" && continue
    printf '%s\t%s\n' "$(basename "$f")" "$(entry_name "$f")"
  done | sort -u -t$'\t' -k1,1 | sort -t$'\t' -k2
}

set_default() { # id regex extra-types
  local types
  types=$(sed -n 's/^MimeType=//p' "$(desktop_file "$1")" | head -1 | tr ';' '\n' | grep -E "$2")
  # shellcheck disable=SC2086
  xdg-mime default "$1" $(printf '%s\n' $types $3 | sort -u)
}

pick() { # category line
  local label icon key regex extra choice apps
  IFS='#' read -r label icon key regex extra <<<"$1"
  apps=$(apps_for "$key")
  [[ -n "$apps" ]] || { notify-send -a defaults "$label" "No installed app supports $key"; return; }
  choice=$(awk -F'\t' '{ print $2 "  (" $1 ")" }' <<<"$apps" |
    "${fz[@]}" --prompt "$label ❯ " --lines "$(grep -c . <<<"$apps")") || return
  choice=${choice##*(}
  choice=${choice%)}
  [[ -n "$choice" ]] || return
  set_default "$choice" "$regex" "$extra" &&
    notify-send -a defaults "$label" "$(app_name "$choice")"
}

menu() {
  local rows=() line label icon key idx
  for line in "${categories[@]}"; do
    IFS='#' read -r label icon key _ <<<"$line"
    rows+=("$(printf '%s  %-14s %s' "$icon" "$label" "$(app_name "$(xdg-mime query default "$key")")")")
  done
  idx=$(printf '%s\n' "${rows[@]}" "󰒓  All file types (Plasma settings)" |
    "${fz[@]}" --prompt "Default apps ❯ " --lines $((${#rows[@]} + 1)) --index) || return
  if ((idx == ${#rows[@]})); then
    kcmshell6 kcm_filetypes
  else
    pick "${categories[idx]}"
  fi
}

case "${1:-menu}" in
menu) menu ;;
set) # defaults.sh set "<category label>" <app.desktop>
  for line in "${categories[@]}"; do
    [[ "${line%%#*}" == "$2" ]] || continue
    IFS='#' read -r _ _ _ regex extra <<<"$line"
    set_default "$3" "$regex" "$extra"
  done
  ;;
*) echo "usage: $0 [menu | set CATEGORY APP.desktop]" >&2; exit 1 ;;
esac
