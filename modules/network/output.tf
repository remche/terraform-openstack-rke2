output "nodes_subnet_id" {
  value = openstack_networking_subnet_v2.nodes_subnet.id
}
output "nodes_net_id" {
  value = openstack_networking_network_v2.nodes_net.id
}
output "router_ip" {
  value = openstack_networking_router_v2.router.external_fixed_ip[0].ip_address
}

