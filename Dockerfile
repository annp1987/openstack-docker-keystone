FROM ubuntu:20.04

EXPOSE 5000 
ENV KEYSTONE_ADMIN_PASSWORD abc123
ENV CONTROLLER localhost
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get install -y keystone apache2 libapache2-mod-wsgi-py3 python3-openstackclient
RUN mkdir -p /etc/keystone
COPY keystone.conf /etc/keystone/keystone.conf
COPY bootstrap.sh /bootstrap.sh
CMD sh -x /bootstrap.sh
