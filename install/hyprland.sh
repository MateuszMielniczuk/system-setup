#!/bin/bash

install_hyprland() {
  local distro="$1"

  case "$distro" in
  manjaro | cachyos | arch)
    install_hyprland_arch
    ;;
  *)
    echo "❌ Error: Hyprland setup for '${distro}' is not supported."
    return 1
    ;;
  esac
}

install_hyprland_arch() {
  echo "Installing Hyprland packages for Arch-based systems..."
  sudo pacman -S --needed --noconfirm \
    brightnessctl \
    rofi \
    waybar \
    mako \
    hyprpaper \
    network-manager-applet \
    blueman \
    hyprlock \
    hypridle \
    hyprsunset \
    cliphist \
    grim \
    slurp \
    satty \
    wf-recorder \
    yazi \
    zoxide \
    7zip \
    tesseract \
    tesseract-data-eng \
    tesseract-data-pol \
    zbar \
    hyprpicker \
    wtype \
    calcurse \
    gthumb
  echo "Hyprland packages installed successfully."

  # The mouse receiver must not wake the laptop from suspend
  sudo install -m 644 "$(dirname "${BASH_SOURCE[0]}")/files/90-mouse-no-wakeup.rules" /etc/udev/rules.d/
  sudo udevadm control --reload-rules
}
