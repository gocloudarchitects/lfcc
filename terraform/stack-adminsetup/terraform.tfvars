#
# Must fill this section with IDs from your environment
#

# Set these based on your openstack installation
#admin_project_id =
#admin_security_group_id =

# Set this based on your access network
provider_cidr = "192.168.6.0/24"

# Admin practice network CIDR (can be anything)
admin_cidr = "172.16.0.0/24"

# Cluster Access Info
stack_endpoint({
  auth_url = "http://192.168.5.254:35357/v3"
  region = "RegionOne"
})

stack_credentials({
# Cluster credentials
  user_name   = "admin"
  tenant_name = "admin"
  password    = "kolla"
})
