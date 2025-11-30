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
elif [[ "$DISTRO" =~ ^(opensuse-tumbleweed|manjaro|catchyos|arch)$ ]]; then
  echo "Detected $DISTRO."
else
  echo "Unsupported distribution: $DISTRO"
  exit 1
fi

read -p "Do you want to install terminal and coding tools? (y/n): " is_coding
read -p "Do you want to install software? (y/n): " is_software
read -p "Do you want to install Docker? (y/n): " is_docker
read -p "Do you want to install Virt Manager? (y/n): " is_qemu

if [[ "$is_coding" =~ ^[Yy]$ ]]; then
  if [[ -f install/coding.sh ]]; then
    source install/coding.sh
    install_coding "$DISTRO"
    ./push_config.sh
  else
    echo "install/coding.sh not found."
  fi
fi

if [[ "$is_software" =~ ^[Yy]$ ]]; then
  echo "Installing flatpack software."
  if [[ -f install/software.sh ]]; then
    source install/software.sh
    install_software "$DISTRO"
  else
    echo "install/software.sh not found."
  fi
fi


if [[ "$is_docker" =~ ^[Yy]$ ]]; then
  echo "Installing Docker."
  if [[ -f install/docker.sh ]]; then
    source install/docker.sh
    install_docker "$DISTRO"
  else
    echo "install/docker.sh not found."
  fi
fi

# if [[ "$is_qemu" =~ ^[Yy]$ ]]; then
#   echo "Installing Virt Manager and QEMU."
#   if [[ -f install/qemu.sh ]]; then
#     source install/qemu.sh
#     install_qemu "$DISTRO"
#   else
#     echo "install/qemu.sh not found."
#   fi
# fi