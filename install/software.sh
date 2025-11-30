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
  manjaro)
    install_manjaro
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
  sudo zypper install -y vlc clementine
  
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

install_manjaro() {
  echo "Installing software for Manjaro..."
  
  # Graphics and Design
  sudo pacman -Syu --noconfirm gimp inkscape
  
  # Browsers
  sudo pacman -Syu --noconfirm firefox chromium
  
  # Brave Browser (from AUR)
  if command -v yay &> /dev/null; then
    yay -S --noconfirm brave-bin
  else
    echo "⚠️  Warning: yay not found. Install yay to get Brave browser from AUR."
  fi
  
  # Communication
  sudo pacman -Syu --noconfirm discord
  
  # Media Players
  sudo pacman -Syu --noconfirm vlc clementine
  
  # Utilities
  sudo pacman -Syu --noconfirm gparted keepassxc
  
  # Music Streaming (Spotify - via AUR)
  if command -v yay &> /dev/null; then
    yay -S --noconfirm spotify
  else
    echo "⚠️  Warning: yay not found. Install Spotify manually or via Flatpak."
  fi
  
  # Development Tools
  sudo pacman -Syu --noconfirm code
  
  # Syncthing - File Synchronization
  sudo pacman -Syu --noconfirm syncthing
  sudo systemctl enable --now syncthing@$USER.service
  
  echo "Software installed successfully on Manjaro."
}

install_debian() {
  echo "Installing software for Debian/Ubuntu..."
  sudo apt update
  
  # Check if snap is available, otherwise use flatpak
  if command -v snap &> /dev/null || sudo apt install -y snapd &> /dev/null; then
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
  sudo apt install -y vlc clementine
  
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