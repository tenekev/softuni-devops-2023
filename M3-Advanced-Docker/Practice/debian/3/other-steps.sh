#!/bin/bash

echo "* Add hosts ..."
echo "192.168.99.101 docker1.do1.lab docker1" >> /etc/hosts
echo "192.168.99.102 docker2.do1.lab docker2" >> /etc/hosts
echo "192.168.99.103 docker3.do1.lab docker3" >> /etc/hosts

echo "* Install Additional Packages ..."
apt-get install -y jq tree git

echo "* Cleanup ..."
apt-get autoclean -y