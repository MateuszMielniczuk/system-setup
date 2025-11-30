#!/bin/bash

install_coding() {
  local distro="$1"

  echo "Setting up coding environment for ${distro}..."

  # System-agnostic installations
  install_terminal
  install_fonts
  install_starship
  install_python_tools

  # System-specific installations
  case "$distro" in
  opensuse-tumbleweed)
    install_packages_suse
    ;;
  manjaro)
    install_packages_manjaro
    ;;
  ubuntu | debian)
    install_packages_debian
    ;;
  *)
    echo "❌ Error: Coding environment installation for '${distro}' is not supported."
    return 1
    ;;
  esac

  echo "✓ Coding environment setup completed successfully!"
}

install_python_packages() {
  echo "Installing Python packages..."
  sudo curl -LlSf https://astral.sh/uv/install.sh | sh
  echo "Python packages installed successfully."
}

install_terminal() {
  echo "Installing kitty terminal"
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  # your system-wide PATH)
  ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
  # Place the kitty.desktop file somewhere it can be found by the OS
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
  # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
  cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
  # Update the paths to the kitty and its icon in the kitty desktop file(s)
  sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
  # Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
  echo 'kitty.desktop' >~/.config/xdg-terminals.list
  echo "kitty terminal installed and configured successfully"
}

install_starship() {
  echo "Installing Starship prompt..."
  sudo curl -sS https://starship.rs/install.sh | sh -s -- --yes
  echo "Starship prompt installed successfully."
}

install_fonts() {
  echo "Installing fonts..."
  mkdir -p ~/.local/share/fonts
  get_font() {
    wget -P ~/.local/share/fonts "$1"
    unzip -o ~/.local/share/fonts/"$(basename "$1")" -d ~/.local/share/fonts
    rm ~/.local/share/fonts/"$(basename "$1")"
  }

  # Download and install FiraCode Nerd Font Mono
  FIRA_FONT="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraMono.zip"
  JETBRAINS_MONO_FONT="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"

  get_font "$FIRA_FONT"
  get_font "$JETBRAINS_MONO_FONT"
  echo "Refreshing fonts cache"
  fc-cache -fv
  echo "Fonts installed successfully"
}

install_packages_debian() {
  echo "Installing coding packages for Debian systems"
  install_stow_debian
  install_node_debian
  install_nvim_debian
}

install_packages_manjaro() {
  echo "Installing coding packages for Manjaro"
  install_stow_manjaro
  install_node_manjaro
  install_nvim_manjaro
}

install_packages_suse() {
  echo "Installing coding packages for openSUSE"
  install_stow_suse
  install_node_suse
  install_nvim_suse
}

install_node_debian() {
  echo "Download and install nvm -> check if latest version:"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  # in lieu of restarting the shell
  \. "$HOME/.nvm/nvm.sh"
  # Download and install Node.js:
  nvm install 24
  echo "Node and npm packages installed successfully."
}

install_node_suse() {
  echo "Installing Node.js for openSUSE Tumbleweed..."
  sudo zypper install -y nodejs npm
  echo "Node.js installed successfully."
}

install_node_manjaro() {
  echo "Installing Node.js for Manjaro..."
  sudo pacman -S --noconfirm nodejs npm
  echo "Node.js installed successfully."
}

install_nvim_debian() {
  echo "Installing Neovim requirements for Debian..."
  sudo apt install -y \
    curl \
    fd-find \
    fzf \
    gcc \
    ripgrep \
    lazygit

  echo "Installing Neovim..."
  sudo apt install -y neovim
  echo "✓ Neovim installed successfully."
}

install_nvim_manjaro() {
  echo "Installing NVIM requirements..."
  sudo pacman -S --noconfirm \
    curl \
    fd \
    fzf \
    gcc \
    ripgrep \
    lazygit

  echo "Installing Neovim for Manjaro..."
  sudo pacman -S --noconfirm neovim
  echo "Neovim installed successfully."
}

install_nvim_suse() {
  echo "Installing NVIM requriements..."
  sudo zypper install -y \
    curl \
    fd \
    fzf \
    gcc \
    ripgrep

  echo "Installing Neovim for openSUSE Tumbleweed..."
  sudo zypper refresh
  sudo zypper ar https://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Factory/devel:languages:go.repo
  sudo zypper ref && sudo zypper in lazygit
  sudo zypper install -y neovim
  echo "Neovim installed successfully."
}

install_stow_debian() {
  echo "Installing Stow for Debian..."
  sudo apt install -y stow
  echo "✓ Stow installed successfully."
}

install_stow_manjaro() {
  echo "Installing stow for Manjaro..."
  sudo pacman -S --noconfirm stow
  echo "Stow installed successfully"
}

install_stow_suse() {
  echo "Installing stow for openSUSE Tumbleweed..."
  sudo zypper install -y stow
  echo "Stow installed successfully"
}
