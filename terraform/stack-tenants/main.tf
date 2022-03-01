###################
# DATA SOURCES
###################


data "openstack_networking_network_v2" "external" {
  external = true
}

data "openstack_identity_role_v3" "member" {
  name = "_member_"
}

#################
# RESOURCES
#################

resource "openstack_identity_project_v3" "projects" {
  for_each = var.tenants
  name = each.key
}

resource "openstack_identity_user_v3" "tenants" {
  for_each = resource.openstack_identity_project_v3.projects
  name = each.value.name
  default_project_id = each.value.id
  password = "kolla"
  ignore_change_password_upon_first_use = true
}

resource "openstack_identity_role_assignment_v3" "member" {
  for_each = resource.openstack_identity_user_v3.tenants
  user_id    = each.value.id
  project_id = each.value.default_project_id
  role_id    = data.openstack_identity_role_v3.member.id
}

# Set project networking quota
resource "openstack_networking_quota_v2" "tenant" {
  for_each = resource.openstack_identity_project_v3.projects
  project_id          = each.value.id
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
resource "openstack_blockstorage_quotaset_v3" "tenant" {
  for_each = resource.openstack_identity_project_v3.projects
  project_id          = each.value.id
  volumes   = 10
  snapshots = 4
  gigabytes = 100
  per_volume_gigabytes = 10
  backups = 4
  backup_gigabytes = 10
  groups = 100
}

# Set project compute quota
resource "openstack_compute_quotaset_v2" "tenant" {
  for_each = resource.openstack_identity_project_v3.projects
  project_id          = each.value.id
  key_pairs            = 10
  ram                  = 40960
  cores                = 32
  instances            = 20
  server_groups        = 4
  server_group_members = 8
}

# Create egress router
resource "openstack_networking_router_v2" "tenant" {
  for_each = resource.openstack_identity_project_v3.projects
  tenant_id = each.value.id 
  name = "${each.value.name}-router"
  external_network_id = data.openstack_networking_network_v2.external.id
}


output "tenant_id" {
  value = {
    for name, id in resource.openstack_identity_user_v3.tenants: name => id.id
  }
}