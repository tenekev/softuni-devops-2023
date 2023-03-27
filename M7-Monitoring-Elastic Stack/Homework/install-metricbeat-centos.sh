#!/bin/bash

echo "* Download the package"
wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-8.1.0-x86_64.rpm

echo "* Install the package"
rpm -Uvh metricbeat-8.1.0-x86_64.rpm

echo "* Deploy configuration"
cp -v /vagrant/metricbeat.yml /etc/metricbeat/metricbeat.yml

echo "* Enable the system module"
metricbeat modules enable system

echo "* Install index template"
metricbeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["192.168.99.101:9200"]'

echo "* Enable and start the beat"
systemctl daemon-reload
systemctl enable --now metricbeat
