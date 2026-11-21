#!/bin/bash
# Select a screen region and copy its text (OCR) or QR code content to the clipboard
# usage: ocr.sh [text|qr]

source "$(dirname "$0")/region.sh"

mode="${1:-text}"
img=$(mktemp --suffix=.png)
trap 'rm -f "$img"' EXIT
capture_region "$img" || exit 0

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
