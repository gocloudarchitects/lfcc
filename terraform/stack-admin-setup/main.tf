#####################
# PROVIDER CONFIG
#####################


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


###################
# DATA SOURCES
###################

data "openstack_identity_project_v3" "admin" {
  name = "admin"
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
  tenant_id = data.openstack_identity_project_v3.admin.id
}

#################
# RESOURCES
#################

## ADMIN QUOTA

# Set project networking quota
resource "openstack_networking_quota_v2" "admin" {
  floatingip          = -1
  network             = -1
  port                = -1
  rbac_policy         = -1
  router              = -1
  security_group      = -1
  security_group_rule = -1
  subnet              = -1
  subnetpool          = -1
  project_id = data.openstack_identity_project_v3.admin.id
}

# Set project storage quota
resource "openstack_blockstorage_quotaset_v3" "admin" {
  volumes   = -1
  snapshots = -1
  gigabytes = -1
  per_volume_gigabytes = -1
  backups = -1
  backup_gigabytes = -1
  groups = -1
  project_id = data.openstack_identity_project_v3.admin.id
}

# Set project compute quota
resource "openstack_compute_quotaset_v2" "admin" {
  key_pairs            = -1
  ram                  = -1 
  cores                = -1
  instances            = -1
  server_groups        = -1
  server_group_members = -1
  project_id = data.openstack_identity_project_v3.admin.id
}

## NETWORK RESOURCES

# Add ping and SSH to admin security group
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = data.openstack_networking_secgroup_v2.default.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = data.openstack_networking_secgroup_v2.default.id
}

# Create external network
resource "openstack_networking_network_v2" "external" {
  name           = "external-net"
  admin_state_up = true
  external = true
  segments{
    physical_network = "physnet1"
    network_type = "flat"
  }
}

resource "openstack_networking_subnet_v2" "external" {
  name       = "external-subnet"
  network_id = resource.openstack_networking_network_v2.external.id
  cidr       = var.provider_network.cidr
  ip_version = 4
  allocation_pool{
    start = var.provider_network.pool_start
    end = var.provider_network.pool_end
  }
}

# Create admin router
resource "openstack_networking_router_v2" "admin" {
  name                = "admin-router"
  external_network_id = resource.openstack_networking_network_v2.external.id
}

# Create admin test network
resource "openstack_networking_network_v2" "admin" {
  name           = "admin-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "admin" {
  name       = "admin-subnet"
  network_id = resource.openstack_networking_network_v2.admin.id
  cidr       = var.admin_cidr
  ip_version = 4
}

# Add subnet to router
resource "openstack_networking_router_interface_v2" "admin_gateway" {
  router_id = resource.openstack_networking_router_v2.admin.id
  subnet_id = resource.openstack_networking_subnet_v2.admin.id
}

## IMAGE

resource "openstack_images_image_v2" "cirros" {
  name = var.default_image.name
  image_source_url = var.default_image.url
  container_format = "bare"
  disk_format = "qcow2"
  visibility = "public"
  properties = {
    version = var.default_image.version_tag
  }
}


## Flavors

resource "openstack_compute_flavor_v2" "public" {
  count = length(var.flavors)
  name  = var.flavors[count.index].name
  ram   = var.flavors[count.index].ram
  vcpus = var.flavors[count.index].vcpus
  disk  = var.flavors[count.index].disk
  is_public = true
}


########################
# OUTPUTS
########################

output "admin_router_external_ip" {
  description = "Gateway IP address for the admin router on the external network"
  value = openstack_networking_router_v2.admin.external_fixed_ip[0].ip_address
}


