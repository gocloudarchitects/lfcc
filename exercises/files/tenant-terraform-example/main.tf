terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
  }
}

# Configure the OpenStack Provider
# Credentials from course lab, please provide your own if different
provider "openstack" {
  user_name   = "acme"
  tenant_name = "acme"
  password    = "kolla"
  auth_url    = "http://192.168.5.254:35357/v3"
  region      = "RegionOne"
}

# Create routed network and subnet

resource "openstack_networking_network_v2" "routed" {
  name           = "routed-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "routed" {
  name = "routed-subnet"
  network_id = "${openstack_networking_network_v2.routed.id}"
  cidr       = "192.168.111.0/24"
}

# Get router ID

data "openstack_networking_router_v2" "tenant_external" {
  name = "acme-router"
}

# Attach routed subnet to router

resource "openstack_networking_router_interface_v2" "tenant" {
  router_id = data.openstack_networking_router_v2.tenant_external.id
  subnet_id = openstack_networking_subnet_v2.routed.id
}

# Create non-routed network and subnet

resource "openstack_networking_network_v2" "private" {
  name           = "private-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private" {
  name = "private-subnet"
  network_id = "${openstack_networking_network_v2.private.id}"
  cidr       = "192.168.112.0/24"
  allocation_pool {
    start = "192.168.112.100"
    end = "192.168.112.200"
  }
}

# Create a keypair

resource "openstack_compute_keypair_v2" "acme" {
  name = "acme-keypair"
}

# Get image id

data "openstack_images_image_v2" "cirros" {
  name        = "cirros"
  most_recent = true
}

data "openstack_compute_flavor_v2" "small" {
  vcpus = 1
  ram   = 512
}

resource "openstack_compute_instance_v2" "acme" {
  count = 2
  name            = "acme-${count.index}"
  image_id        = data.openstack_images_image_v2.cirros.id
  flavor_id       = data.openstack_compute_flavor_v2.small.id
  key_pair        = openstack_compute_keypair_v2.acme.id
  security_groups = ["default"]

  network {
    name = "routed-net"
  }

  network {
    name = "private-net"
  }

  depends_on = [
    openstack_networking_subnet_v2.private,
    openstack_networking_subnet_v2.routed,
  ]
}


# Create floating IP and associate it with VM 1

resource "openstack_compute_floatingip_v2" "acme" {
  pool = "external-net"
}

resource "openstack_compute_floatingip_associate_v2" "acme_a" {
  floating_ip = openstack_compute_floatingip_v2.acme.address
  instance_id = openstack_compute_instance_v2.acme[0].id
}

# Create block storage volume and attach to the second VM

resource "openstack_blockstorage_volume_v3" "acme" {
  name = "acme-volume"
  size = 1
}

resource "openstack_compute_volume_attach_v2" "acme" {
  instance_id = openstack_compute_instance_v2.acme[1].id
  volume_id   = openstack_blockstorage_volume_v3.acme.id
}

provider "local" {}

resource "local_file" "private_key"{
  content = openstack_compute_keypair_v2.acme.private_key
  filename = "acme.priv"
}

resource "local_file" "public_key"{
  content = openstack_compute_keypair_v2.acme.public_key
  filename = "acme.pub"
}

output "floating_ip" {
  value = openstack_compute_floatingip_v2.acme.address
}

output "instance_ips" {
  value = {
    for index, item in openstack_compute_instance_v2.acme: item.name => item.network[*].fixed_ip_v4
  }
}