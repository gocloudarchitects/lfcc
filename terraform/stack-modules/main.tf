terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
  }
}

provider "openstack" {
  user_name   = var.stack_credentials.user_name
  tenant_name = var.stack_credentials.tenant_name
  password    = var.stack_credentials.password
  auth_url    = "http://192.168.5.254:35357/v3"
  region      = "RegionOne"
}

data "openstack_identity_project_v3" "admin" {
  name = "admin"
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
  tenant_id = data.openstack_identity_project_v3.admin.id
}

data "openstack_identity_role_v3" "member" {
  name = "_member_"
}

module "stack_admin_setup" {
  source = "./modules/stack_admin_setup"
  # vars
  admin_project_id = data.openstack_identity_project_v3.admin.id
  admin_default_secgroup_id = data.openstack_networking_secgroup_v2.default.id

  provider_network_cidr = "192.168.6.0/24"
  provider_network_pool_start = "192.168.6.100"
  provider_network_pool_end = "192.168.6.199"

  admin_network_cidr = "172.168.0.0/24"
  default_image_name = "cirros"
  default_image_url = "https://github.com/cirros-dev/cirros/releases/download/0.5.2/cirros-0.5.2-x86_64-disk.img"
  default_image_version_tag = "0.5.3"
  public_flavors = var.flavors
}

module "stack_tenants" {
  source = "./modules/stack_tenants"
  external_network_id = module.stack_admin_setup.external_network_id
  tenant_role_id = data.openstack_identity_role_v3.member.id
  tenants = [
    "acme",
    "bigco",
    "canada",
    "dave",
  ]
}