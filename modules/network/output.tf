output "router_interface" {
  value = openstack_networking_router_interface_v2.router_interface
}

output "nodes_subnet" {
  value = openstack_networking_subnet_v2.nodes_subnet
}
output "nodes_net_name" {
  value = openstack_networking_network_v2.nodes_net.name
}
