#!/bin/bash

self=$1

echo "* Initializing swarm ..."

docker swarm init --advertise-addr $self

docker swarm join-token -q worker > /vagrant/swarm_token