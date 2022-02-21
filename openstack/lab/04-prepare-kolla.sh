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
pip install git+https://opendev.org/openstack/kolla-ansible@master || pip install git+https://github.com/openstack/kolla-ansible@master
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master || pip install git+https://github.com/openstack/python-openstackclient


# copy example files into place
cp -r ~/venv/kolla/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp ~/venv/kolla/share/kolla-ansible/ansible/inventory/* .

