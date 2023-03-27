FROM openjdk:17

# Initially taken from https://github.com/aboullaite/docker-elk

ENV DEBIAN_FRONTEND noninteractive

ENV KIBANA_VERSION 8.6.2
# Add kbuser to avoid starting Kibana as the root user.
RUN useradd -d /home/kbuser -m kbuser
WORKDIR /home/kbuser

# Install Kibana
RUN \
curl https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz --output kibana.tar.gz && \
tar xvzf kibana.tar.gz && \
rm -f kibana.tar.gz && \
chown -R kbuser:kbuser kibana-${KIBANA_VERSION}

# Kibana.yml and Dockerfile are on same location
ADD kibana.yml kibana-${KIBANA_VERSION}/config/kibana.yml
ENTRYPOINT kibana-${KIBANA_VERSION}/bin/kibana
