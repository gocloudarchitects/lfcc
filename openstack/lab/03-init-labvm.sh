#!/bin/bash

# check if root, else exit
if [ $(whoami) != "root" ]; then
  echo "You must run this script as root"
  exit 1
fi

# install required packages
apt-get update
apt-get upgrade -y
apt-get install -y python3-dev libffi-dev gcc libssl-dev python3-venv net-tools bridge-utils

# prep ansible config
mkdir /etc/ansible
cat << EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
EOF

# create kolla directory
mkdir -p /etc/kolla
chown vagrant.vagrant /etc/kolla

# prep hard drive for cinder volumes
pvcreate /dev/sdc
vgcreate cinder-volumes /dev/sdc

