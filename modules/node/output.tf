output "floating_ip" {
  value = openstack_compute_floatingip_associate_v2.associate_floating_ip[*].floating_ip
}

output "internal_ip" {
  value = openstack_compute_instance_v2.instance[*].access_ip_v4
}
