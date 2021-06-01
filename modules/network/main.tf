resource "openstack_networking_network_v2" "nodes_net" {
  name                  = var.network_name
  admin_state_up        = "true"
  port_security_enabled = "true"
  dns_domain            = var.dns_domain
}

resource "openstack_networking_subnet_v2" "nodes_subnet" {
  name            = var.subnet_name
  network_id      = openstack_networking_network_v2.nodes_net.id
  cidr            = var.nodes_net_cidr
  ip_version      = 4
  dns_nameservers = var.dns_servers
}

data "openstack_networking_network_v2" "public_net" {
  name = var.public_net_name
}

resource "openstack_networking_router_v2" "router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_net.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.nodes_subnet.id
}
