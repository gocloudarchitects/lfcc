#
# Must fill this section with IDs from your environment
#

admin_security_group_id = ""
provider_cidr = "192.168.6.0/24"
admin_cidr = "172.16.0.0/24"

stack_credentials({
# Cluster Access Info
stack_endpoint({
  auth_url = "http://192.168.5.254:35357/v3"
  region = "RegionOne"
})

# Cluster credentials
  user_name   = "admin"
  tenant_name = "admin"
  password    = "kolla"
})
