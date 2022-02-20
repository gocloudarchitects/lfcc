FROM ubuntu:16.04
MAINTAINER Nathan Curry

RUN apt-get update && apt-get -y install python-openstackclient && apt clean all -y
CMD ["openstack"]
