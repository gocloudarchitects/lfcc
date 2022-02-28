###################
# INPUT VARIABLES
###################

## STRINGS
# admin_project_id
# admin_default_secgroup_id
# provider_network_cidr
# provider_network_pool_start
# provider_network_pool_end
# admin_network_cidr
# default_image_name
# default_image_url
# default_image_version_tag

# public_flavors = list(object({
#    name = string
#    ram = number
#    vcpus = number
#    disk = number
#  }))


variable "admin_project_id" {
  type = string
}

variable "admin_default_secgroup_id" {
  type = string
}

variable "provider_network_cidr" {
  type = string
}

variable "provider_network_pool_start" {
  type = string
}

variable "provider_network_pool_end" {
  type = string
}

variable "admin_network_cidr" {
  type = string
}

variable "default_image_name" {
  type = string
}

variable "default_image_url" {
  type = string
}

variable "default_image_version_tag" {
  type = string
}

variable "public_flavors" {
  description = "Public flavors"
  type = list(object({
    name = string
    ram = number
    vcpus = number
    disk = number
  }))
}
