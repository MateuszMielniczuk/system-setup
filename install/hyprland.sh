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
    fuzzel
  echo "Hyprland packages installed successfully."
}
