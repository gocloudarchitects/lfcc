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
  user_name   = "admin"
  tenant_name = "admin"
  password    = "kolla"
  auth_url    = "http://192.168.5.254:35357/v3"
  region      = "RegionOne"
}


# Set project networking quota
resource "openstack_networking_quota_v2" "quota" {
  project_id          = var.admin_project_id
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
  project_id = var.admin_project_id
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
  project_id           = var.admin_project_id
  key_pairs            = -1
  ram                  = -1 
  cores                = -1
  instances            = -1
  server_groups        = -1
  server_group_members = -1
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
resource "openstack_networking_router_v2" "router" {
  name                = "admin-router"
  external_network_id = ""
  tenant_id = var.admin_project_id
}

# Create user
resource "openstack_identity_user_v3" "user" {
  default_project_id = "${openstack_identity_project_v3.project.id}"
  name               = "tentant1"
  description        = "Tenant 1"
  password = "password123"
  ignore_change_password_upon_first_use = test
}

# Assign user to `_member_` role

resource "openstack_identity_role_assignment_v3" "role_assignment_1" {
  user_id    = "${openstack_identity_user_v3.user.id}"
  project_id = "${openstack_identity_project_v3.project.id}"
  role_id    = "225b2611166c406888bb23c1e6b52627"
}

