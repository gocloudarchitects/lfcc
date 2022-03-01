variable "tenants" {
  description = "list of tenants"
  type = set(string)
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