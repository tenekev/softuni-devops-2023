#!/bin/bash

echo "* Add required packages"
apt-get install -y ca-certificates curl gnupg lsb-release

echo "* Add repository key"
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "* Add the Docker repository"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "* Install the packages"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "* Adjust the group membership"
usermod -aG docker vagrant