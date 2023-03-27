#!/bin/bash

# !!!!! Dependent on: apt-get install -y jq 
g_user="$(jq -r '.username' /vagrant/credentials/gitea.json)"
g_pass="$(jq -r '.password' /vagrant/credentials/gitea.json)"


echo "* Deploying Gitea Stack"
docker compose -f /vagrant/docker/docker-compose.yml up --force-recreate -d


echo "Waiting for Gitea:"
while true; do
  url=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
  if [ $url == "200" ]; then
    echo 'Connected!';
    break;
  else
    echo 'Waiting...';
    sleep 5;
  fi
done


echo "Adding a Gitea User"
docker container exec -u 1000 gitea gitea admin user create --username "$g_user" --password "$g_pass" --email "$g_user@testmail.com"