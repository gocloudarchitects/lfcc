output "admin_router_external_ip" {
  description = "Gateway IP address for the admin router on the external network"
  value = module.stack_admin_setup.admin_router_external_ip
}

output "tenant_id" {
  value = module.stack_tenants.tenant_id
}