FROM openjdk:17

# Initially taken from https://github.com/aboullaite/docker-elk

ENV DEBIAN_FRONTEND noninteractive

ENV LOGSTASH_VERSION 8.6.2
# Add lsuser to avoid starting logstash as the root user.
RUN useradd -d /home/lsuser -m lsuser
WORKDIR /home/lsuser

# Install logstash
RUN \
curl https://artifacts.elastic.co/downloads/logstash/logstash-${LOGSTASH_VERSION}-linux-x86_64.tar.gz --output logstash.tar.gz && \
tar xvzf logstash.tar.gz && \
rm -f logstash.tar.gz && \
chown -R lsuser:lsuser logstash-${LOGSTASH_VERSION}


# logstash.conf and Dockerfile are on same location
ADD logstash.conf /home/lsuser
CMD logstash-${LOGSTASH_VERSION}/bin/logstash -f /home/lsuser/logstash.conf --verbose
