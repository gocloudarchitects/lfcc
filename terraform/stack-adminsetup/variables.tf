#
# variables.tf initializes and describes input variables
#

#### FROM ENVIRONMENT ####

variable "admin_project_id" {
  description = "Admin project ID"
}

variable "admin_security_group" {
  description = "Admin security group ID"
}

variable "provider_cidr" {
  description = "CIDR of physical access network"
}

variable "provider_cidr" {
  description = "CIDR of admin test network"
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

variable "stack_endpoint" {
  description = "OpenStack API endpoint"
  type = object({
    auth_url = string
    region = string
    })
}
