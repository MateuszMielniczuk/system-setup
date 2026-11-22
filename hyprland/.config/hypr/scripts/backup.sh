#!/bin/bash
# Settings backup: private data that isn't in git, as dated archives in $SYSTEM_DATA/backups
# (synced by Syncthing; the archives are the history Syncthing doesn't keep).
# usage: backup.sh [menu]        back up now / pick an archive to restore
#        backup.sh now           make an archive
#        backup.sh auto          make one if the newest is older than 7 days (Hyprland start)
#        backup.sh restore FILE  restore an archive (the wallet is staged, not overwritten)

source "$(dirname "$0")/system-data.sh"
dest="$SYSTEM_DATA/backups"
keep=10
fz=(fuzzel --dmenu --width 56)
umask 077

# Paths relative to $HOME
items() {
  cd "$HOME" || return
  local data=${SYSTEM_DATA#"$HOME"/} p
  for p in .local/share/kwalletd "$data" .config/mimeapps.list .local/state/theme \
    .local/share/applications/webapp-*.desktop .local/share/icons/hicolor/256x256/apps/webapp-*.png; do
    [[ -e "$p" ]] && echo "$p"
  done
}

now() { # [quiet]
  local file
  mkdir -p "$dest"
  file="$dest/settings-$(date +%F_%H%M%S).tar.gz"
  if items | tar -czf "$file" -C "$HOME" --exclude="${dest#"$HOME"/}" --exclude="*.pid" -T - 2>/dev/null; then
    ls -1t "$dest"/settings-*.tar.gz | tail -n +$((keep + 1)) | xargs -r rm --
    [[ "$1" == quiet ]] || notify-send -a backup -i document-save "Settings backed up" \
      "$(basename "$file") ($(du -h "$file" | cut -f1))"
    echo "$file"
  else
    rm -f "$file"
    notify-send -a backup -u critical -i dialog-error "Settings backup failed"
    return 1
  fi
}

auto() {
  [[ -n $(find "$dest" -name 'settings-*.tar.gz' -mtime -7 -print -quit 2>/dev/null) ]] || now quiet >/dev/null
}

restore() { # archive
  local file=$1 staged="$HOME/.local/share/kwalletd.restore"
  [[ -f "$file" ]] || { echo "no such archive: $file" >&2; return 1; }
  now quiet >/dev/null || return 1 # undo point
  tar -xzf "$file" -C "$HOME" --exclude=.local/share/kwalletd || return 1
  # The running wallet service would overwrite the wallet: stage it for after logout
  rm -rf "$staged"
  mkdir -p "$staged"
  tar -xzf "$file" -C "$staged" --strip-components=3 .local/share/kwalletd 2>/dev/null

  "$(dirname "$0")/webapp.sh" restore
  "$(dirname "$0")/theme.sh" wallpaper apply
  pkill -SIGUSR2 waybar
  if [[ -n "$(ls -A "$staged" 2>/dev/null)" ]]; then
    notify-send -a backup -t 0 -i document-revert "Settings restored" \
      "Wallet staged. To restore it: log out, open a TTY (Ctrl+Alt+F3), log in and run:
cp ~/.local/share/kwalletd.restore/* ~/.local/share/kwalletd/"
  else
    rmdir "$staged"
    notify-send -a backup -i document-revert "Settings restored" "$(basename "$file")"
  fi
}

menu() {
  local archives=() rows=() f idx
  mapfile -t archives < <(ls -1t "$dest"/settings-*.tar.gz 2>/dev/null)
  for f in "${archives[@]}"; do
    rows+=("󰁯  Restore $(date -d "@$(stat -c %Y "$f")" '+%a %d %b %Y %H:%M')  ($(du -h "$f" | cut -f1))")
  done
  idx=$(printf '%s\n' "󰆓  Back up now" "${rows[@]}" |
    "${fz[@]}" --prompt "Backup ❯ " --lines $((${#rows[@]} + 1)) --index) || return
  [[ -n "$idx" ]] || return
  if ((idx == 0)); then
    now >/dev/null
  else
    f=${archives[idx - 1]}
    [[ $(printf '󰁯  Yes, restore %s\n' "$(basename "$f")" |
      "${fz[@]}" --prompt "Overwrite current settings? ❯ " --lines 1) ]] || return
    restore "$f"
  fi
}

case "${1:-menu}" in
menu) menu ;;
now) now ;;
auto) auto ;;
restore) restore "$2" ;;
*) echo "usage: $0 [menu|now|auto|restore FILE]" >&2; exit 1 ;;
esac
