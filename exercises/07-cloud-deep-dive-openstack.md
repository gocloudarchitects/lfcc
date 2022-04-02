# Cloud Deep Dive: OpenStack

## Configure and Install OpenStack Lab

Set up the lab using the files provided in this repository, according to the lesson.


## OpenStack Architecture and Workflow

Open two ssh sessions to the OpenStack lab.  In one, tail the logs for a service, and then run commands against that service.  You should be able to see it respond.

You can do this exercise alongside upcoming exercises in which we create resources, but here is an example with Neutron.

```bash
# in one shell
tail -f /var/log/kolla/neutron/*.log
# in the other shell
openstack network create test-net
openstack subnet create --subnet-range 192.168.99.0/24 --network test-net test-subnet
openstack network delete test-net
```

## Environment Management

Some of these upcoming exercises may put your system in a bad state. Even if they do not, we will want to revert to a clean environment later.  You are free to manually delete resources after creating them, but you may prefer an easier way to revert.

Familiarize yourself with the autostack setup, and possibly take snapshots as you reach various points so that you can revert and try other options.


## Admin: Security Groups

1. Create the security groups from this exercise, while tailing neutron logs.

2. Try deleting a security group rule from the mysql database, and then list the rules.  Is the change to the database reflected in the command output?

   **NOTE:** You don't want to directly mess with mysql in a production environment unless absolutely necessary. The mysql syntax for this would be `delete from <table> where id = '<id>';`


## Admin: Network Resources

1. Create the network resources from this exercise, while tailing neutron logs.

2. Review [Section 4.4 from Red Hat's OpenStack Networking Guide for RHOSP16.2](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.2/html/networking_guide/connect-instance_rhosp-network#how-does-flat-packet-flow-work_connect-instance) for a diagram of the network flow, from instance to egress.

3. Bookmark the official [OpenStack Networking Guide](https://docs.openstack.org/neutron/yoga/admin/). If you don't know what the topics are, google them.  SR-IOV, DPDK, BGP, and Trunking are all technologies you are likely to encounter at least in passing in a cloud career.


## Admin: Keypairs, Images, Flavors

Create the resources and tail the appropriate logs.  For keypairs and flavors, tail nova logs.  For images, tail glance logs.


## Admin: Instances and Tenant Networking

Create the resources from this exercise, tailing the appropriate logs.  Try the following:

```bash
tail -f  /var/log/kolla/neutron/neutron-server.log /var/log/kolla/nova/nova-{scheduler,api,compute}.log /var/log/kolla/glance/glance-api.log
```

## Admin: User Data and Volumes

1. Create the resources from this exercise, tailing the nova and cinder logs.

2. Write a user-data file and launch an ubuntu server:
   - /etc/motd should contain the message "This is a private server, authorized access only!"
   - install and enable apache2
   - enable ufw, allow ssh, allow port 80

