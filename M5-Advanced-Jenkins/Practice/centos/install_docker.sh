#!/bin/bash

echo "* Add the Docker repository"
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "* Install the packages (Java, git, Docker)"
dnf install -y java-17-openjdk git docker-ce docker-ce-cli containerd.io

echo "* Start the Docker service"
systemctl enable --now docker

echo "* Adjust the group membership"
usermod -aG docker vagrant

echo "* Adjust the firewall"
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload