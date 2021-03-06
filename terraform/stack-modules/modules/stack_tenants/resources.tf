resource "openstack_identity_project_v3" "projects" {
  for_each = var.tenants
  name = each.key
}

resource "openstack_identity_user_v3" "users" {
  for_each = resource.openstack_identity_project_v3.projects
  name = each.value.name
  default_project_id = each.value.id
  password = "kolla"
  ignore_change_password_upon_first_use = true
}

resource "openstack_identity_role_assignment_v3" "member" {
  for_each = resource.openstack_identity_user_v3.users
  user_id    = each.value.id
  project_id = each.value.default_project_id
  role_id    = var.tenant_role_id
}

data "openstack_networking_secgroup_v2" "default" {
  for_each = resource.openstack_identity_project_v3.projects
  tenant_id = each.value.id
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  for_each = resource.openstack_identity_project_v3.projects
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = data.openstack_networking_secgroup_v2.default[each.key].id
  tenant_id = each.value.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  for_each = resource.openstack_identity_project_v3.projects
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = data.openstack_networking_secgroup_v2.default[each.key].id
  tenant_id = each.value.id
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
  external_network_id = var.external_network_id
}
