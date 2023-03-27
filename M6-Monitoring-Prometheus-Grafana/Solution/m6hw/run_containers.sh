#!/bin/bash

echo "* Start the Prometheus container"
docker container run -d --name prometheus -p 9090:9090 --mount type=bind,source=/vagrant/prometheus.yml,destination=/etc/prometheus/prometheus.yml prom/prometheus 

echo "* Start the Grafana container"
docker container run -d --name grafana -p 3000:3000 grafana/grafana

echo "* Start the two application containers"
docker container run -d --name worker1 -p 8081:8080 shekeriev/goprom 
docker container run -d --name worker2 -p 8082:8080 shekeriev/goprom 

echo "* Start the two application work generators"
/vagrant/runner.sh http://localhost:8081 &> /tmp/runner8081.log &
/vagrant/runner.sh http://localhost:8082 &> /tmp/runner8082.log &
