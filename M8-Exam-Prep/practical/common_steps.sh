#!/bin/bash

echo "192.168.99.101 vm101.do1.exam vm101" >> /etc/hosts
echo "192.168.99.102 vm102.do1.exam vm102" >> /etc/hosts
echo "192.168.99.103 vm103.do1.exam vm103" >> /etc/hosts

echo "* Install Additional Packages ..."
apt-get update
apt-get install -y jq tree git fontconfig openjdk-17-jre