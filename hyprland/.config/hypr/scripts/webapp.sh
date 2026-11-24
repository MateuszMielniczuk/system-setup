#!/bin/bash
# Web apps: a site in its own window (no tabs or address bar) with a launcher in the app launcher/Plasma menu.
# Opens in the default browser when it is Chromium-based (needed for --app), else Chromium.
# usage: webapp.sh add NAME URL | remove NAME | restore | launch URL | menu

source "$(dirname "$0")/system-data.sh"
list="$SYSTEM_DATA/webapps"
apps="$HOME/.local/share/applications"
icons="$HOME/.local/share/icons/hicolor/256x256/apps"
self="$HOME/.config/hypr/scripts/webapp.sh"

slug() { tr '[:upper:]' '[:lower:]' <<<"$1" | sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//'; }

browser() { # command of the default browser, if it supports --app
  local desktop exec dir
  desktop=$(xdg-settings get default-web-browser 2>/dev/null)
  case "$desktop" in
  *chromium* | *chrome* | *brave* | *vivaldi* | *edge* | *opera*)
    for dir in "${XDG_DATA_HOME:-$HOME/.local/share}" /usr/local/share /usr/share; do
      [[ -f "$dir/applications/$desktop" ]] || continue
      exec=$(sed -n 's/^Exec=\([^ ]*\).*/\1/p' "$dir/applications/$desktop" | head -1)
      command -v "$exec" >/dev/null && echo "$exec" && return
    done
    ;;
  esac
  echo chromium
}

# Window class the browser gives an --app window: <prefix>-<host>__<path>-Default
window_class() { # url
  local address host path prefix
  address=${1#*://}
  address=${address%%[?#]*}
  host=${address%%/*}
  path=${address:${#host}}
  case "$(basename "$(browser)")" in
  brave*) prefix=brave ;;
  *) prefix=chrome ;;
  esac
  printf '%s-%s_%s-Default\n' "$prefix" "${host,,}" "${path:-/}" | sed 's|/|_|g'
}

download_icon() { # url dest
  curl -fsSL --max-time 10 -o "$2" "$1" 2>/dev/null &&
    [[ -s "$2" && $(file -b --mime-type "$2") == image/* ]]
}

fetch_icon() { # site-url dest
  local origin href
  origin=$(sed -E 's|^(https?://[^/]+).*|\1|' <<<"$1")
  href=$(curl -fsSL --max-time 5 "$1" 2>/dev/null | head -c 200000 | tr '\n' ' ' |
    grep -oiE "<link[^>]*rel=[\"'][^\"']*apple-touch-icon[^\"']*[\"'][^>]*>" |
    grep -oiE "href=[\"'][^\"']+" | head -1 | sed -E "s/^href=[\"']//")
  case "$href" in
  http://* | https://*) ;;
  //*) href="https:$href" ;;
  /*) href="$origin$href" ;;
  ?*) href="$origin/$href" ;;
  esac
  { [[ -n "$href" ]] && download_icon "$href" "$2"; } ||
    download_icon "$origin/apple-touch-icon.png" "$2" ||
    download_icon "https://www.google.com/s2/favicons?domain=${origin#*://}&sz=256" "$2"
}

add() { # name url
  local name=$1 url=$2 id icon
  [[ -n "$name" && -n "$url" && "$name" != */* ]] || { echo "usage: $0 add NAME URL" >&2; return 1; }
  [[ "$url" =~ ^[a-zA-Z][a-zA-Z0-9+.-]*: ]] || url="https://$url"
  [[ "${url,,}" =~ ^https?://[^[:space:]]+$ ]] || { echo "URL must be http(s): $url" >&2; return 1; }
  id="webapp-$(slug "$name")"
  mkdir -p "$apps" "$icons" "$SYSTEM_DATA"

  icon=applications-internet
  if fetch_icon "$url" "$icons/$id.png"; then
    icon=$id
    gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" 2>/dev/null
  fi

  cat >"$apps/$id.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Comment=$name web app
Exec="$self" launch "$url"
Icon=$icon
Categories=Network;WebBrowser;
StartupWMClass=$(window_class "$url")
EOF
  touch "$list"
  grep -v "^$name|" "$list" >"$list.tmp"
  echo "$name|$url" >>"$list.tmp"
  mv "$list.tmp" "$list"
  update-desktop-database -q "$apps" 2>/dev/null
}

remove() { # name
  local id="webapp-$(slug "$1")"
  rm -f "$apps/$id.desktop" "$icons/$id.png"
  if [[ -f "$list" ]]; then
    grep -v "^$1|" "$list" >"$list.tmp"
    mv "$list.tmp" "$list"
  fi
  update-desktop-database -q "$apps" 2>/dev/null
}

restore() {
  local name url
  [[ -f "$list" ]] || return 0
  while IFS='|' read -r name url; do
    [[ -n "$name" ]] && add "$name" "$url"
  done < <(cat "$list")
}

menu() {
  local fz=("$(dirname "$0")/menu.sh" --width 44) choice name url
  choice=$({
    echo "󰐕  Add web app"
    [[ -f "$list" ]] && cut -d'|' -f1 "$list" | sed 's/^/󰖟  /'
    echo "󰑓  Restore all"
  } | "${fz[@]}" --prompt "Web apps" --lines 12) || return
  case "$choice" in
  *"Add web app")
    name=$("${fz[@]}" --prompt "Name" --lines 0 --placeholder "e.g. YouTube") || return
    url=$("${fz[@]}" --prompt "URL" --lines 0 --placeholder "e.g. youtube.com") || return
    if add "$name" "$url"; then
      notify-send -i "webapp-$(slug "$name")" "Web app added" "$name"
    else
      notify-send -u critical "Web app not added" "Check the name and URL"
    fi
    ;;
  *"Restore all") restore && notify-send "Web apps restored" ;;
  *)
    name=${choice#󰖟  }
    [[ $(printf '󰆴  Remove %s\n' "$name" | "${fz[@]}" --prompt "$name" --lines 1) ]] || return
    remove "$name" && notify-send "Web app removed" "$name"
    ;;
  esac
}

case "$1" in
add) add "$2" "$3" ;;
remove) remove "$2" ;;
restore) restore ;;
launch) exec setsid "$(browser)" --app="$2" ;;
menu | "") menu ;;
*) echo "usage: $0 add NAME URL | remove NAME | restore | launch URL | menu" >&2; exit 1 ;;
esac
