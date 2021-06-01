output "keypair_name" {
  value = var.ssh_keypair_name == null ? openstack_compute_keypair_v2.key[0].name : var.ssh_keypair_name
}
