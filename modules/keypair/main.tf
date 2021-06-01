resource "openstack_compute_keypair_v2" "key" {
  count      = var.ssh_keypair_name == null ? 1 : 0
  name       = "${var.cluster_name}-key"
  public_key = file("${var.ssh_key_file}.pub")
}
