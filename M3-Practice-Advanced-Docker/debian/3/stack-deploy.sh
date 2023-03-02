#!/bin/bash

echo "* Deploying stack"

echo '12345' | docker secret create db_root_password -

docker stack deploy -c /vagrant/docker/docker-compose-swarm.yaml diabetes