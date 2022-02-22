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
pip install 'ansible<5.0'

# Install the 'Xena' release
pip install git+https://opendev.org/openstack/kolla-ansible@stable/xena || pip install git+https://github.com/openstack/kolla-ansible@stable/xena
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/xena || pip install git+https://github.com/openstack/python-openstackclient@stable/xena

# copy example files into place
cp -r ~/venv/kolla/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp ~/venv/kolla/share/kolla-ansible/ansible/inventory/* .

# generate passwords, set admin password to `kolla`
kolla-genpwd
sed -i 's/^keystone_admin_password:.*$/keystone_admin_password: kolla/g' /etc/kolla/passwords.yml
