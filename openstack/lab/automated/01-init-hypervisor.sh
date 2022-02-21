#!/bin/bash

source /etc/os-release
if [ $ID != 'ubuntu' ]; then
  echo "This script is designed to run on an Ubuntu system configured with NetworkManager."
  echo "Please verify the steps and manually run them if on another system."
  exit 1
elif [ $(whoami) != "root" ]; then
  echo "You must run this script as root"
  exit 1
fi

# install necessary tools
apt install net-tools bridge-utils -y

# optimize virtualized networks
cat << EOF > /etc/sysctl.d/50-kvm-bridging.conf
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
EOF

# apply changes
sysctl -p /etc/sysctl.d/50-kvm-bridging.conf

# create API interfaces
nmcli connection add type bridge ifname br-api con-name br-api ipv4.method manual ipv4.addresses 192.168.5.1/24
nmcli connection add type dummy ifname dummy-api con-name dummy-api master br-api

# OPTIONAL: commands to create provider bridge 
# nmcli connection add type bridge ifname br-provider con-name br-provider ipv4.method manual ipv4.addresses 10.0.2.1/24
# ncmli connection add type dummy ifname dummy-provider con-name dummy-provider master br-provider

