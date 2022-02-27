# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
# Credentials from course lab, please provide your own if different
provider "openstack" {
  user_name   = var.stack_credentials.user_name
  tenant_name = var.stack_credentials.tenant_name
  password    = var.stack_credentials.password
  auth_url    = var.stack_endpoint.auth_url
  region      = var.stack_endpoint.region
}

# Set project networking quota
resource "openstack_networking_quota_v2" "quota" {
  floatingip          = -1
  network             = -1
  port                = -1
  rbac_policy         = -1
  router              = -1
  security_group      = -1
  security_group_rule = -1
  subnet              = -1
  subnetpool          = -1
}

# Set project storage quota
resource "openstack_blockstorage_quotaset_v3" "quota" {
  volumes   = -1
  snapshots = -1
  gigabytes = -1
  per_volume_gigabytes = -1
  backups = -1
  backup_gigabytes = -1
  groups = -1
}

# Set project compute quota
resource "openstack_compute_quotaset_v2" "quota" {
  key_pairs            = -1
  ram                  = -1 
  cores                = -1
  instances            = -1
  server_groups        = -1
  server_group_members = -1
}

# Add ping and SSH to admin security group
resource "openstack_networking_secgroup_rule_v2" "rule-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "default"
}

resource "openstack_networking_secgroup_rule_v2" "rule-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "default"
}


# Create external network
resource "openstack_networking_network_v2" "external-net" {
  name           = "external-net"
  admin_state_up = "true"
  physical_network = "physnet1"
  network_type = "flat"
}

resource "openstack_networking_subnet_v2" "external-subnet" {
  name       = "external-subnet"
  network_id = "${openstack_networking_network_v2.external-net.id}"
  cidr       = var.provider_cidr
  ip_version = 4
}

# Create admin router
resource "openstack_networking_router_v2" "admin-router" {
  name                = "admin-router"
  external_network_id = "${openstack_networking_network_v2.external-net.id}"
}

# Create admin test network
resource "openstack_networking_network_v2" "admin-net" {
  name           = "admin-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "admin-subnet" {
  name       = "admin-subnet"
  network_id = "${openstack_networking_network_v2.admin-net.id}"
  cidr       = "172.16.0.0/24"
  ip_version = 4
}

# Add subnet to router
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${openstack_networking_router_v2.admin-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.admin-subnet.id}"
}