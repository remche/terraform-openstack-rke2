module "controlplane" {
  source           = "remche/rke2/openstack"
  cluster_name     = var.cluster_name
  write_kubeconfig = true
  image_name       = "ubuntu-20.04-focal-x86_64"
  flavor_name      = "genX2"
  public_net_name  = "dmz"
}
