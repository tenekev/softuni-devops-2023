#!/bin/bash

token=$(cat "/vagrant/swarm_token")

self=$1
manager=$2

echo "* Joining swarm ${token:0:50} ..."

docker swarm join --token $token --advertise-addr $self $manager:2377