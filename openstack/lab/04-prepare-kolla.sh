#!/bin/bash
# ensure you are a regular user, else quit
if [ $(whoami) == "root" ]; then
  echo "You must run this script as your regular user"
  exit 1
fi

# create the virtual-env
mkdir ~/venv
python3 -m venv ~/venv/kolla

# activate venv and install packages
source ~/venv/kolla/bin/activate
pip install -U pip
pip install 'ansible==5.*'

# Install the 'Xena' release
pip install git+https://opendev.org/openstack/kolla-ansible@stable/xena || pip install git+https://github.com/openstack/kolla-ansible@stable/xena
# Install the latest (possibly development) version of Kolla-Ansible
# pip install git+https://opendev.org/openstack/kolla-ansible@master || pip install git+https://github.com/openstack/kolla-ansible@master
# Install known-good commit from 02/09/2022
# pip install git+https://github.com/openstack/kolla-ansible@556d979930bdb24c3ee46413f7b77584017b9206

pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master || pip install git+https://github.com/openstack/python-openstackclient

# copy example files into place
cp -r ~/venv/kolla/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp ~/venv/kolla/share/kolla-ansible/ansible/inventory/* .

# generate passwords, set admin password to `kolla`
kolla-genpwd
sed -i 's/^keystone_admin_password:.*$/keystone_admin_password: kolla/g' /etc/kolla/passwords.yml
