# log in into server via ssh: ssh <root>@<server_ip> and provide password
# setup ssh key from your local machine to server
# copy ssh key to server: ssh-copy-id <root>@<server_ip> on your local machine

apt update
apt upgrade -y

read -p 'Provide your username: ' user_name
# create new user created with home directory and bash shell
useradd -m -s /bin/bash $user_name

su -
apt install sudo -y

usermod -aG sudo $user_name

sudo su - $user_name

# ======================== install docker and docker-compose
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
# INFO replace bookworm with the latest Debian version
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add your user to the docker group - no sudo needed
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# ======================== end of docker and docker-compose installation

# github setup
sudo apt install git-all -y

read -p 'Provide github user email: ' github_email
git config --global user.email $github_email
read -p 'Provide github username: ' github_username
git config --global user.name $github_username

# create ssh key
ssh-keygen -t ed25519 -C $github_email
# add ssh password
# add public key to github

# Update and install syncthing:
sudo apt-get update
sudo apt-get install syncthing -y

sudo systemctl enable --now syncthing@$USER.service

# to get access locally to server's syncthing web interface use ssh tunnelling
# ssh -L <port_local>:127.0.0.1:<port_server> <server_ip>

# ======================= install flatpak to get more recent sandboxed software

sudo apt install flatpak

# ================= add ssh key from host ===============

ssh-keygen -t ed25519 -C "server_name"
# add ssh password
ssh-copy-id -i /path/to/your/public_key.pub server_username@server_ip

# ======================== SECURITY HARDENING ========================

# 1. Configure iptables and ufw. Set max login attempts.

# Disable root login
vim /etc/ssh/sshd_config
# set this line to no and add allowed users by space
PermitRootLogin no
AllowUsers "$user_name"

# ======================== optional settings ========================
# additionally you can specify below options for more security

# Only allow key-based authentication
# remeber to add your shh key to the server before disabling password authentication
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey

# Disable empty passwords
PermitEmptyPasswords no

# Limit login attempts
MaxAuthTries 4
LoginGraceTime 60

# This setting is a security measure designed to protect
# the SSH server from denial-of-service (DoS) attacks.
# By limiting the number of unauthenticated connections,
# it prevents an attacker from overwhelming the server with
# a large number of connection attempts, which could consume
# resources and prevent legitimate users from connecting.
MaxStartups 10:30:60
# Keep the connection alive by sending periodic messages
# between the client and server. This helps to prevent
# the connection from being dropped due to inactivity.
ClientAliveInterval 300

# Restart SSH service to apply changes
sudo systemctl restart sshd

echo "SSH service restarted. Test your connection before closing this session!"
