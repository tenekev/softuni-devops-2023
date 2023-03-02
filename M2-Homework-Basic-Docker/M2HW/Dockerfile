FROM centos:centos7

LABEL maintainer="Radoslav" version="1.0"

RUN yum -y install epel-release

RUN yum -y update; yum -y install httpd; yum clean all

COPY web/ /var/www/html

ENTRYPOINT ["/usr/sbin/httpd","-D", "FOREGROUND"]

EXPOSE 80