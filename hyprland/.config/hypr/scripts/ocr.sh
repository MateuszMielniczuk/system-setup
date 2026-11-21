#!/bin/bash
# Select a screen region and copy its text (OCR) or QR code content to the clipboard
# usage: ocr.sh [text|qr]

mode="${1:-text}"
geom=$(slurp) || exit 0

img=$(mktemp --suffix=.png)
trap 'rm -f "$img"' EXIT
grim -g "$geom" "$img" || exit 1

if [[ "$mode" == qr ]]; then
  title="QR code"
  out=$(zbarimg --quiet --raw "$img" 2>/dev/null)
else
  title="Text"
  # Bigger and grayscale reads much better for small UI text
  magick "$img" -colorspace Gray -resize 300% "$img"
  langs=$(tesseract --list-langs 2>/dev/null | grep -xE 'eng|pol' | paste -sd+)
  out=$(tesseract "$img" - -l "${langs:-eng}" 2>/dev/null | tr -d '\f')
fi

if [[ -z "${out//[[:space:]]/}" ]]; then
  notify-send -a ocr "$title" "Nothing found"
  exit 0
fi

printf '%s' "$out" | wl-copy
lines=$(printf '%s\n' "$out" | wc -l)
preview=$(printf '%s' "$out" | head -c 160 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
notify-send -a ocr "$title copied ($lines line$([[ $lines -gt 1 ]] && echo s))" "$preview"
