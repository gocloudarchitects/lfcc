output "admin_router_external_ip" {
  description = "Gateway IP address for the admin router on the external network"
  value = openstack_networking_router_v2.admin.external_fixed_ip[0].ip_address
}

output "external_network_id" {
  value = resource.openstack_networking_network_v2.external.id
}