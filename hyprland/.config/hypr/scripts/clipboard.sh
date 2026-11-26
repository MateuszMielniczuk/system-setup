#!/bin/bash
# Clipboard history (cliphist) with image thumbnails and pins (Super+V)
# Enter copies, Alt+P pins/unpins, Alt+D deletes, Alt+C clears history, Alt+X clears all. Pins stay local.
# usage: clipboard.sh          menu
#        clipboard.sh status   Waybar JSON (signal 20)
#        clipboard.sh clear    wipe history, pins and the current clipboard (asks first)
pins="${XDG_DATA_HOME:-$HOME/.local/share}/clipboard-pins"
thumbs="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-thumbs"
umask 077
mkdir -p "$pins" "$thumbs"
chmod 700 "$pins" "$thumbs"

preview() { tr '\n\t' '  ' <"$1" | cut -c1-80; }
confirm() { [[ $(printf '%s\n' "$2" | "$(dirname "$0")/menu.sh" --prompt "$1" --lines 1) ]]; }
refresh() { pkill -RTMIN+20 waybar; }

status() {
  local n p
  n=$(cliphist list 2>/dev/null | wc -l)
  p=$(find "$pins" -type f | wc -l)
  jq -cn --arg n "$n" --arg p "$p" --arg class "$( ((n + p > 0)) && echo full || echo empty)" \
    '{text: "󰅌", tooltip: "Clipboard: \($n) in history, \($p) pinned\nClick: history · Right click: clear everything", class: $class}'
}

clear_all() {
  confirm "Clear history, pins and clipboard?" "Yes, clear everything" || return
  cliphist wipe
  wl-copy --clear
  rm -f "$thumbs"/*.png "$pins"/*
  refresh
  notify-send -a clipboard -i edit-clear "Clipboard cleared" "History, pins and current clipboard"
}

case "$1" in
status) status; exit ;;
clear) clear_all; exit ;;
esac

while :; do
  rows=() icons=() refs=() # icons: image path or empty (rows can't hold the NUL rofi needs)
  for f in "$pins"/*; do
    [[ -f "$f" ]] || continue
    if [[ $(file -b --mime-type "$f") == image/* ]]; then
      rows+=("📌  Image") icons+=("$f")
    else
      rows+=("📌  $(preview "$f")") icons+=("")
    fi
    refs+=("pin:$f")
  done
  while IFS= read -r line; do
    id=${line%%$'\t'*}
    if [[ "$line" == *"[[ binary data"* ]]; then
      thumb="$thumbs/$id.png"
      [[ -f "$thumb" ]] || cliphist decode <<<"$line" | magick - -thumbnail 96x96 "$thumb" 2>/dev/null
      rows+=("${line#*$'\t'}") icons+=("$thumb")
    else
      rows+=("${line#*$'\t'}") icons+=("")
    fi
    refs+=("hist:$line")
  done < <(cliphist list)

  idx=$(for i in "${!rows[@]}"; do
    if [[ -n "${icons[i]}" ]]; then printf '%s\0icon\x1f%s\n' "${rows[i]}" "${icons[i]}"; else printf '%s\n' "${rows[i]}"; fi
  done | "$(dirname "$0")/menu.sh" --prompt Clipboard --width 70 --lines 12 \
    --index --icon-size 32 --key 1 Alt+p --key 2 Alt+d --key 3 Alt+c --key 4 Alt+x \
    --message "Enter copy  ·  Alt+P pin / unpin  ·  Alt+D delete Alt+C clear history  ·  Alt+X clear all")
  rc=$?
  case "$rc" in
  12)
    confirm "Clear clipboard history (keeps pins)?" "Yes, clear history" && cliphist wipe && rm -f "$thumbs"/*.png && refresh
    exit 0
    ;;
  13) clear_all; exit 0 ;;
  esac
  [[ -n "$idx" ]] || exit 0
  ref=${refs[idx]}

  case "$rc:$ref" in
  0:pin:*)
    f=${ref#pin:}
    wl-copy --type "$(file -b --mime-type "$f")" <"$f"
    exit 0
    ;;
  0:hist:*) cliphist decode <<<"${ref#hist:}" | wl-copy && exit 0 ;;
  10:pin:*) rm -f "${ref#pin:}" ;; # unpin
  10:hist:*)
    tmp=$(mktemp "$pins/XXXXXX")
    cliphist decode <<<"${ref#hist:}" >"$tmp"
    ;;
  11:pin:*) rm -f "${ref#pin:}" ;;
  11:hist:*)
    line=${ref#hist:}
    cliphist delete <<<"$line"
    rm -f "$thumbs/${line%%$'\t'*}.png"
    ;;
  *) exit 0 ;;
  esac
  refresh
done
