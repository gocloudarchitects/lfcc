#
# variables.tf initializes and describes input variables
#


variable "admin_project_id" {
  description = "Admin project ID"
}

variable "admin_security_group_id" {
  description = "Admin security group ID"
}

variable "provider_cidr" {
  description = "CIDR of physical access network"
}

variable "admin_cidr" {
  description = "CIDR of admin test network"
}


variable "stack_endpoint" {
  description = "OpenStack API endpoint"
  type = object({
    auth_url = string
    region = string
    })
}

#### CREDENTIALS AND ENDPOINT ####

variable "stack_credentials" {
  description = "OpenStack API credentials"
  type = object({
    user_name = string
    tenant_name = string
    password = string
    })
  sensitive = true
}

