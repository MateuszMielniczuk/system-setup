#!/bin/bash
# usage: theme.sh                     pick a theme with fuzzel
#        theme.sh <name>              apply a theme
#        theme.sh wallpaper           random wallpaper from the current theme (not the current one)
#        theme.sh wallpaper <file>    set a specific wallpaper
#        theme.sh wallpaper apply     re-apply the current wallpaper (after docking)
#        theme.sh rotation on|off|start|status   hourly random wallpaper (Hyprland-only timer)
# A wallpaper "name.ext" may have "name-uw.<jpg|png|webp>" next to it: used on screens wider than 2:1.

themes="$HOME/.config/hypr/themes"
state="${XDG_STATE_HOME:-$HOME/.local/state}/theme"
mkdir -p "$state"
current=$(cat "$state/current" 2>/dev/null || echo gruvbox-dark)

# Ultrawide variant of an image, if it exists (any image format: name.png -> name-uw.jpg)
uw_of() {
  local ext
  for ext in "${1##*.}" jpg jpeg png webp; do
    [[ -f "${1%.*}-uw.$ext" ]] && echo "${1%.*}-uw.$ext" && return
  done
}

set_wallpaper() {
  local img="${1:-}" last uw mon conf
  last=$(cat "$state/wallpaper" 2>/dev/null)
  if [[ -z "$img" ]]; then
    [[ -d "$wallpapers" ]] || return 0
    img=$(find "$wallpapers" -maxdepth 1 -type f \
      \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
      ! -iname '*-uw.*' ! -path "$last" | shuf -n1)
    [[ -z "$img" ]] && img=$last
  fi
  [[ -f "$img" ]] || return 0
  echo "$img" >"$state/wallpaper"
  uw=$(uw_of "$img")

  conf="splash = false
"
  conf+="
wallpaper {
    monitor =
    path = $img
    fit_mode = cover
}
"
  # Set every monitor explicitly: a monitor given its own image keeps it otherwise
  while read -r mon wide; do
    if [[ -n "$uw" && "$wide" == true ]]; then
      conf+="
wallpaper {
    monitor = $mon
    path = $uw
    fit_mode = cover
}
"
      hyprctl hyprpaper wallpaper "$mon,$uw" >/dev/null 2>&1
    else
      hyprctl hyprpaper wallpaper "$mon,$img" >/dev/null 2>&1
    fi
  done < <(hyprctl monitors -j | jq -r '.[] | "\(.name) \(.width > 2 * .height)"')
  printf '%s' "$conf" >"$HOME/.config/hypr/hyprpaper.conf"
}

rotation() { # on|off|start|status
  local flag="$state/rotation-off" unit=wallpaper-rotate
  case "$1" in
  on) rm -f "$flag" && rotation start ;;
  off)
    touch "$flag"
    systemctl --user stop "$unit.timer" 2>/dev/null
    ;;
  start)
    [[ -f "$flag" ]] && return 0
    systemctl --user is-active -q "$unit.timer" && return 0
    systemd-run --user --quiet --unit="$unit" --on-calendar=hourly \
      "$HOME/.config/hypr/scripts/theme.sh" wallpaper
    ;;
  status) [[ -f "$flag" ]] && echo off || echo on ;;
  esac
}

name="${1:-}"
if [[ "$name" == "wallpaper" ]]; then
  source "$themes/$current.sh"
  if [[ "${2:-}" == apply ]]; then
    set_wallpaper "$(cat "$state/wallpaper" 2>/dev/null)"
  else
    set_wallpaper "${2:-}"
  fi
  exit 0
fi
if [[ "$name" == "rotation" ]]; then
  rotation "${2:-status}"
  exit 0
fi

if [[ -z "$name" ]]; then
  name=$(find "$themes" -name '*.sh' -printf '%f\n' | sed 's/\.sh$//' | sort |
    fuzzel --dmenu --prompt "Theme ❯ " --select "$current" --lines 11 --width 30) || exit 0
fi

if [[ ! -f "$themes/$name.sh" ]]; then
  echo "unknown theme: $name" >&2
  exit 1
fi
source "$themes/$name.sh"
[[ "$variant" == dark ]] && gtk="Adwaita:dark" || gtk="Adwaita"

cat >"$HOME/.config/hypr/theme.lua" <<EOF
return {
    active   = { "rgba(${accent}ee)", "rgba(${accent2}ee)" },
    inactive = "rgba(${surface2}aa)",
    gtk      = "$gtk",
}
EOF

cat >"$HOME/.config/hypr/hyprlock-colors.conf" <<EOF
\$base    = rgba(${bg}ee)
\$surface = rgba(${surface0}ee)
\$text    = rgb(${fg})
\$subtext = rgb(${subtext})
\$accent  = rgb(${accent})
\$yellow  = rgb(${yellow})
\$red     = rgb(${red})
EOF

cat >"$HOME/.config/waybar/colors.css" <<EOF
@define-color base     #${bg};
@define-color surface0 #${surface0};
@define-color surface1 #${surface1};
@define-color surface2 #${surface2};
@define-color text     #${fg};
@define-color subtext  #${subtext};
@define-color accent   #${accent};
@define-color red      #${red};
@define-color yellow   #${yellow};
@define-color green    #${green};
@define-color blue     #${blue};
EOF

cat >"$HOME/.config/fuzzel/colors.ini" <<EOF
[colors]
background=${bg}ee
text=${fg}ff
prompt=${subtext}ff
placeholder=${surface2}ff
input=${fg}ff
match=${accent}ff
selection=${surface1}ff
selection-text=${fg}ff
selection-match=${accent2}ff
border=${accent}ff
EOF

cat >"$HOME/.config/mako/colors" <<EOF
background-color=#${bg}ee
text-color=#${fg}
border-color=#${surface2}
progress-color=over #${surface1}

[urgency=critical]
border-color=#${red}

[app-name=osd]
border-color=#${accent}
progress-color=over #${accent}66
EOF

cat >"$HOME/.config/kitty/theme.conf" <<EOF
foreground #${fg}
background #${bg}
cursor #${fg}
cursor_text_color #${bg}
selection_foreground #${fg}
selection_background #${surface2}
url_color #${blue}
active_tab_foreground #${bg}
active_tab_background #${accent}
inactive_tab_foreground #${subtext}
inactive_tab_background #${surface0}
tab_bar_background #${bg}
color0 #${surface1}
color8 #${surface2}
color1 #${red}
color9 #${red}
color2 #${green}
color10 #${green}
color3 #${yellow}
color11 #${yellow}
color4 #${blue}
color12 #${blue}
color5 #${magenta}
color13 #${magenta}
color6 #${cyan}
color14 #${cyan}
color7 #${subtext}
color15 #${fg}
EOF

echo "$name" >"$state/current"
[[ "$name" == "$current" ]] || set_wallpaper

# Live reload; each step is a no-op when the app isn't running
hyprctl reload >/dev/null 2>&1
pkill -USR2 -x waybar
makoctl reload 2>/dev/null
pkill -USR1 -x kitty
for sock in "${XDG_RUNTIME_DIR:-/run/user/$UID}"/nvim.*; do
  [[ -S "$sock" ]] || continue
  timeout 2 nvim --server "$sock" --remote-expr 'luaeval("require(\"config.theme\").apply()")' >/dev/null 2>&1 &
done
wait
notify-send -t 2000 "Theme" "$name" 2>/dev/null
exit 0
