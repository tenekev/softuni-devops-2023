FROM ubuntu:20.04

RUN apt-get update -y 
RUN env DEBIAN_FRONTEND=noninteractive apt-get install -y apache2

ADD index.html /var/www/html/

RUN chown -R www-data:www-data /var/www

ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
