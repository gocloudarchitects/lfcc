#
# variables.tf initializes and describes input variables
#

variable "stack_endpoint" {
  description = "OpenStack API endpoint"
  type = object({
    auth_url = string
    region = string
    })
}

variable "stack_credentials" {
  description = "OpenStack API credentials"
  type = object({
    user_name = string
    tenant_name = string
    password = string
    })
  sensitive = true
}

