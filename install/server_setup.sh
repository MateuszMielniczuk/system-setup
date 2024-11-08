# log in into server via ssh: ssh <root>@<server_ip> and provide password
# setup ssh key from your local machine to server
# copy ssh key to server: ssh-copy-id <root>@<server_ip> on your local machine

apt update
apt upgrade -y

read -p 'Provide your username' user_name
useradd $user_name

su -
apt install sudo -y

usermod -aG sudo $user_name

sudo su - $user_name

read -p 'Enter distro name : ' distro_name

# ======================== install docker and docker-compose
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
# INFO replace bookworm with the latest Debian version
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
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
# add public key to github
