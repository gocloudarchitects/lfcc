#
# variables.tf initializes and describes input variables
#

#### CREDENTIALS ####

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


##### FLAVORS ####

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
