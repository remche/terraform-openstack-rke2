locals {
  # Set local vars conditionally
  final_network_id = var.assign_floating_ip ? openstack_networking_network_v2.nodes_net[0].id : var.network_id
  final_subnet_id  = var.assign_floating_ip ? openstack_networking_subnet_v2.nodes_subnet[0].id : var.subnet_id
  router_ip        = var.assign_floating_ip ? openstack_networking_router_v2.router[0].external_fixed_ip[0].ip_address : null
}

resource "openstack_networking_network_v2" "nodes_net" {
  # Create resource if assign_floating_ip is true
  count = var.assign_floating_ip ? 1 : 0

  name                  = var.network_name
  admin_state_up        = "true"
  port_security_enabled = "true"
  dns_domain            = var.dns_domain
}

resource "openstack_networking_subnet_v2" "nodes_subnet" {
  # Create resource if assign_floating_ip is true
  count = var.assign_floating_ip ? 1 : 0
 
  name            = var.subnet_name 
  network_id      = openstack_networking_network_v2.nodes_net[0].id
  cidr            = var.nodes_net_cidr
  ip_version      = 4
  dns_nameservers = var.dns_servers
}

resource "openstack_networking_router_v2" "router" {
  # Create resource if assign_floating_ip is true
  count = var.assign_floating_ip ? 1 : 0

  name                = var.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_net.*.id[0]
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  # Create resource if assign_floating_ip is true
  count = var.assign_floating_ip ? 1 : 0

  router_id = openstack_networking_router_v2.router[0].id
  subnet_id = openstack_networking_subnet_v2.nodes_subnet[0].id
}

data "openstack_networking_network_v2" "public_net" {
  name = var.public_net_name
}
