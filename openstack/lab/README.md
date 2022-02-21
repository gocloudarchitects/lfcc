# Installing OpenStack All-In-One Lab with Kolla-Ansible

These instructions are derived from the [Kolla-Ansible Quickstart Guide](https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html).

There may be some minor changes in the install process with new releases,
so if you encounter problems, please review the project documentation.

# Configuration overview

This document is divided in sections:

1. Initialize the hypervisor
2. Provisiom the lab vm
3. Initialize the lab vm
4. Prepare Kolla-Ansible Virtual Environment
5. Configure and install OpenStack

The networking requires two interfaces.  For simplicity, we are using:
- 1x routed access network (managed by Vagrant)
- 1x Bridged API NIC to access the API from the Hypervisor
- 1x dummy NIC to access OpenStack provider networks from the Lab VM

The networking will look something like this:

~~~
    +--------------------------------+
    |                                |
    |        OpenStack Lab VM        |
    |                                |
    +--------+----------+------------+
    | NIC1   |  NIC2    | NIC3       |
    | Access |  API     | Provider   |
    | NAT    |  Bridged | dummy NIC  |
    +----+---+-------+--+------------+
         |           |
         |           |
         |           |
         |           |
    +----+-----+-----+-----+
    | virtual  | Bridge    |
    | router   | br-api    |
    +----------|-----------|--------+
    |    ↓     | dummy NIC |        |
    |    ↓     +-----------+        |
    |    ↓                          |
    |    ↓     Hypervisor           |
    |    ↓                          |
    +-------------+-----------------+
    |External NIC |
    +-----+-------+
          |
          +----------->> To Internet
~~~

It is possible to configure external access to the API and provider networks,
but there are too many variables to address here.

## Initialize the Hypervisor

This section is for a Linux system using provisioning on Virtualbox with 
Vagrant.  If you are using another operating system, you will need to 
create the necessary resources according to that system.

The specific commands I use are in the `init-hypervisor.sh` script.

- install necessary tools
- set kernel parameters to optimize networking
- create a bridge and dummy interface for the API
- set an IP

## Provision the Lab VM

There is a Vagrantfile provided that will provision the lab VM according to
the required specification.

- CPUs: 2 (would prefer 4+ if you have enough cores)
- RAM: 8GB
- HDD:
  - Main HDD 40GB
  - (Optional) Additional 20GB HDD for Cinder volumes
- Network:
  - 1 public (bridged) NIC connecting the hypervisor API bridge
  - 1 dummy NIC, not connected to the hv

## Initialize the Lab VM

This covers the preparation of the Lab VM, and is where the Kolla-Ansible
documentation begins.

The specific commands I use are in the `init-labvm.sh` script.

- Install required system packages
- Prep ansible config
- (Optional) Create LVM pool for Cinder volumes

## Prepare Kolla-Ansible Environment

These steps are all from Kolla documentation. Specific commands are in the
`prepare-kolla.sh` script

- Create the venv
- Activate venv and install python packages
- Copy example files into place

## Configure and Install OpenStack

Most of these commands are in 

- Generate passwords
- Replace keystone admin password with something easy to remember (ok in lab)
- Edit globals.yaml (file provided)
- Run kolla-ansible preliminary steps
- Deploy
