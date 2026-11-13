#!/bin/bash

# add symbolic links from packages in this directory to the home folder
# requires `stow` package to be installed on the system
# existing (non-symlink) files that would conflict are moved to ~/backups_stow

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

PACKAGES=(bash fish kitty nvim starship zed)
BACKUP_DIR="$HOME/backups_stow/$(date +%Y%m%d-%H%M%S)"

if ! command -v stow >/dev/null; then
  echo "stow is not installed."
  exit 1
fi

for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r -d '' file; do
    rel="${file#"$pkg"/}"
    target="$HOME/$rel"
    # skip missing targets and links (already stowed)
    if [[ -e "$target" && ! -L "$target" ]]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      echo "Backed up $target -> $BACKUP_DIR/$rel"
    fi
  done < <(find "$pkg" -type f -print0)
done

stow -v -t "$HOME" "${PACKAGES[@]}"
