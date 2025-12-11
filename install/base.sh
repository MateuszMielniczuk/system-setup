#!/bin/bash

install_base() {
  local distro="$1"

  echo "Installing Docker on ${distro}..."

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
    echo "❌ Error:  environment installation for '${distro}' is not supported."
    return 1
    ;;
  esac

  echo "✓ Coding environment setup completed successfully!"
}

install_suse() {
  echo "Nothing important to install for suse"
}

install_arch() {
  echo "installing base packages for arch-based systems..."
  # change default shell
  chsh --shell /bin/bash

  # appimage support
  sudo pacman -s fuse

  # set ufw rules for kde connect
  sudo ufw allow 1714:1764/udp
  sudo ufw allow 1714:1764/tcp
  sudo ufw reload

  # install yey
  sudo pacman -s --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

  # add udev rules for ledger
  wget -q -o - https://raw.githubusercontent.com/ledgerhq/udev-rules/master/add_udev_rules.sh | sudo bash
}

install_debian() {
  echo "Nothing important to install for debian."
}
