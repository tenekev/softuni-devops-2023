#!/bin/bash

echo "192.168.99.201 pipelines.do1.exam pipelines" >> /etc/hosts
echo "192.168.99.202 containers.do1.exam containers" >> /etc/hosts
echo "192.168.99.203 monitoring.do1.exam monitoring" >> /etc/hosts

echo "* Install Additional Packages ..."
apt-get update
apt-get install -y jq tree git fontconfig openjdk-17-jre