#
# variables.tf initializes and describes input variables
#


variable "tenants" {
  description = "list of tenants"
  type = set(string)
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



##### IMAGES AND FLAVORS ####

variable "default_image" {
  description = "Default VM image made available to tenants"
  default = {
    name = "cirros"
    url = "https://github.com/cirros-dev/cirros/releases/download/0.5.2/cirros-0.5.2-x86_64-disk.img"
    version_tag = "0.5.3"
  }
  type = map(string)
}

variable "flavors" {
  description = "Public flavors"
  type = list(object({
    name = string
    ram = number
    vcpus = number
    disk = number
  }))
  default = [
  {
    name = "m1.tiny"
    ram = 512
    vcpus = 1
    disk = 1
  },
  {
    name = "m1.small"
    ram = 1024
    vcpus = 1
    disk = 5
  },
  {
    name = "m1.medium"
    ram = 2048
    vcpus = 2
    disk = 10
  },
  {
    name = "m1.large"
    ram = 4096
    vcpus = 2
    disk = 40
  }
  ]
}



##################################
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