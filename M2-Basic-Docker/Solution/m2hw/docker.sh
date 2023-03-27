#!/bin/bash

echo "* Update packages ..."
apt-get update -y && apt-get upgrade -y

echo "* Install additional software ..."
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

echo "* Install the repository key ..."
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

echo "* Add the repository ..."
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

echo "* Install the software ..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "* Add the vagrant user to the docker group ..."
usermod -aG docker vagrant
