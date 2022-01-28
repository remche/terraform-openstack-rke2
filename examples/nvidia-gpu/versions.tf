terraform {
  required_version = ">=0.13.1"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">=1.24.0"
    }
  }
}
