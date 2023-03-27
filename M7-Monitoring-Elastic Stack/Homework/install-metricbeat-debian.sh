#!/bin/bash

echo "* Download the package"
wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-8.1.0-amd64.deb

echo "* Install the package"
sudo dpkg -i metricbeat-8.1.0-amd64.deb

echo "* Deploy configuration"
cp -v /vagrant/metricbeat.yml /etc/metricbeat/metricbeat.yml

echo "* Enable the system module"
metricbeat modules enable system

echo "* Enable and start the beat"
systemctl daemon-reload
systemctl enable --now metricbeat

echo '* Create the Index Pattern ...'
curl -X POST http://server:5601/api/index_patterns/index_pattern  -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"index_pattern": {"title": "metricbeat-*", "timeFieldName":"@timestamp"}}'
