#!/bin/bash

install_software() {
  local distro="$1"

  echo "Setting up coding environment for ${distro}..."

  # System-agnostic installations

  # System-specific installations
  case "$distro" in
  opensuse-tumbleweed)
    install_suse
    ;;
  manjaro | cachyos | arch)
    install_arch
    ;;
  ubuntu | debian)
    install_debian
    ;;
  *)
    echo "❌ Error: Coding environment installation for '${distro}' is not supported."
    return 1
    ;;
  esac

  echo "✓ Coding environment setup completed successfully!"
}

install_suse() {
  echo "Installing software for openSUSE Tumbleweed..."

  # Install Flatpak
  sudo zypper install -y flatpak
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # Graphics and Design
  sudo zypper install -y gimp inkscape

  # Browsers
  sudo zypper install -y firefox chromium

  # Brave Browser
  # TODO: Add installation

  # Communication
  sudo zypper install -y discord

  # Media Players
  sudo zypper install -y vlc strawberry

  # Utilities
  sudo zypper install -y gparted keepassxc

  # Music Streaming (Spotify - via Flatpak)
  flatpak install -y flathub com.spotify.Client

  # Development Tools
  # TODO: Add installation

  # Syncthing - File Synchronization
  sudo zypper install -y syncthing
  sudo systemctl enable --now syncthing@$USER.service

  echo "Software installed successfully on openSUSE Tumbleweed."
}

install_arch() {
  echo "Installing software for Arch-based systems..."

  # NATIVE PACKAGES-----------

  # Graphics and Design
  sudo pacman -Syu --noconfirm gimp inkscape
  # Browsers
  sudo pacman -Syu --noconfirm firefox chromium okular
  # Communication
  sudo pacman -Syu --noconfirm thunderbird
  # Media Players
  sudo pacman -Syu --noconfirm vlc strawberry
  # Utilities
  sudo pacman -Syu --noconfirm gparted keepassxc discover
  # Development Tools
  sudo pacman -Syu --noconfirm dbeaver
  # Syncthing - File Synchronization
  sudo pacman -Syu --noconfirm syncthing
  sudo systemctl enable --now syncthing@$USER.service

  # PACKAGES FROM AUR ---------
  if command -v yay &>/dev/null; then
    sudo yay -S --noconfirm brave-bin
    sudo yay -S --noconfirm chrome
    sudo yay -S visual-studio-code-bin
  else
    echo "⚠️  Warning: yay not found. Install yay to get Brave browser from AUR."
  fi

  # FLATPAK PACKAGES-----------

  # Install Flatpak
  sudo pacman -S flatpak
  flatpak remote-add --if-not-exists flathub flathub.org
  # Install proprietary software
  flatpak install -y flathub com.spotify.Client
  flatpak install -y flathub com.discordapp.Discord
  flatpak install -y flathub com.getpostman.Postman
  flatpak install -y flathub com.superproductivity.SuperProductivity
  flatpak install -y flathub md.obsidian.Obsidian

  echo "Software installed successfully on Manjaro."
}

install_debian() {
  echo "Installing software for Debian/Ubuntu..."
  sudo apt update

  # Check if snap is available, otherwise use flatpak
  if command -v snap &>/dev/null || sudo apt install -y snapd &>/dev/null; then
    echo "Using Snap for package management..."
    USE_SNAP=true
  else
    echo "Snap not available, using Flatpak..."
    USE_SNAP=false
    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi

  # Graphics and Design
  sudo apt install -y gimp inkscape

  # Browsers
  sudo apt install -y firefox chromium-browser

  # Brave Browser
  echo "Add Brave script installation"

  # Communication
  sudo apt install -y discord

  # Media Players
  sudo apt install -y vlc strawberry

  # Utilities
  sudo apt install -y gparted keepassxc

  # Music Streaming (Spotify)
  if [ "$USE_SNAP" = true ]; then
    sudo snap install spotify
  else
    flatpak install -y flathub com.spotify.Client
  fi

  # Development Tools (VSCode)
  if [ "$USE_SNAP" = true ]; then
    sudo snap install code --classic
  else
    flatpak install -y flathub com.visualstudio.code
  fi

  # Syncthing - File Synchronization
  sudo apt install -y syncthing
  sudo systemctl enable --now syncthing@$USER.service

  echo "Software installed successfully on Debian/Ubuntu."
}
