output "tenant_id" {
  value = {
    for name, id in resource.openstack_identity_user_v3.tenants: name => id.id
  }
}