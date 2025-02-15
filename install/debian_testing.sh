#!/usr/bin/env bash
# download Debian stable ISO from debian.org main site
# Run installer and pick expert install
# INFO choose language
# select language, location, keyboard, etc, additional locales -> none
# INFO Access software for a blind porson using a raille display
# SKIP
# INFO Configure the keyboard -> your keyboard  layout
# INFO Detect and mount installation media -> follow instructions
# INFO Load installer components from installation media -> continue
# INFO Configure the network detected network hardware -> continue
# set hostname - personal computer name
# Allow login as root -> no
# domain name and root password(this will add sudo) - leave blank
# set unername add password
# INFO Configure the clock -> Set the clock using NTP? -> Yes -> your timezone
# INFO Detect disks -> yes
# INFO Partition disk -> btfrs
# skip scanning extra media -> no
# Unselect graphical desktop environment(space) and leave only standard system utilities
# install GRUB to the master boot record - yes /dev/vda or other
# restart system
# install git `sudo apt install git-all -y`
# mkdir projects && cd projects
# connect github to git 'git config --global user.email "your_email@example.com"'
# 'git config --global user.name github_username'
# create ssh key ssh-keygen -t ed25519 -C "your_email@example.com"
# git clone git@github:MateuszMielniczuk/system_setup.git

# install access to apt-add-repository
sudo apt update
sudo apt install software-properties-common -y
# backup sources.list
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo 'sources.list backed up to sources.list.bak'
echo 'provide Debian distro name to use in sources.list: bookworm, bullseye, buster etc'
read -p 'Enter distro name : ' distro_name
# use sed to replace all instances of Debian distro name with testing or sid
sudo sed -i 's/'$distro_name'/sid/g' /etc/apt/sources.list

sudo apt-add-repository contrib non-free-firmware -y

# update system and install graphical desktop
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
# install GNOME desktop without all unnecessary apps
sudo apt install kde-plasma-desktop -y

# install GNOME desktop without all unnecessary apps
# sudo apt get install gnome-core -y
# sudo apt install flatpak gnome-software-plugin-flatpak -y
# sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo apt install flatpak plasma-discover-backend-flatpak kde-config-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo apt install synaptic -y
sudo apt install neofetch -y
sudo apt install kitty -y
sudo apt install gparted -y

# TODO add fonts and other conf for nvim
sudo apt install neovim -y

# install docker and docker-compose
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
# INFO replace bookworm with the latest Debian version
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $distro_name stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add your user to the docker group - no sudo needed
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

flatpak install -y $(flatpaks.txt)


# install syncthing
# # Add the release PGP keys to allow the system to check the packages authenticity
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg

# Add the "stable" channel to your APT sources:
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

# Update and install syncthing:
sudo apt-get update
sudo apt-get install syncthing -y

sudo systemctl enable --now syncthing@$USER.service

sudo reboot
