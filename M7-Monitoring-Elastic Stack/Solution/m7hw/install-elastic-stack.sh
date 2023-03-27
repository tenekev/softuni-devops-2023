#!/bin/bash

echo "* Import the repository key"
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

echo "* Register the repository"
cat > /etc/yum.repos.d/elasticsearch.repo <<EOF
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF

echo "* Install Elasticsearch, Logstash, and Kibana"
sudo dnf install --enablerepo=elasticsearch -y elasticsearch logstash kibana

echo "* Deploy configuration for Elasticsearch"
cp -v /vagrant/elasticsearch.yml /etc/elasticsearch/

echo "* Correct the Java heap size for Elasticsearch"
cat > /etc/elasticsearch/jvm.options.d/jvm.options <<EOF
-Xms1g
-Xmx1g
EOF
    
echo "* Create beats configuration for Logstash"
cat > /etc/logstash/conf.d/beats.conf << EOF
input {
  beats {
    port => 5044
  }
}
output {
  elasticsearch {
    hosts => ["http://server:9200"]
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}
EOF

echo "* Deploy configuration for Kibana"
cp -v /vagrant/kibana.yml /etc/kibana/

echo "* Start the services"
systemctl daemon-reload
systemctl enable --now elasticsearch
systemctl enable --now logstash
systemctl enable --now kibana

echo "* Open firewall ports"
sudo firewall-cmd --add-port 5044/tcp --permanent
sudo firewall-cmd --add-port 5601/tcp --permanent
sudo firewall-cmd --add-port 9200/tcp --permanent
sudo firewall-cmd --reload
