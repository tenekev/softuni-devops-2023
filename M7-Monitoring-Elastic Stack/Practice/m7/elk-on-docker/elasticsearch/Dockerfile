FROM openjdk:17

# Initially taken from https://github.com/aboullaite/docker-elk

ENV DEBIAN_FRONTEND noninteractive

ENV ELASTICSEARCH_VERSION 8.6.2
# Add esuser to avoid starting Elasticsearch as the root user.
RUN useradd -d /home/esuser -m esuser
WORKDIR /home/esuser

RUN mkdir /data

# Install Elastisearch
RUN \
curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}-linux-x86_64.tar.gz --output elasticsearch.tar.gz && \
tar xvzf elasticsearch.tar.gz && \
rm -f elasticsearch.tar.gz && \
chown -R esuser:esuser elasticsearch-${ELASTICSEARCH_VERSION}

# elasticsearch.yml and Dockerfile are on same location
ADD elasticsearch.yml /home/esuser/elasticsearch-${ELASTICSEARCH_VERSION}/config/elasticsearch.yml
ENTRYPOINT elasticsearch-${ELASTICSEARCH_VERSION}/bin/elasticsearch
