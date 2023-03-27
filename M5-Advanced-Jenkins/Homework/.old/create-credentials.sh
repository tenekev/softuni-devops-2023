#!/bin/bash

id=$1
user_name=$2
user_pass=$3

cat <<EOF | ssh -o StrictHostKeyChecking=no -p 6666 admin@192.168.99.101 create-credentials-by-xml system::system::jenkins _
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
<scope>GLOBAL</scope>
  <id>${id}</id>
  <description>${name} username and password pair</description>
  <username>${name}</username>
  <password>${user_pass}</password>                                                                                                             
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
