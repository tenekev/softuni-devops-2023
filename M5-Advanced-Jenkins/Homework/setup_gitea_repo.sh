#!/bin/bash

github_repo="https://github.com/tenekev/softuni-devops-2023-demo-website"

jenkins_host="192.168.99.101"

g_project_name="diabetes"
g_user="$(jq -r '.username' /vagrant/credentials/gitea.json)"
g_pass="$(jq -r '.password' /vagrant/credentials/gitea.json)"



echo "* 📦 Downlading repo"
rm -rf "/vagrant/docker/$g_project_name"
git clone "$github_repo" "/vagrant/docker/$g_project_name" && cd "/vagrant/docker/$g_project_name"



echo "* ⬆️   Initializing Git"
git add . && git commit -m "Initial commit to Gitea"



echo "* ↪️   Pushing to Gitea"
git push -o repo.private=false "http://$g_user:$g_pass@localhost:3000/$g_user/$g_project_name"



echo "* 🪝   Checking for Webhooks"
webhooks=$(curl -s -X 'GET' "http://localhost:3000/api/v1/repos/$g_user/$g_project_name/hooks" \
  -H 'accept: application/json' \
  -H 'authorization: Basic '$(echo -n "$g_user:$g_pass" | base64) \
  -H 'Content-Type: application/json' )
webhooks_lenght=${#webhooks}

if [ $webhooks_lenght -le 5 ]; then
  
  echo '* 🪝❌ No webhooks! Creating Webhook!';
  curl -S -s -o /dev/null -X 'POST' "http://localhost:3000/api/v1/repos/$g_user/$g_project_name/hooks" \
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