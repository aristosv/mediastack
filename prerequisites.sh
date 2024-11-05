#!/bin/bash

# update
echo "updating system..."
commands=("apt update; apt -y upgrade; apt dist-upgrade; apt -y autoclean; apt -y autoremove")
for cmd in "${commands[@]}"; do eval "$cmd" > /dev/null 2> /dev/null || echo "error during ${cmd%%;*}"; done

# curl
echo "installing curl..."
apt install -y curl > /dev/null 2>&1 || echo "an error occurred during curl installation"

# docker
echo "installing docker..."
curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null 2>&1 && sh ./get-docker.sh > /dev/null 2>&1 && rm get-docker.sh > /dev/null 2>&1

# compose
echo "installing compose..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sh -c "curl -s -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
chmod +x /usr/local/bin/docker-compose
sh -c "curl -s -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"

# network
echo "creating docker network..."
docker network create -d bridge network > /dev/null 2>&1 || echo "error creating docker network"

# user
echo "creating docker user..."
adduser --disabled-password --gecos "" containers > /dev/null 2>&1 || { echo "error creating user"; }
echo containers:containers | chpasswd > /dev/null 2>&1 || { echo "error setting password"; }
usermod -aG docker containers > /dev/null 2>&1 || { echo "error adding user to docker group"; }

# directories
echo "creating directories..."
mkdir -p /mnt/realdebrid /mnt/symlinks/downloads/complete/{radarr,sonarr}
chown -R containers:containers /mnt/{realdebrid,symlinks/downloads/complete/{radarr,sonarr}}
