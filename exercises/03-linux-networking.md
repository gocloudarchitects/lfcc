# Linux Networking

## OpenSSH

1. Launch the VMs with the Vagrantfile at `vagrant/mixed_environment` and configure ssh communication between them. Note that one VM is Centos and the other is Ubuntu. Criteria:
   - each vagrant user should generate his own ed25519 key (instead of RSA)
   - each vagrant user should be able to connect to the other system's vagrant account
   - the vagrant user from the `centos` vm should be able to connect to the ubuntu user of the `ubuntu` vm

   Hint 1: To access the other VM, run `ip a` on each system and get the IP address from the 192.168.33.0/24 network.
   Hint 2: You can manually copy the SSH key, but don't paste it into a rich text editor while you're copying it. This can change the character encoding, which will break the key.

   Keep these VMs for the following networking exercises.

2. [OpenSSH Specifications](https://www.openssh.com/specs.html) - A listof the IETF Requests For Comment that define how the SSH protocol must be implemented. No need to read this in its entirety, but if you ever have questions about how a standard protocol works, you can review the RFCs, which show how it must work in fairly plain language.


## The Linux Firewall

1. Using the `mixed_environment` you configured earlier, ensure the firewalls are enabled.
   - install the `apache2` package on ubuntu, and make sure the service is running and enabled
   - install the `vsftpd` package on centos, and make sure the service is running and enabled
   - open the ports that these services are bound on, and test them from the other machine
     - you can test the apache port with `curl`
     - you can test the ftp port with `telnet`

   **HINT:** heed the warning when you enable ufw on ubuntu, and add an SSH rule first.

2. Listen on a high random port with the `netcat` utility, enable access, and connect from the other host.
   - ensure the `netcat` package is installed on both hosts
   - ports below 1024 are reserved and regular users cannot bind to them, use any port >=1024.

3. On both systems, allow `https` (or `443/tcp`) traffic from any host on the 192.168.33.0/24 network.
   - on CentOS, try using both creating an ad hoc rule with `--add-rich-rule` and a zone-based approach

   **HINT:** review `man ufw`, `man firewall-cmd`, and `man firewalld.richlanguage`

4. The applications we have been using are user-friendly wrappers for the `iptables` userspace utility, which itself manages kernel hooks provided by the `netfilter` project. Using nothing but iptables, you can turn a Linux system into a router or network switch. This is an advanced topic, but you should be somewhat familiar with the foundation of Linux packet filtering. Review or bookmark the following documentation:
   - [Netfilter.org](https://www.netfilter.org/)
   - [Netfilter Wikipedia article](https://en.wikipedia.org/wiki/Netfilter) - For a high-level view of all the parts
   - [Introduction to Netfilter](https://home.regit.org/netfilter-en/netfilter/) - An easy to follow blog post that describes netfilter rules in plain language, and with simple diagrams.
   - [IPTables packet traverse map](https://www.adminsehow.com/2011/09/iptables-packet-traverse-map/) - A detailed flowchart of packet traversal
   - [Linux Advanced Routing and Traffic Control](https://tldp.org/HOWTO/Adv-Routing-HOWTO/) - A truly deep dive, if you decide that a Linux networking career is for you


## Network Utilities

Use the existing `mixed_environment` VMs

1. On the interfaces that have an IP on the `192.168.33.0/24` subnet, use `ip` to add an address on the `192.168.44.0/24` subnet.
   - Can they ping each other? Why or why not?
   - Can they connect to one another via SSH? Why or why not?
   - Reboot the nodes. Do they retain their IP? Why or why not?

2. CentOS uses the NetworkManager service to manage it's network configuration.  Try using nmcli to add the secondary IP.
   - Before you begin, make a copy of the configuration file at `/etc/sysconfig/network-scripts/ifcfg-*`
   - Refer to the manpages for `nmcli`, which has examples at the bottom. You can also review the manpage for `nmcli-examples`
   - Reboot the node. It should retain its IP.
   - Compare the backed up ifcfg script with the new one.  What was added to the configuration?

   **HINT:** You will be modifying a NetworkManager connection.

3. Ubuntu uses Netplan to configure networks. Workstation version of Ubuntu use NetworkManager as well, but Ubuntu Server (as in this case) uses Netplan to manage systemd-networkd.
   - Review the manpage for `netplan`, particularly the examples at the bottom.
   - Review the configuration files at `/etc/netplan`
   - Try and add the additional IP address.
   - Reboot the node. It should retain its IP.


# ANSWERS

## Linux Firewall - Exercise 1

### On Ubuntu

```bash
sudo -i
ufw allow ssh
ufw enable
apt install apache2   # services are enabled by default in Ubuntu, no need to enable
ufw allow http
```

### On CentOS

```bash
sudo -i
# firewall is enabled and allows SSH by default, but to enable:
systemctl enable firewalld
systemctl start firewalld
dnf install vsftpd
systemctl enable vsftpd --now
firewall-cmd --add-service ftp
firewall-cmd --add-service ftp --permanent   # to make it persist after reboot
```

Another way to make changes is to stage them in the permanent configuration and reload the transient configuration. For example:

```bash
firewall-cmd --add-service http --permanent
firewall-cmd --add-service https --permanent
firewall-cmd --reload
```

## Linux Firewall - Exercise 2

### On Ubuntu

```bash
sudo apt install netcat
sudo ufw allow 10000/tcp
nc -l 10000
```

### On Centos

```bash
sudo dnf install netcat
sudo firewall-cmd --add-port 20000/tcp
```

## Linux Firewall - Exercise 3

### On Ubuntu

```bash
ufw allow from 192.168.33.0/24 port https
```

### On Centos

Here is a solution using rich language rules.

```bash
firewall-cmd --add-rich-rule="rule family=ipv4 source address=192.168.33.0/24 service name=https accept"
firewall-cmd --add-rich-rule="rule family=ipv4 source address=192.168.33.0/24 service name=https accept" --permanent
```

Here is a solution setting up a local zone

```bash
firewall-cmd --add-zone localnet
firewall-cmd --add-zone localnet --permanent
firewall-cmd --zone localnet --add-source 192.168.33.0/24 --permanent
firewall-cmd --zone localnet --add-port https --permenent
firewall-cmd --reload
```

## Network Utilities - Exercise 1

The command to add an IP address:

```bash
sudo ip address add 192.168.44.11/24
```

You must include the full CIDR, or the IP will have the /32 netmask and not be able to communicate with other systems on the network.

The systems will be able to ping one another, and should be able to ssh to one another, since your firewall rules for SSH are open on all networks.  They will not retain their IPs because the ip tool doesn't write any configuration.

## Network Utilities - Exercise 2

The command you will want to run is:

```bash
sudo nmcli con mod "System eth1" +ipv4.addresses 192.168.44.11/24
```

It's crucial that you include the `+`, or it will overwrite the other IP.  It retains the IP on reboot, since nmcli writes to the configuration, adding an IPADDR1 field (and associated fields) in addition to the IPADDR field.

## Network Utilities - Exercise 3

Netplan is a bit simpler than Network Manager.  All I had to do on my system was add another IP to the bulleted list in the config:

```yaml
$ cat /etc/netplan/50-vagrant.yaml 
---
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      addresses:
      - 192.168.33.12/24
      - 192.168.44.12/24

```