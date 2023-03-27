#!/bin/bash

echo "* Add hosts ..."
echo "192.168.99.100 docker.do1.lab docker" >> /etc/hosts

echo "* Install Additional Packages ..."
apt-get install -y jq tree git vim