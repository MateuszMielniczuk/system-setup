#!/bin/bash

# add symbolic links from packages in this directory to the home folder
# requires `stow` package to be installed on the system
# existing (non-symlink) files that would conflict are moved to ~/backups_stow

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

PACKAGES=(bash fish herdr hyprland kitty mako nvim rofi starship waybar zed)
BACKUP_DIR="$HOME/backups_stow/$(date +%Y%m%d-%H%M%S)"

if ! command -v stow >/dev/null; then
  echo "stow is not installed."
  exit 1
fi

for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r -d '' file; do
    rel="${file#"$pkg"/}"
    target="$HOME/$rel"
    # absolute symlink pointing at this repo file (not stow-style relative):
    # stow treats it as foreign and aborts, so drop it and let stow relink
    if [[ -L "$target" && "$(readlink "$target")" == /* &&
      "$(readlink -f "$target")" == "$(readlink -f "$file")" ]]; then
      rm "$target"
      echo "Replaced absolute symlink $target"
    # skip missing targets and links (already stowed)
    # target already resolves to the repo file (e.g. via a symlinked parent dir):
    # never move it, that would delete the repo file itself
    elif [[ "$(readlink -f "$target")" == "$(readlink -f "$file")" ]]; then
      :
    elif [[ -e "$target" && ! -L "$target" ]]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      echo "Backed up $target -> $BACKUP_DIR/$rel"
    fi
  done < <(find "$pkg" -type f -print0)
done

stow -v -t "$HOME" "${PACKAGES[@]}"

# generate theme color files (gitignored)
theme="$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/theme/current" 2>/dev/null || echo gruvbox-dark)"
"$HOME/.config/hypr/scripts/theme.sh" "$theme" || true
