output "floating_ip" {
  value = openstack_compute_floatingip_associate_v2.associate_floating_ip[*].floating_ip
}

output "bootstrap_ip" {
  value = var.bootstrap_server == "" ? openstack_compute_instance_v2.instance[0].access_ip_v4 : ""
}
