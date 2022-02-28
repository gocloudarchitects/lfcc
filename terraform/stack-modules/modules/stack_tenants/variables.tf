# INPUT VARIABLES
# tenants = set(string)
# external_network_id = string
# tenant_role_id = string

variable "tenants" {
  description = "list of tenants"
  type = set(string)
}

variable "external_network_id" {
  description = "external_network_id"
  type = string
}

variable "tenant_role_id" {
  description = "tenant default member role"
  type = string
}
