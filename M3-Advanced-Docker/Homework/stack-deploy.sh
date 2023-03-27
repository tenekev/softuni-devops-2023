#!/bin/bash

stack_name=diabetes


echo "* Deploying stack $stack_name"

echo '12345' | docker secret create db_root_password -

docker stack deploy -c /vagrant/docker/docker-compose-swarm.yaml $stack_name

echo "* Removing temp token file"

#rm -f /vagrant/swarm_token