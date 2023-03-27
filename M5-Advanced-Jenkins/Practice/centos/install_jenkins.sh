#!/bin/bash

echo "* Add and import the repository key"
wget https://pkg.jenkins.io/redhat/jenkins.repo -O /etc/yum.repos.d/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key

echo "* Update repositories and install components"
dnf update
dnf install -y java-17-openjdk jenkins git

echo "* Start the service"
systemctl enable --now jenkins

echo "* Adjust the firewall"
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

echo "* admin password is:"
cat /var/lib/jenkins/secrets/initialAdminPassword