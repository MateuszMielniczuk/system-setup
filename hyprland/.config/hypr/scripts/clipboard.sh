#!/bin/bash
# Clipboard history (cliphist) with image thumbnails and pins (Super+V)
# Enter copies, Alt+P pins/unpins, Alt+D deletes. Pins stay local (not synced).
pins="${XDG_DATA_HOME:-$HOME/.local/share}/clipboard-pins"
thumbs="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-thumbs"
mkdir -p "$pins" "$thumbs"

preview() { tr '\n\t' '  ' <"$1" | cut -c1-80; }

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
  rows+=("󰆴  Clear history (keeps pins)") icons+=("") refs+=("clear")

  idx=$(for i in "${!rows[@]}"; do
    if [[ -n "${icons[i]}" ]]; then printf '%s\0icon\x1f%s\n' "${rows[i]}" "${icons[i]}"; else printf '%s\n' "${rows[i]}"; fi
  done | "$(dirname "$0")/menu.sh" --prompt Clipboard --width 70 --lines 12 \
    --index --icon-size 32 --key 1 Alt+p --key 2 Alt+d \
    --message "Enter copy  ·  Alt+P pin / unpin  ·  Alt+D delete")
  rc=$?
  [[ -n "$idx" ]] || exit 0
  ref=${refs[idx]}

  case "$rc:$ref" in
  0:pin:*)
    f=${ref#pin:}
    wl-copy --type "$(file -b --mime-type "$f")" <"$f"
    exit 0
    ;;
  0:hist:*) cliphist decode <<<"${ref#hist:}" | wl-copy && exit 0 ;;
  0:clear)
    [[ $(printf 'Yes, clear history\n' | "$(dirname "$0")/menu.sh" --prompt "Clear clipboard history?" --lines 1) ]] &&
      cliphist wipe && rm -f "$thumbs"/*.png
    exit 0
    ;;
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
done
