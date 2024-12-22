FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install apache2 -y && \
    apt install php php-mysql -y

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]