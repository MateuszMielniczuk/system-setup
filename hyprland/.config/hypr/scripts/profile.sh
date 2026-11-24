#!/bin/bash
# Visual + power profiles, remembered until logout and re-applied after config reloads
# usage: profile.sh normal|battery|performance   switch profile
#        profile.sh get                           print current profile
#        profile.sh apply                         re-apply (called on config.reloaded)

state="${XDG_RUNTIME_DIR:-/tmp}/hypr-profile"
current() { cat "$state" 2>/dev/null || echo normal; }

apply() {
  case "$(current)" in
  battery)
    hyprctl eval 'hl.config({
      animations = { enabled = false },
      decoration = { blur = { enabled = false }, shadow = { enabled = false },
                     active_opacity = 1.0, inactive_opacity = 1.0 },
      misc = { render_unfocused_fps = 10 },
    })' >/dev/null
    ;;
  performance)
    hyprctl eval 'hl.config({
      animations = { enabled = false },
      decoration = { rounding = 0, blur = { enabled = false }, shadow = { enabled = false },
                     active_opacity = 1.0, inactive_opacity = 1.0 },
      general = { gaps_in = 0, gaps_out = 0, border_size = 1 },
    })' >/dev/null
    ;;
  esac
}

case "$1" in
get) current ;;
apply) apply ;;
normal | battery | performance)
  echo "$1" >"$state"
  case "$1" in
  normal) powerprofilesctl set balanced ;;
  battery) powerprofilesctl set power-saver ;;
  performance) powerprofilesctl set performance ;;
  esac
  # Reload gives a clean base; the config.reloaded hook re-applies the profile
  hyprctl reload >/dev/null
  notify-send -t 2000 "Profile" "$1"
  ;;
*)
  echo "usage: $0 normal|battery|performance|get|apply" >&2
  exit 1
  ;;
esac
