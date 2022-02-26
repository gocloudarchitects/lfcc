# source openstack credentials
source /etc/kolla/admin-openrc.sh

# get admin project id and default secgroup id
ADMIN_PROJECT_ID=$(openstack project list | awk '/ admin / {print $2}')
ADMIN_SEC_GROUP=$(openstack security group list --project ${ADMIN_PROJECT_ID} | awk '/ default / {print $2}')

# increase project quota
openstack quota set --instances 40 ${ADMIN_PROJECT_ID}
openstack quota set --cores 40 ${ADMIN_PROJECT_ID}
openstack quota set --ram 96000 ${ADMIN_PROJECT_ID}

# configure default security group
openstack security group rule create --ingress --ethertype IPv4 --protocol icmp ${ADMIN_SEC_GROUP}
openstack security group rule create --ingress --ethertype IPv4 --protocol tcp --dst-port 22 ${ADMIN_SEC_GROUP}
openstack security group rule create --ingress --ethertype IPv4 --protocol tcp --dst-port 8000 ${ADMIN_SEC_GROUP}
openstack security group rule create --ingress --ethertype IPv4 --protocol tcp --dst-port 8080 ${ADMIN_SEC_GROUP}

# configure neutron tenant network
openstack router create demo-router
openstack network create tenant-net
openstack subnet create --subnet-range 10.0.0.0/24 --network tenant-net --gateway 10.0.0.1 --dns-nameserver 8.8.8.8 tenant-subnet
openstack router add subnet demo-router tenant-subnet

# configure neutron provider network
openstack network create --external --provider-physical-network physnet1 --provider-network-type flat provider-net
openstack subnet create --dhcp --allocation-pool start=192.168.6.100,end=192.168.6.199 --network provider-net --subnet-range 192.168.6.0/24 --gateway 192.168.6.1 provider-subnet
openstack router set --external-gateway provider-net demo-router

# configure bridge to access provider network
sudo cat << EOF > /etc/netplan/60-provider.yaml
network:
  version: 2
  renderer: networkd
  bridges:
    br-ex:
      addresses:
      - 192.168.6.1/24
EOF
sudo netplan apply

# create keypair
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
fi
if [ -r ~/.ssh/id_rsa.pub ]; then
    openstack keypair create --public-key ~/.ssh/id_rsa.pub default-keypair
fi

# create glance image
mkdir ~/images
curl --fail -L -o ~/images/cirros-0.5.1-x86_64-disk.img
openstack image create --disk-format qcow2 --container-format bare --public --property os_type=cirros --file ~/images/cirros-0.5.1-x86_64-disk.img

# create flavors
openstack flavor create --id 1 --ram 512 --disk 1 --vcpus 1 m1.tiny
openstack flavor create --id 2 --ram 2048 --disk 20 --vcpus 1 m1.small
openstack flavor create --id 3 --ram 4096 --disk 40 --vcpus 2 m1.medium
openstack flavor create --id 4 --ram 8192 --disk 80 --vcpus 4 m1.large
openstack flavor create --id 5 --ram 16384 --disk 160 --vcpus 8 m1.xlarge


# create demo instance
openstack server create --flavor m1.tiny --image cirros --network tenant-net --key-name default-keypair demo-server
