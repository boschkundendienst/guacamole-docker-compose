#!/bin/sh

INSTALL_DIR=/srv/workfromhome-with-docker

# Update the apt package index
apt-get update

# Install packages to allow apt to use a repository over HTTPS
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    git

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Use the following command to set up the stable repository.
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update the apt package index.
apt-get update

# Install the latest version of Docker Engine - Community and containerd.
apt-get -y install docker-ce docker-ce-cli containerd.io 

# Download docker-compose
curl -SLo /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64"
chown root:root /usr/local/bin/docker-compose
chmod 0755 /usr/local/bin/docker-compose

# Clone workfromhome-with-docker git repo
mkdir -p $INSTALL_DIR
git clone https://github.com/andif888/workfromhome-with-docker.git $INSTALL_DIR

