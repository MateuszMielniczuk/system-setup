#!/usr/bin/env bash
# download Debian stable ISO from debian.org main site
# Run installer and pick normal install
# select language, location, keyboard, etc
# set hostname - personal computer name
# domain name and root password(this will add sudo) - leave blank
# set unername add password
# partition disk
# skip scanning extra media -> no
# Unselect graphical desktop environment(space) and leave only standard system utilities
# install GRUB to the master boot record - yes /dev/vda or other
# restart system
# install git `sudo apt install git-all -y`
# mkdir projects && cd projects
# git clone git@github:MateuszMielniczuk/system_setup.git
# connect github to git git config --global user.email "your_email@example.com"
# git config --global user.name github_username
# create ssh key ssh-keygen -t ed25519 -C "your_email@example.com"


# backup sources.list
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo 'sources.list backed up to sources.list.bak'
echo 'provide Debian distro name to use in sources.list: bookworm, bullseye, buster etc'
read -sp 'Enter distro name : 'dishro_name
# use sed to replace all instances of Debian distro name with testing or sid
sudo sed -i 's/$distro_name/testing/g' /etc/apt/sources.list

sudo apt install software-properties-common -y
sudo apt-add-repository contrib non-free-firmware -y

# update system and install graphical desktop
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
# install GNOME desktop without all unnecessary apps
sudo apt install gnome-core -y

sudo apt install flatpak gnome-software-plugin-flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

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



# flatpak install flathub com.spotify.Client -y
flatpak install flathub org.inkscape.Inkscape -y
flatpak install flathub org.gimp.GIMP -y
# flatpak install flathub org.strawberrymusicplayer.strawberry -y
flatpak install flathub org.clementine_player.Clementine -y
# vesktop is a Discord client for Wayland
flatpak install flathub dev.vencord.Vesktop -y
flatpak install flathub org.chromium.Chromium -y
flatpak install flathub com.brave.Browser -y
flatpak install flathub org.keepassxc.KeePassXC -y
flatpak install flathub org.filezillaproject.Filezilla -y
flatpak install flathub org.kde.kdenlive -y
flatpak install flathub org.darktable.Darktable -y
flatpak install flathub org.libreoffice.LibreOffice -y
flatpak install flathub org.videolan.VLC -y
flatpak install flathub io.dbeaver.DBeaverCommunity -y
flatpak install flathub com.visualstudio.code -y

sudo reboot
