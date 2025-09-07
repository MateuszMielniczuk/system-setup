#!/bin/bash

# Detect Linux distribution
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO=$ID
else
  DISTRO="unknown"
fi

# Check for supported distributions
if [[ "$DISTRO" =~ ^(debian|ubuntu|linuxmint)$ ]]; then
  echo "Detected Debian/Ubuntu or derivative. Not supported yet."
  exit 1
elif [[ "$DISTRO" == "opensuse-tumbleweed" ]]; then
  echo "Detected openSUSE Tumbleweed."
else
  echo "Unsupported distribution: $DISTRO"
  exit 1
fi

read -p "Do you want to install terminal and coding tools? (y/n): " is_coding
# read -p "Do you want to install software? (y/n): " is_flatpack
# read -p "Do you want to install fonts? (y/n): " is_fonts
# read -p "Do you want to install Docker? (y/n): " ifDocker
# read -p "Do you want to install Virt Manager? (y/n): " ifQemu

if [[ "$is_coding" =~ ^[Yy]$ ]]; then
  if [[ -f install/coding.sh ]]; then
    source install/coding.sh
    install_coding "$DISTRO"
    ./push_config.sh
  else
    echo "install/coding.sh not found."
  fi
fi

# if [[ "$is_flatpack" =~ ^[Yy]$ ]]; then
#   echo "Installing flatpack software."
#   # Script 2 logic here
# fi
#
# if [[ "$is_fonts" =~ ^[Yy]$ ]]; then
#   echo "Adding fonts."
#   # Script 3 logic here
# fi
