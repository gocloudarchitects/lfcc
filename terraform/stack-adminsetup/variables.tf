#
# variables.tf initializes and describes input variables
#


variable "admin_project_id" {
  description = "Admin project ID"
}

variable "admin_security_group_id" {
  description = "Admin security group ID"
}

variable "provider_network" {
  description = "CIDR of physical access network"
    default = {
    cidr   = "192.168.6.0/24"
    pool_start = "192.168.6.100"
    pool_end   = "192.168.6.199"
  }
  type = object({
    cidr = string
    pool_start = string
    pool_end = string
    })


}

variable "admin_cidr" {
  description = "CIDR of admin test network"
  default = "172.168.0.0/24"
}

#### CREDENTIALS AND ENDPOINT ####

variable "stack_credentials" {
  description = "OpenStack API credentials"
  default = {
    user_name   = "admin"
    tenant_name = "admin"
    password    = "kolla"
  }
  type = object({
    user_name = string
    tenant_name = string
    password = string
    })
  sensitive = true
}

variable "stack_endpoint" {
  description = "OpenStack API endpoint"
  default = {
    auth_url = "http://192.168.5.254:35357/v3"
    region = "RegionOne"
  }
  type = object({
    auth_url = string
    region = string
    })
}
