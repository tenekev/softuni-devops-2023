#!/bin/bash

jenkins_host="192.168.99.101"
g_user="$(jq -r '.username' /vagrant/credentials/gitea.json)"
g_pass="$(jq -r '.password' /vagrant/credentials/gitea.json)"


echo "* 🪝   Checking for Webhooks"
webhooks=$(curl -s -X 'GET' "http://localhost:3000/api/v1/repos/$g_user/diabetes/hooks" \
  -H 'accept: application/json' \
  -H 'authorization: Basic '$(echo -n "$g_user:$g_pass" | base64) \
  -H 'Content-Type: application/json' )
lenght=${#webhooks}

if [ $lenght -le 5 ]; then
  
  echo '* 🪝❌ No webhooks! Creating Webhook!';
  curl -S -s -o /dev/null -X 'POST' "http://localhost:3000/api/v1/repos/$g_user/diabetes/hooks" \
    -H 'accept: application/json' \
    -H 'authorization: Basic '$(echo -n "$g_user:$g_pass" | base64) \
    -H 'Content-Type: application/json' \
    -d '{
            "active": true,
            "type": "gitea",
            "branch_filter": "*",
            "config": {
                "content_type": "json",
                "url": "http://'"$jenkins_host"':8080/gitea-webhook/post",
                "http_method": "post"
            },
            "events": [
                "push"
            ]
        }'
  
  echo '* 🪝✔️ Created Webhook!';
else
  
  echo '* 🪝✔️ Webhooks Present! Skipping!';
fi