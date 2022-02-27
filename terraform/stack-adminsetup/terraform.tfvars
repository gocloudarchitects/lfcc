# This file for user variables and default overrides
# Defaults are defined in variables.tf

# MANDATORY

# Set these based on your openstack installation
# admin_project_id =
# admin_security_group_id =



#  OPTIONAL

# Set this based on your access network
#provider_network({
#  cidr = "192.168.6.0/24"
#  pool_start = "192.168.6.100"
#  pool_end = "192.168.6.199"
#})

# Admin practice network CIDR (can be anything)
# admin_cidr = "172.16.0.0/24"

# Cluster Access Info
#stack_endpoint({
#  auth_url = "http://192.168.5.254:35357/v3"
#  region = "RegionOne"
#})

# Cluster credentials

#stack_credentials({
#  user_name   = "admin"
#  tenant_name = "admin"
#  password    = "kolla"
#})
