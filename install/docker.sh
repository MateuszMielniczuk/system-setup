#!/bin/bash

install_docker() {
  local distro="$1"

  echo "Installing Docker on ${distro}..."

  # System-specific installations
  case "$distro" in
  opensuse-tumbleweed)
    install_suse
    ;;
  manjaro|catchyos|arch)
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
  echo "Installing Docker for openSUSE Tumbleweed..."
  sudo zypper install -y docker docker-compose
  sudo systemctl enable --now docker
  sudo usermod -aG docker $"USER"
  newgrp docker
}

install_arch() {
  echo "Installing Docker for Arch-based systems..."
  sudo pacman -Syu --noconfirm docker docker-compose
  sudo systemctl enable --now docker.service
  sudo usermod -aG docker $"USER"
  newgrp docker
}

install_debian() {
  echo "Installing Docker for Debian/Ubuntu..."

  sudo apt-get update
  sudo apt-get install -y ca-certificates curl

  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
    Types: deb
    URIs: https://download.docker.com/linux/debian
    Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
    Components: stable
    Signed-By: /etc/apt/keyrings/docker.asc
EOF

  sudo apt update

  sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo groupadd docker
  sudo systemctl enable --now docker
  sudo usermod -aG docker $"USER"
  newgrp docker
}

