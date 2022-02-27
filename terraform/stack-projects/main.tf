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

# Create project
resource "openstack_identity_project_v3" "project" {
  name = "tenant1"
}

# Set project networking quota
resource "openstack_networking_quota_v2" "quota" {
  project_id          = "${openstack_identity_project_v3.project.id}"
  floatingip          = 10
  network             = 4
  port                = 100
  rbac_policy         = 10
  router              = 4
  security_group      = 10
  security_group_rule = 100
  subnet              = 8
  subnetpool          = 2
}

# Set project storage quota
resource "openstack_blockstorage_quotaset_v3" "quota" {
  project_id = "${openstack_identity_project_v3.project.id}"
  volumes   = 10
  snapshots = 4
  gigabytes = 100
  per_volume_gigabytes = 10
  backups = 4
  backup_gigabytes = 10
  groups = 100
}

# Set project compute quota
resource "openstack_compute_quotaset_v2" "quota" {
  project_id           = "${openstack_identity_project_v3.project.id}"
  key_pairs            = 10
  ram                  = 40960
  cores                = 32
  instances            = 20
  server_groups        = 4
  server_group_members = 8
}

# Create egress router
resource "openstack_networking_router_v2" "router" {
  name                = "tenant1-router"
  external_network_id = "4a07c939-d7e7-408d-9192-853f453b88d5"
  tenant_id = "${openstack_identity_project_v3.project.id}"
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
