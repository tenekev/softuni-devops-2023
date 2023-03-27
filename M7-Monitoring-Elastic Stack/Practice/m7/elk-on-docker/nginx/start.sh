#!/bin/bash

# Wait for ElasticSearch to become available
while true; do 
  echo 'Trying to connect to elasticsearch:9200 ...'; 
  if [ $(curl -s -o /dev/null -w "%{http_code}" http://elasticsearch:9200) == "200" ]; then 
    echo '... connected.'; 
    echo 'Sleep for another 30s for ElasticSerach to calm down';
    sleep 30;
    break; 
  else 
    echo '... no success. Sleep for 5s and retry.'; 
    sleep 5; 
  fi 
done

# Install the index template
filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["elasticsearch:9200"]'

# Start the FileBeat component
/etc/init.d/filebeat start

# Start NGINX
nginx

# Follow the logs and show them on the STDOUT
tail -f /var/log/nginx/access.log -f /var/log/nginx/error.log
